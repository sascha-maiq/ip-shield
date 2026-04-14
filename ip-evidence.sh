#!/usr/bin/env bash
# ============================================================
# IP-SHIELD: Evidence Package Generator
# ============================================================
# Extracts IP documentation from git history and project files
# to generate court-grade evidence packages.
#
# Usage:
#   ./ip-evidence.sh                    # Full evidence package
#   ./ip-evidence.sh --feedback         # Post-commit feedback only
#   ./ip-evidence.sh --report           # Structured report (for lawyer/DD)
#   ./ip-evidence.sh --since 2026-01-01 # Since specific date
#   ./ip-evidence.sh --author "Name"    # Filter by author
#   ./ip-evidence.sh --lang DE          # Report language (DE/EN)
#   ./ip-evidence.sh --output ./report  # Output directory
#
# Requires: git, bash 3.2+
# Compatible with macOS (BSD) and Linux (GNU). Windows only via WSL/Git Bash.
# ============================================================

set -euo pipefail

# ── Configuration (override via environment or flags) ────────

REPORT_LANG="${IP_SHIELD_LANG:-DE}"
OUTPUT_DIR="${IP_SHIELD_OUTPUT:-./ip-evidence-$(date +%Y%m%d-%H%M%S)}"
SINCE_DATE=""
AUTHOR_FILTER=""
MODE="full"  # full | feedback | report
PROJECT_NAME=""
DOCS_DIR="docs"
SPEC_DIRS="${IP_SHIELD_SPEC_DIRS:-docs/specs specs dev/specs}"  # Space-separated list
MAX_COMMITS_DUMP=1000   # Max commits for full dump files
MAX_COMMITS_FREQ=500    # Max commits for file frequency analysis

# ── Color output ─────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# ── Parse arguments ──────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case $1 in
    --feedback)  MODE="feedback"; shift ;;
    --report)    MODE="report"; shift ;;
    --since)     SINCE_DATE="$2"; shift 2 ;;
    --author)    AUTHOR_FILTER="$2"; shift 2 ;;
    --lang)      REPORT_LANG="$2"; shift 2 ;;
    --output)    OUTPUT_DIR="$2"; shift 2 ;;
    --help|-h)
      echo "IP-SHIELD Evidence Package Generator"
      echo ""
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Modes:"
      echo "  (default)    Full evidence package (all files + report)"
      echo "  --feedback   Post-commit IP quality feedback"
      echo "  --report     Structured report only (for lawyer/DD)"
      echo ""
      echo "Options:"
      echo "  --since DATE   Only analyze commits since DATE (YYYY-MM-DD)"
      echo "  --author NAME  Filter commits by author"
      echo "  --lang LANG    Report language: DE (default) or EN"
      echo "  --output DIR   Output directory (default: ./ip-evidence-TIMESTAMP)"
      echo "  --help         Show this help"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Verify we're in a git repository ────────────────────────

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo -e "${RED}Error: Not inside a git repository.${NC}"
  exit 1
fi

PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
GIT_ROOT=$(git rev-parse --show-toplevel)

# ── Helper: return git filter args as string ─────────────────

git_filter_args() {
  # Returns --since and --author flags (call with $(...) and use unquoted)
  local result=""
  [[ -n "$SINCE_DATE" ]] && result="--since=$SINCE_DATE"
  [[ -n "$AUTHOR_FILTER" ]] && result="$result --author=$AUTHOR_FILTER"
  echo "$result"
}

# macOS-compatible: extract content after a tag like [HUMAN]: ...
# Reads from [TAG]: until the next [TAG]: or end of message (multiline support)
extract_tag_content() {
  local tag="$1" text="$2"
  echo "$text" | awk -v t="$tag" '
    BEGIN { pat = "\\[" t "\\]:" }
    $0 ~ pat { found=1; sub(/.*\[[A-Z_-]+\]:[[:space:]]*/, ""); print; next }
    found && (/\[[A-Z_-]+\]:/ || /^[[:space:]]*$/) { exit }
    found { print }
  '
}

file_exists_in_repo() {
  [[ -f "$GIT_ROOT/$1" ]]
}

# ── Compute all stats once (cached in global vars) ───────────

CACHED_TOTAL=""
CACHED_IP_TAGGED=""
CACHED_HIGH=""
CACHED_MEDIUM=""
CACHED_LOW=""

compute_stats() {
  if [[ -n "$CACHED_TOTAL" ]]; then return; fi

  # shellcheck disable=SC2046
  local filters
  filters=$(git_filter_args)

  # Total commits
  CACHED_TOTAL=$(git log --oneline $filters 2>/dev/null | wc -l | tr -d ' ')

  # IP-tagged commits
  CACHED_IP_TAGGED=$(git log --oneline --grep="\[HUMAN\]:" $filters 2>/dev/null | wc -l | tr -d ' ')

  # IP scores — scan only IP-tagged commits (much smaller set)
  local scores
  scores=$(git log --grep="\[IP-SCORE\]:" --format="%B---SEP---" $filters 2>/dev/null \
    | grep '\[IP-SCORE\]:' | sed 's/.*\[IP-SCORE\]:[[:space:]]*//' | awk '{print $1}' || true)

  CACHED_HIGH=$(echo "$scores" | grep -c "HIGH" || true)
  CACHED_MEDIUM=$(echo "$scores" | grep -c "MEDIUM" || true)
  CACHED_LOW=$(echo "$scores" | grep -c "LOW" || true)
}

# ── Mode: Post-Commit Feedback ──────────────────────────────

run_feedback() {
  echo -e "${BOLD}${CYAN}IP-SHIELD: Post-Commit Feedback${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  local last_hash last_msg last_author last_date files_changed
  last_hash=$(git log -1 --format="%H")
  last_msg=$(git log -1 --format="%B")
  last_author=$(git log -1 --format="%an")
  last_date=$(git log -1 --format="%ai")
  files_changed=$(git diff-tree --no-commit-id --name-only -r "$last_hash" | wc -l | tr -d ' ')

  echo -e "Commit: ${BLUE}$(git log -1 --format='%h')${NC} by ${last_author}"
  echo -e "Date:   ${last_date}"
  echo -e "Files:  ${files_changed} changed"
  echo ""

  local score=0
  local max_score=7

  echo -e "${BOLD}IP Quality Check:${NC}"

  # [HUMAN] tag
  if echo "$last_msg" | grep -q '\[HUMAN\]:'; then
    echo -e "  ${GREEN}✓${NC} [HUMAN] tag present"
    local human_content word_count
    human_content=$(extract_tag_content "HUMAN" "$last_msg")
    word_count=$(echo "$human_content" | wc -w | tr -d ' ')
    if [[ $word_count -ge 10 ]]; then
      echo -e "  ${GREEN}✓${NC} [HUMAN] tag substantive (${word_count} words)"
      score=$((score + 2))
    else
      echo -e "  ${YELLOW}△${NC} [HUMAN] tag brief (${word_count} words) — more detail strengthens IP"
      score=$((score + 1))
    fi
    # Weak content detection: process descriptions without design reasoning
    if echo "$human_content" | grep -qiE '^(reviewed|approved|checked|looked at|fixed|updated)'; then
      if ! echo "$human_content" | grep -qiE '(because|weil|statt|instead|design|architect|algorithm|chose|selected|decided)'; then
        echo -e "  ${YELLOW}△${NC} [HUMAN] describes process, not design decisions — add reasoning (weil/statt/because)"
      fi
    fi
  else
    echo -e "  ${RED}✗${NC} [HUMAN] tag missing"
  fi

  # [AI-ROLE] tag
  if echo "$last_msg" | grep -q '\[AI-ROLE\]:'; then
    echo -e "  ${GREEN}✓${NC} [AI-ROLE] tag present"
    score=$((score + 1))
  else
    echo -e "  ${RED}✗${NC} [AI-ROLE] tag missing"
  fi

  # [CREATIVE-DECISIONS] tag
  if echo "$last_msg" | grep -q '\[CREATIVE-DECISIONS\]:'; then
    local decisions_content
    decisions_content=$(extract_tag_content "CREATIVE-DECISIONS" "$last_msg")
    if [[ "$decisions_content" =~ ^(none|keine|n/a|-) ]]; then
      echo -e "  ${YELLOW}△${NC} [CREATIVE-DECISIONS] present but empty — expected for LOW-IP commits"
      score=$((score + 1))
    else
      echo -e "  ${GREEN}✓${NC} [CREATIVE-DECISIONS] tag with content"
      score=$((score + 2))
    fi
  else
    echo -e "  ${RED}✗${NC} [CREATIVE-DECISIONS] tag missing"
  fi

  # [IP-SCORE] tag
  if echo "$last_msg" | grep -q '\[IP-SCORE\]:'; then
    local ip_score
    ip_score=$(extract_tag_content "IP-SCORE" "$last_msg")
    echo -e "  ${GREEN}✓${NC} [IP-SCORE]: ${ip_score}"
    score=$((score + 1))
    if [[ "$ip_score" == "HIGH" ]]; then
      if echo "$last_msg" | grep -q '\[SPEC-REF\]:'; then
        echo -e "  ${GREEN}✓${NC} [SPEC-REF] present (expected for HIGH)"
        score=$((score + 1))
      else
        echo -e "  ${YELLOW}△${NC} HIGH score without [SPEC-REF] — consider adding spec reference"
      fi
    fi
  else
    echo -e "  ${RED}✗${NC} [IP-SCORE] tag missing"
  fi

  # Co-Authored-By
  if echo "$last_msg" | grep -qi 'Co-Authored-By:'; then
    echo -e "  ${GREEN}✓${NC} Co-Authored-By header present"
  else
    echo -e "  ${YELLOW}△${NC} Co-Authored-By header missing (recommended when AI assisted)"
  fi

  # Score summary
  echo ""
  local pct=$((score * 100 / max_score))
  if [[ $pct -ge 80 ]]; then
    echo -e "${BOLD}IP Documentation Score: ${GREEN}${score}/${max_score} (${pct}%) — Excellent${NC}"
  elif [[ $pct -ge 50 ]]; then
    echo -e "${BOLD}IP Documentation Score: ${YELLOW}${score}/${max_score} (${pct}%) — Adequate${NC}"
  else
    echo -e "${BOLD}IP Documentation Score: ${RED}${score}/${max_score} (${pct}%) — Needs Improvement${NC}"
  fi

  # Recommendations
  echo ""
  if [[ $pct -lt 80 ]]; then
    echo -e "${BOLD}Recommendations:${NC}"
    echo "$last_msg" | grep -q '\[HUMAN\]:' || echo "  → Add [HUMAN]: tag describing YOUR creative decisions"
    echo "$last_msg" | grep -q '\[CREATIVE-DECISIONS\]:' || echo "  → Add [CREATIVE-DECISIONS]: with specific design choices"
    echo "$last_msg" | grep -q '\[IP-SCORE\]:' || echo "  → Add [IP-SCORE]: to classify the commit's IP value"
    if [[ $files_changed -gt 5 ]] && ! echo "$last_msg" | grep -q '\[SPEC-REF\]:'; then
      echo "  → Large change without spec reference — consider writing a spec"
    fi
  fi

  # Project health
  echo ""
  echo -e "${BOLD}Project IP Health:${NC}"
  file_exists_in_repo "${DOCS_DIR}/ARCHITECTURE.md" \
    && echo -e "  ${GREEN}✓${NC} ARCHITECTURE.md exists" \
    || echo -e "  ${RED}✗${NC} ARCHITECTURE.md missing — your most important IP document!"

  if ls "$GIT_ROOT/${DOCS_DIR}"/decisions/ADR-*.md &>/dev/null 2>&1; then
    local adr_count
    adr_count=$(ls "$GIT_ROOT/${DOCS_DIR}"/decisions/ADR-*.md 2>/dev/null | wc -l | tr -d ' ')
    echo -e "  ${GREEN}✓${NC} ${adr_count} ADR(s) found"
  else
    echo -e "  ${YELLOW}△${NC} No ADRs found — document major design decisions"
  fi

  file_exists_in_repo "${DOCS_DIR}/process/DEVELOPMENT-DIARY.md" \
    && echo -e "  ${GREEN}✓${NC} Development diary exists" \
    || echo -e "  ${YELLOW}△${NC} No development diary"

  local current_month
  current_month=$(date +%Y-%m)
  file_exists_in_repo "${DOCS_DIR}/ip-log/${current_month}.md" \
    && echo -e "  ${GREEN}✓${NC} IP log for ${current_month} exists" \
    || echo -e "  ${YELLOW}△${NC} No IP log for ${current_month}"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ── Mode: Full Evidence Package ──────────────────────────────

run_full() {
  echo -e "${BOLD}${CYAN}IP-SHIELD: Evidence Package Generator${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "Project:  ${BOLD}${PROJECT_NAME}${NC}"
  echo -e "Language: ${REPORT_LANG}"
  echo -e "Output:   ${OUTPUT_DIR}"
  [[ -n "$SINCE_DATE" ]] && echo -e "Since:    ${SINCE_DATE}"
  [[ -n "$AUTHOR_FILTER" ]] && echo -e "Author:   ${AUTHOR_FILTER}"
  echo ""

  mkdir -p "$OUTPUT_DIR"

  # Compute all stats once
  compute_stats

  # ── 1. Collect commits ──
  echo -e "${BLUE}[1/6]${NC} Extracting commits (last ${MAX_COMMITS_DUMP})..."

  local filters
  filters=$(git_filter_args)

  # shellcheck disable=SC2086
  git log --max-count="$MAX_COMMITS_DUMP" --format="---BEGIN COMMIT---%nHash: %H%nDate: %ai%nAuthor: %an <%ae>%nSubject: %s%n%n%b%n---END COMMIT---" $filters \
    > "$OUTPUT_DIR/01-all-commits.txt" 2>/dev/null || true

  # IP-tagged commits only (no limit — these are the important ones)
  # shellcheck disable=SC2086
  git log --grep="\[HUMAN\]:" --format="---BEGIN COMMIT---%nHash: %H%nDate: %ai%nAuthor: %an <%ae>%nSubject: %s%n%n%b%n---END COMMIT---" $filters \
    > "$OUTPUT_DIR/02-ip-tagged-commits.txt" 2>/dev/null || true

  echo "  Found ${CACHED_IP_TAGGED}/${CACHED_TOTAL} commits with IP tags"

  # ── 2. IP scores ──
  echo -e "${BLUE}[2/6]${NC} Analyzing IP scores..."
  echo "  HIGH: ${CACHED_HIGH}, MEDIUM: ${CACHED_MEDIUM}, LOW: ${CACHED_LOW}"

  # ── 3. Copy documentation files ──
  echo -e "${BLUE}[3/6]${NC} Collecting documentation files..."
  mkdir -p "$OUTPUT_DIR/docs"

  for claude_file in CLAUDE.md .claude.md; do
    if [[ -f "$GIT_ROOT/$claude_file" ]]; then
      cp "$GIT_ROOT/$claude_file" "$OUTPUT_DIR/docs/"
      echo "  Copied $claude_file"
    fi
  done

  if [[ -f "$GIT_ROOT/${DOCS_DIR}/ARCHITECTURE.md" ]]; then
    cp "$GIT_ROOT/${DOCS_DIR}/ARCHITECTURE.md" "$OUTPUT_DIR/docs/"
    echo "  Copied ARCHITECTURE.md"
  fi

  if ls "$GIT_ROOT/${DOCS_DIR}"/decisions/ADR-*.md &>/dev/null 2>&1; then
    mkdir -p "$OUTPUT_DIR/docs/decisions"
    cp "$GIT_ROOT/${DOCS_DIR}"/decisions/ADR-*.md "$OUTPUT_DIR/docs/decisions/"
    local adr_count
    adr_count=$(ls "$OUTPUT_DIR/docs/decisions/"ADR-*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "  Copied ${adr_count} ADRs"
  fi

  # Search all configured spec directories
  local spec_found=false
  for spec_dir in $SPEC_DIRS; do
    if [[ -d "$GIT_ROOT/${spec_dir}" ]] && ls "$GIT_ROOT/${spec_dir}"/*.md &>/dev/null 2>&1; then
      mkdir -p "$OUTPUT_DIR/docs/specs"
      local spec_count=0
      for f in "$GIT_ROOT/${spec_dir}"/*.md; do
        local basename_f
        basename_f=$(basename "$f")
        # Skip templates
        [[ "$basename_f" == *TEMPLATE* ]] && continue
        [[ "$basename_f" == *template* ]] && continue
        cp "$f" "$OUTPUT_DIR/docs/specs/"
        spec_count=$((spec_count + 1))
      done
      if [[ $spec_count -gt 0 ]]; then
        echo "  Copied ${spec_count} spec(s) from ${spec_dir}"
        spec_found=true
      fi
    fi
  done
  # Also collect plan/spec files from docs root (PLAN-*.md, *-Strategy.md, etc.)
  if [[ -d "$GIT_ROOT/${DOCS_DIR}" ]]; then
    for pattern in "PLAN-*.md" "*-Strategy.md"; do
      for f in "$GIT_ROOT/${DOCS_DIR}"/$pattern; do
        [[ -f "$f" ]] || continue
        mkdir -p "$OUTPUT_DIR/docs/specs"
        local basename_f
        basename_f=$(basename "$f")
        if [[ ! -f "$OUTPUT_DIR/docs/specs/$basename_f" ]]; then
          cp "$f" "$OUTPUT_DIR/docs/specs/"
          echo "  Copied ${basename_f} (from ${DOCS_DIR}/)"
          spec_found=true
        fi
      done
    done
  fi
  $spec_found || echo "  No specs found"

  if [[ -d "$GIT_ROOT/${DOCS_DIR}/ip-log" ]]; then
    mkdir -p "$OUTPUT_DIR/docs/ip-log"
    cp "$GIT_ROOT/${DOCS_DIR}"/ip-log/*.md "$OUTPUT_DIR/docs/ip-log/" 2>/dev/null || true
    echo "  Copied IP log"
  fi

  if [[ -f "$GIT_ROOT/${DOCS_DIR}/process/DEVELOPMENT-DIARY.md" ]]; then
    cp "$GIT_ROOT/${DOCS_DIR}/process/DEVELOPMENT-DIARY.md" "$OUTPUT_DIR/docs/"
    echo "  Copied Development Diary"
  fi

  # ── 4. Git history analysis ──
  echo -e "${BLUE}[4/6]${NC} Generating git history analysis..."

  {
    echo "# Git History Analysis"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""
    echo "## Statistics"
    echo "- Total commits: ${CACHED_TOTAL}"
    echo "- IP-tagged commits: ${CACHED_IP_TAGGED}"
    if [[ $CACHED_TOTAL -gt 0 ]]; then
      echo "- IP coverage: $((CACHED_IP_TAGGED * 100 / CACHED_TOTAL))%"
    fi
    echo "- IP Score distribution: HIGH=${CACHED_HIGH}, MEDIUM=${CACHED_MEDIUM}, LOW=${CACHED_LOW}"
    echo ""

    echo "## Contributors"
    # shellcheck disable=SC2086
    git shortlog -sne $filters 2>/dev/null || true
    echo ""

    echo "## File Change Frequency (Top 20, last ${MAX_COMMITS_FREQ} commits)"
    # shellcheck disable=SC2086
    git log --max-count="$MAX_COMMITS_FREQ" --name-only --format= $filters 2>/dev/null \
      | sort | uniq -c | sort -rn | head -20
    echo ""

    echo "## Recent Commits Without IP Tags (last 10)"
    # shellcheck disable=SC2086
    git log --max-count=10 --oneline --invert-grep --grep="\[HUMAN\]:" $filters 2>/dev/null || true
  } > "$OUTPUT_DIR/03-git-analysis.md"

  echo "  Git analysis written"

  # ── 5. CLAUDE.md history ──
  echo -e "${BLUE}[5/6]${NC} Extracting CLAUDE.md version history..."

  {
    echo "# CLAUDE.md Version History"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""
    echo "This file tracks changes to the AI control configuration."
    echo "Each change proves human architectural control over AI behavior."
    echo ""

    for claude_file in CLAUDE.md .claude.md; do
      local hist_count
      hist_count=$(git log --oneline -- "$claude_file" 2>/dev/null | wc -l | tr -d ' ')
      if [[ $hist_count -gt 0 ]]; then
        echo "## ${claude_file} (${hist_count} versions)"
        echo ""
        git log --format="### %h — %ai%n**Author:** %an%n**Message:** %s%n" -- "$claude_file" 2>/dev/null
      fi
    done
  } > "$OUTPUT_DIR/04-claude-md-history.md"

  echo "  CLAUDE.md history extracted"

  # ── 6. Generate report ──
  echo -e "${BLUE}[6/6]${NC} Generating evidence report..."

  generate_report

  echo ""
  echo -e "${GREEN}${BOLD}Evidence package complete: ${OUTPUT_DIR}/${NC}"
  echo ""
  echo "Contents:"
  ls -la "$OUTPUT_DIR/" | tail -n +2
  echo ""

  if [[ -d "$OUTPUT_DIR/docs" ]]; then
    echo "Documentation:"
    find "$OUTPUT_DIR/docs" -type f | sort
  fi
}

# ── Generate Report (uses cached stats) ──────────────────────

generate_report() {
  compute_stats  # No-op if already computed

  local report_file="$OUTPUT_DIR/00-EVIDENCE-REPORT.md"
  local has_architecture="Nein" has_adrs="Nein" has_specs="Nein"
  local has_diary="Nein" has_iplog="Nein" has_claude="Nein"

  file_exists_in_repo "${DOCS_DIR}/ARCHITECTURE.md" && has_architecture="Ja"
  ls "$GIT_ROOT/${DOCS_DIR}"/decisions/ADR-*.md &>/dev/null 2>&1 && has_adrs="Ja"
  for d in $SPEC_DIRS; do
    [[ -d "$GIT_ROOT/$d" ]] && ls "$GIT_ROOT/$d"/*.md &>/dev/null 2>&1 && has_specs="Ja"
  done
  file_exists_in_repo "${DOCS_DIR}/process/DEVELOPMENT-DIARY.md" && has_diary="Ja"
  [[ -d "$GIT_ROOT/${DOCS_DIR}/ip-log" ]] && ls "$GIT_ROOT/${DOCS_DIR}"/ip-log/*.md &>/dev/null 2>&1 && has_iplog="Ja"
  { file_exists_in_repo "CLAUDE.md" || file_exists_in_repo ".claude.md"; } && has_claude="Ja"

  local coverage=0
  [[ $CACHED_TOTAL -gt 0 ]] && coverage=$((CACHED_IP_TAGGED * 100 / CACHED_TOTAL))

  if [[ "$REPORT_LANG" == "EN" ]]; then
    _generate_report_en "$report_file" "$coverage" \
      "$has_architecture" "$has_adrs" "$has_specs" "$has_diary" "$has_iplog" "$has_claude"
  else
    _generate_report_de "$report_file" "$coverage" \
      "$has_architecture" "$has_adrs" "$has_specs" "$has_diary" "$has_iplog" "$has_claude"
  fi

  echo "  Report written: ${report_file}"
}

_generate_report_de() {
  local file="$1" coverage="$2"
  local arch="$3" adrs="$4" specs="$5" diary="$6" iplog="$7" claude="$8"

  # --- Build conditional Subsumtion blocks based on actual evidence ---
  local doc_count=0 found="" missing=""
  [[ "$arch" == "Ja" ]] && { doc_count=$((doc_count+1)); found="${found}ARCHITECTURE.md, "; } || missing="${missing}ARCHITECTURE.md, "
  [[ "$adrs" == "Ja" ]] && { doc_count=$((doc_count+1)); found="${found}ADRs, "; } || missing="${missing}ADRs, "
  [[ "$specs" == "Ja" ]] && { doc_count=$((doc_count+1)); found="${found}Feature-Spezifikationen, "; } || missing="${missing}Feature-Spezifikationen, "
  [[ "$diary" == "Ja" ]] && { doc_count=$((doc_count+1)); found="${found}Entwicklungstagebuch, "; } || missing="${missing}Entwicklungstagebuch, "
  [[ "$claude" == "Ja" ]] && { doc_count=$((doc_count+1)); found="${found}CLAUDE.md, "; } || missing="${missing}CLAUDE.md, "
  found="${found%, }"; missing="${missing%, }"

  # Stufe 1 Subsumtion
  local sub1
  if [[ $doc_count -eq 0 ]]; then
    sub1="**Subsumtion Stufe 1:** Keines der fünf Planungsdokumente liegt vor. Freie kreative Entscheidungen sind derzeit nur über die Commit-History (IP-Tags) nachweisbar. **Handlungsempfehlung:** Mindestens ARCHITECTURE.md und CLAUDE.md anlegen. Für Software gilt der niedrigere Schwellenwert des § 69a Abs. 3 UrhG."
  else
    sub1="**Subsumtion Stufe 1:** ${doc_count} von 5 Planungsdokumenten liegen vor (${found})."
    [[ -n "$missing" ]] && sub1="${sub1} Fehlend: ${missing}."
    if [[ "$arch" == "Ja" || "$adrs" == "Ja" ]]; then
      sub1="${sub1} Die vorhandenen Dokumente belegen Architekturentscheidungen mit Alternativenbewertung — dies erfüllt das Kriterium der \"freien kreativen Entscheidung\" (EuGH C-604/10)."
    fi
    [[ "$claude" == "Ja" ]] && sub1="${sub1} Die CLAUDE.md belegt menschliche Kontrolle über den Entwicklungsprozess."
    sub1="${sub1} Für Software gilt der niedrigere Schwellenwert des § 69a Abs. 3 UrhG."
  fi

  # Stufe 2 Subsumtion
  local sub2
  if [[ ${CACHED_IP_TAGGED} -eq 0 ]]; then
    sub2="**Subsumtion Stufe 2:** Keiner der ${CACHED_TOTAL} Commits enthält IP-Tags. Die Prägung des Outputs durch menschliche Entscheidungen ist auf Commit-Ebene nicht dokumentiert. **Handlungsempfehlung:** IP-Tags (\`[HUMAN]\`, \`[AI-ROLE]\`, \`[IP-SCORE]\`) in Commit-Messages aufnehmen."
  else
    sub2="**Subsumtion Stufe 2:** ${CACHED_IP_TAGGED} von ${CACHED_TOTAL} Commits (${coverage}%) enthalten IP-Tags, die pro Änderung dokumentieren, welche Designentscheidungen der Entwickler getroffen hat (\`[HUMAN]\`), wie KI eingesetzt wurde (\`[AI-ROLE]\`), und welche kreativen Entscheidungen den Output prägen (\`[CREATIVE-DECISIONS]\`)."
    if [[ ${CACHED_HIGH} -gt 0 ]]; then
      if [[ ${CACHED_HIGH} -eq 1 ]]; then
        sub2="${sub2} 1 Commit ist als HIGH klassifiziert — hier dominieren menschliche Entscheidungen den Output \"hinreichend objektiv und eindeutig identifizierbar\" (Leistner GRUR 2025, 1123, 1132)."
      else
        sub2="${sub2} ${CACHED_HIGH} Commits sind als HIGH klassifiziert — bei diesen dominieren menschliche Entscheidungen den Output \"hinreichend objektiv und eindeutig identifizierbar\" (Leistner GRUR 2025, 1123, 1132)."
      fi
    else
      sub2="${sub2} Kein Commit ist als HIGH klassifiziert — der Nachweis dominierender menschlicher Prägung steht noch aus (Leistner GRUR 2025, 1123, 1132)."
    fi
  fi

  # Stufe 3: dynamic mechanisms list
  local mechanisms="" mech_count=0
  if [[ "$claude" == "Ja" ]]; then
    mech_count=$((mech_count+1))
    mechanisms="${mechanisms}
${mech_count}. **CLAUDE.md als Steuerungsdatei:** Im Git-Repository versioniert, definiert Regeln und Einschränkungen für das KI-Werkzeug."
    mech_count=$((mech_count+1))
    mechanisms="${mechanisms}
${mech_count}. **Rückfragen-Pflicht:** Die CLAUDE.md verpflichtet das KI-Werkzeug, bei jeder Designentscheidung den Entwickler zu fragen."
  fi
  if [[ ${CACHED_IP_TAGGED} -gt 0 ]]; then
    mech_count=$((mech_count+1))
    mechanisms="${mechanisms}
${mech_count}. **IP-Tags in Commits:** \`[HUMAN]\`/\`[AI-ROLE]\`-Tags dokumentieren pro Commit die Rollenverteilung zwischen Mensch und KI."
  fi
  if [[ "$specs" == "Ja" ]]; then
    mech_count=$((mech_count+1))
    mechanisms="${mechanisms}
${mech_count}. **Spezifikationen vor Implementation:** Feature-Specs definieren die Lösung, bevor KI-Code generiert wird."
  fi

  local sub3_block
  if [[ $mech_count -eq 0 ]]; then
    sub3_block="Es liegen keine Nachweise für eine systematische menschliche Steuerung des KI-Einsatzes vor. **Handlungsempfehlung:** CLAUDE.md als Steuerungsdatei anlegen und IP-Tags in Commits verwenden.

**Subsumtion Stufe 3:** Ohne nachgewiesene Steuerungsmechanismen kann die KI nicht als \"Hilfsmittel unter menschlicher Kontrolle\" eingeordnet werden."
  else
    sub3_block="Die KI wurde als Werkzeug unter menschlicher Kontrolle eingesetzt:
${mechanisms}

**Subsumtion Stufe 3:** Die ${mech_count} genannten Mechanismen belegen, dass die KI auf dem Spektrum von Olbrich/Bongers/Pampel (GRUR 2022, 870) als \"Werkzeug unter menschlicher Kontrolle\" einzuordnen ist — vergleichbar einem Taschenrechner, nicht einem autonomen Schöpfungsinstrument."
  fi

  # Sammelwerk
  local sub_sammelwerk
  if [[ "$arch" == "Ja" ]]; then
    sub_sammelwerk="Selbst wenn einzelne Codeblöcke als reine KI-Outputs nicht individuell schutzfähig wären, kann deren architektonische Integration — die Auswahl, Anordnung und Kombination der Module — eigenständigen Sammelwerkschutz begründen. Die ARCHITECTURE.md dokumentiert diese Integrationsleistung."
  else
    sub_sammelwerk="Selbst wenn einzelne Codeblöcke als reine KI-Outputs nicht individuell schutzfähig wären, kann deren architektonische Integration — die Auswahl, Anordnung und Kombination der Module — eigenständigen Sammelwerkschutz begründen. **Hinweis:** Eine ARCHITECTURE.md, die diese Integrationsleistung dokumentiert, fehlt derzeit und würde dieses Argument erheblich stärken."
  fi

  cat > "$file" << REPORT_EOF
# Nachweis der persönlichen geistigen Schöpfung

**Projekt:** ${PROJECT_NAME}
**Erstellt:** $(date +%Y-%m-%d)
**Zeitraum:** ${SINCE_DATE:-Gesamte Projektlaufzeit} bis $(date +%Y-%m-%d)
${AUTHOR_FILTER:+**Autor:** ${AUTHOR_FILTER}}

---

## 1. Zusammenfassung

Dieses Dokument weist nach, dass das Projekt **${PROJECT_NAME}** unter maßgeblicher
menschlicher kreativer Leitung entstanden ist. KI-Werkzeuge wurden als Hilfsmittel
eingesetzt (§ 2 Abs. 2, § 69a Abs. 3 UrhG), die Architektur- und Designentscheidungen
stammen vom Entwickler.

**Prüfungsmaßstab:** AG München 142 C 9786/25 (13.02.2026), Leistner GRUR 2025, 1123,
BGH "Birkenstocksandale" GRUR 2025, 407.

## 2. Dreistufiger Schutzfähigkeitstest

### Stufe 1: Freie kreative Entscheidungen (EuGH C-604/10)

| Nachweis | Vorhanden | Fundstelle |
|----------|-----------|------------|
| Architektur-Dokument (ARCHITECTURE.md) | ${arch} | docs/ARCHITECTURE.md |
| Architecture Decision Records (ADRs) | ${adrs} | docs/decisions/ |
| Feature-Spezifikationen | ${specs} | docs/specs/ |
| Entwicklungstagebuch | ${diary} | docs/process/DEVELOPMENT-DIARY.md |
| KI-Steuerungsdatei (CLAUDE.md) | ${claude} | CLAUDE.md |

${sub1}

### Stufe 2: Identifizierbare Prägung (Leistner GRUR 2025, 1123)

| Metrik | Wert |
|--------|------|
| Commits gesamt | ${CACHED_TOTAL} |
| Commits mit IP-Dokumentation | ${CACHED_IP_TAGGED} (${coverage}%) |
| Davon HIGH (starke menschliche Prägung) | ${CACHED_HIGH} |
| Davon MEDIUM (erkennbare menschliche Prägung) | ${CACHED_MEDIUM} |
| Davon LOW (geringe menschliche Prägung) | ${CACHED_LOW} |

${sub2}

### Stufe 3: Hilfsmittel-Test (Olbrich/Bongers/Pampel GRUR 2022, 870)

${sub3_block}

### Ergänzend: Sammelwerkschutz (§§ 3, 4 UrhG)

${sub_sammelwerk}

## 3. Beweismittel-Übersicht

| # | Dokument | Beweiszweck |
|---|----------|-------------|
| 1 | ARCHITECTURE.md | Menschliche Systemarchitektur |
| 2 | ADRs (docs/decisions/) | Entscheidungen mit Alternativenbewertung |
| 3 | CLAUDE.md | KI-Kontrolle und -Konfiguration |
| 4 | Commit-History mit IP-Tags | Pro-Änderung-Dokumentation |
| 5 | Entwicklungstagebuch | Laufende kreative Entscheidungen |
| 6 | Feature-Spezifikationen | Vorab-Designentscheidungen |
| 7 | IP-Log | Monatliche Zusammenfassung |
| 8 | CLAUDE.md-Versionshistorie | Evolution der KI-Kontrolle |

## 4. Anhänge

- \`01-all-commits.txt\` — Commit-History (letzte ${MAX_COMMITS_DUMP})
- \`02-ip-tagged-commits.txt\` — Commits mit IP-Dokumentation
- \`03-git-analysis.md\` — Statistische Auswertung
- \`04-claude-md-history.md\` — Versionshistorie der KI-Steuerung
- \`docs/\` — Kopien aller relevanten Dokumentation

---

*Generiert mit IP-SHIELD Evidence Package Generator.*
*Dieses Dokument ersetzt keine Rechtsberatung.*
REPORT_EOF
}

_generate_report_en() {
  local file="$1" coverage="$2"
  local arch="$3" adrs="$4" specs="$5" diary="$6" iplog="$7" claude="$8"

  # --- Build conditional assessment blocks based on actual evidence ---
  local doc_count=0 found="" missing=""
  [[ "$arch" == "Ja" ]] && { doc_count=$((doc_count+1)); found="${found}ARCHITECTURE.md, "; } || missing="${missing}ARCHITECTURE.md, "
  [[ "$adrs" == "Ja" ]] && { doc_count=$((doc_count+1)); found="${found}ADRs, "; } || missing="${missing}ADRs, "
  [[ "$specs" == "Ja" ]] && { doc_count=$((doc_count+1)); found="${found}feature specifications, "; } || missing="${missing}feature specifications, "
  [[ "$diary" == "Ja" ]] && { doc_count=$((doc_count+1)); found="${found}development diary, "; } || missing="${missing}development diary, "
  [[ "$claude" == "Ja" ]] && { doc_count=$((doc_count+1)); found="${found}CLAUDE.md, "; } || missing="${missing}CLAUDE.md, "
  found="${found%, }"; missing="${missing%, }"

  # Stage 1 Assessment
  local sub1
  if [[ $doc_count -eq 0 ]]; then
    sub1="**Assessment Stage 1:** None of the five planning documents are present. Free creative choices can currently only be evidenced through the commit history (IP tags). **Recommendation:** Create at minimum ARCHITECTURE.md and CLAUDE.md. For software, the lower threshold of § 69a(3) UrhG applies."
  else
    sub1="**Assessment Stage 1:** ${doc_count} of 5 planning documents are present (${found})."
    [[ -n "$missing" ]] && sub1="${sub1} Missing: ${missing}."
    if [[ "$arch" == "Ja" || "$adrs" == "Ja" ]]; then
      sub1="${sub1} The existing documents record architecture decisions with alternatives analysis — satisfying the \"free creative choices\" criterion (CJEU C-604/10)."
    fi
    [[ "$claude" == "Ja" ]] && sub1="${sub1} CLAUDE.md evidences human control over the development process."
    sub1="${sub1} For software, the lower threshold of § 69a(3) UrhG applies."
  fi

  # Stage 2 Assessment
  local sub2
  if [[ ${CACHED_IP_TAGGED} -eq 0 ]]; then
    sub2="**Assessment Stage 2:** None of the ${CACHED_TOTAL} commits contain IP tags. The identifiable shaping of output through human decisions is not documented at commit level. **Recommendation:** Add IP tags (\`[HUMAN]\`, \`[AI-ROLE]\`, \`[IP-SCORE]\`) to commit messages."
  else
    sub2="**Assessment Stage 2:** ${CACHED_IP_TAGGED} of ${CACHED_TOTAL} commits (${coverage}%) contain IP tags documenting per-change design decisions (\`[HUMAN]\`), AI usage (\`[AI-ROLE]\`), and creative choices shaping the output (\`[CREATIVE-DECISIONS]\`)."
    if [[ ${CACHED_HIGH} -gt 0 ]]; then
      if [[ ${CACHED_HIGH} -eq 1 ]]; then
        sub2="${sub2} 1 commit is classified as HIGH — human decisions dominate the output \"sufficiently objectively and unambiguously identifiable\" (Leistner GRUR 2025, 1123, 1132)."
      else
        sub2="${sub2} ${CACHED_HIGH} commits are classified as HIGH — human decisions dominate the output \"sufficiently objectively and unambiguously identifiable\" (Leistner GRUR 2025, 1123, 1132)."
      fi
    else
      sub2="${sub2} No commits are classified as HIGH — evidence of dominant human shaping is still pending (Leistner GRUR 2025, 1123, 1132)."
    fi
  fi

  # Stage 3: dynamic mechanisms list
  local mechanisms="" mech_count=0
  if [[ "$claude" == "Ja" ]]; then
    mech_count=$((mech_count+1))
    mechanisms="${mechanisms}
${mech_count}. **CLAUDE.md as control file** — versioned in git, defines rules and constraints for the AI tool."
    mech_count=$((mech_count+1))
    mechanisms="${mechanisms}
${mech_count}. **Mandatory decision points** — CLAUDE.md requires the AI tool to ask the developer for design decisions."
  fi
  if [[ ${CACHED_IP_TAGGED} -gt 0 ]]; then
    mech_count=$((mech_count+1))
    mechanisms="${mechanisms}
${mech_count}. **IP tags in commits** — \`[HUMAN]\`/\`[AI-ROLE]\` tags document the human-AI role distribution per commit."
  fi
  if [[ "$specs" == "Ja" ]]; then
    mech_count=$((mech_count+1))
    mechanisms="${mechanisms}
${mech_count}. **Specifications before implementation** — feature specs define the solution before AI generates code."
  fi

  local sub3_block
  if [[ $mech_count -eq 0 ]]; then
    sub3_block="No evidence of systematic human control over AI usage is present. **Recommendation:** Create CLAUDE.md as control file and use IP tags in commits.

**Assessment Stage 3:** Without documented control mechanisms, the AI cannot be classified as a \"tool under human control\" on the Olbrich/Bongers/Pampel spectrum."
  else
    sub3_block="AI was used as a tool under human control:
${mechanisms}

**Assessment Stage 3:** These ${mech_count} mechanisms place the AI on the Olbrich/Bongers/Pampel spectrum (GRUR 2022, 870) as a \"tool under human control\" — comparable to a calculator, not an autonomous creative instrument."
  fi

  # Compilation protection
  local sub_sammelwerk
  if [[ "$arch" == "Ja" ]]; then
    sub_sammelwerk="Even if individual code blocks (as pure AI output) are not independently protectable, their architectural integration — the selection, arrangement, and combination of modules — can constitute protectable compilation rights. ARCHITECTURE.md documents this integration effort."
  else
    sub_sammelwerk="Even if individual code blocks (as pure AI output) are not independently protectable, their architectural integration — the selection, arrangement, and combination of modules — can constitute protectable compilation rights. **Note:** An ARCHITECTURE.md documenting this integration effort is currently missing and would significantly strengthen this argument."
  fi

  cat > "$file" << REPORT_EOF
# Evidence of Human Creative Contribution

**Project:** ${PROJECT_NAME}
**Generated:** $(date +%Y-%m-%d)
**Period:** ${SINCE_DATE:-Full project history} to $(date +%Y-%m-%d)
${AUTHOR_FILTER:+**Author:** ${AUTHOR_FILTER}}

---

## 1. Summary

This document demonstrates that the project **${PROJECT_NAME}** was created under
substantial human creative direction. AI tools were used as assistive tools
(German: "Hilfsmittel"), while architecture and design decisions originate from
the developer.

**Legal framework:** AG München 142 C 9786/25 (Feb 13, 2026), applying German
copyright law (§ 2(2), § 69a(3) UrhG) and EU case law (CJEU C-604/10).

## 2. Three-Stage Copyrightability Test

### Stage 1: Free Creative Choices (CJEU C-604/10)

| Evidence | Present | Location |
|----------|---------|----------|
| Architecture document (ARCHITECTURE.md) | ${arch} | docs/ARCHITECTURE.md |
| Architecture Decision Records (ADRs) | ${adrs} | docs/decisions/ |
| Feature specifications | ${specs} | docs/specs/ |
| Development diary | ${diary} | docs/process/DEVELOPMENT-DIARY.md |
| AI control file (CLAUDE.md) | ${claude} | CLAUDE.md |

${sub1}

### Stage 2: Identifiable Shaping of Output (Leistner GRUR 2025, 1123)

| Metric | Value |
|--------|-------|
| Total commits | ${CACHED_TOTAL} |
| Commits with IP documentation | ${CACHED_IP_TAGGED} (${coverage}%) |
| HIGH (strong human shaping) | ${CACHED_HIGH} |
| MEDIUM (recognizable human shaping) | ${CACHED_MEDIUM} |
| LOW (minimal human shaping) | ${CACHED_LOW} |

${sub2}

### Stage 3: Tool Test (Olbrich/Bongers/Pampel GRUR 2022, 870)

${sub3_block}

### Additionally: Compilation Protection (§§ 3, 4 UrhG)

${sub_sammelwerk}

## 3. Evidence Index

| # | Document | Purpose |
|---|----------|---------|
| 1 | ARCHITECTURE.md | Human system architecture |
| 2 | ADRs | Decisions with alternatives analysis |
| 3 | CLAUDE.md | AI control and configuration |
| 4 | Commit history with IP tags | Per-change documentation |
| 5 | Development diary | Ongoing creative decisions |
| 6 | Feature specifications | Pre-implementation design |
| 7 | IP log | Monthly summary |
| 8 | CLAUDE.md version history | Evolution of AI control |

## 4. Attachments

- \`01-all-commits.txt\` — Commit history (last ${MAX_COMMITS_DUMP})
- \`02-ip-tagged-commits.txt\` — IP-documented commits
- \`03-git-analysis.md\` — Statistical analysis
- \`04-claude-md-history.md\` — AI control file version history
- \`docs/\` — Copies of all relevant documentation

---

*Generated with IP-SHIELD Evidence Package Generator.*
*This document does not constitute legal advice.*
REPORT_EOF
}

# ── Mode: Report Only ────────────────────────────────────────

run_report() {
  echo -e "${BOLD}${CYAN}IP-SHIELD: Evidence Report${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  mkdir -p "$OUTPUT_DIR"
  generate_report
  echo ""
  echo -e "${GREEN}Report: ${OUTPUT_DIR}/00-EVIDENCE-REPORT.md${NC}"
}

# ── Main ─────────────────────────────────────────────────────

case "$MODE" in
  feedback) run_feedback ;;
  report)   run_report ;;
  full)     run_full ;;
esac
