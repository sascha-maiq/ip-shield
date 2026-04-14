#!/usr/bin/env bash
# ============================================================
# IP-SHIELD: Installer
# ============================================================
# Sets up IP documentation framework in any project.
#
# Usage:
#   ./install.sh /path/to/project
#   ./install.sh .                    # Current directory
#   ./install.sh /path --docs-dir src/docs  # Custom docs location
#   ./install.sh /path --lang EN      # Default language
# ============================================================

set -euo pipefail

# ── Colors ───────────────────────────────────────────────────

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ── Configuration ────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=""
DOCS_DIR="docs"
DEFAULT_LANG="DE"

# ── Parse arguments ──────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case $1 in
    --docs-dir)  DOCS_DIR="$2"; shift 2 ;;
    --lang)      DEFAULT_LANG="$2"; shift 2 ;;
    --help|-h)
      echo "IP-SHIELD Installer"
      echo ""
      echo "Usage: $0 TARGET_DIR [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --docs-dir DIR  Documentation directory (default: docs)"
      echo "  --lang LANG     Default language: DE or EN (default: DE)"
      echo "  --help          Show this help"
      exit 0
      ;;
    *)
      if [[ -z "$TARGET_DIR" ]]; then
        TARGET_DIR="$1"
      else
        echo -e "${RED}Unknown option: $1${NC}"
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ -z "$TARGET_DIR" ]]; then
  echo -e "${RED}Usage: $0 TARGET_DIR [OPTIONS]${NC}"
  echo "Run '$0 --help' for details."
  exit 1
fi

# Resolve to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
  echo -e "${RED}Directory not found: $1${NC}"
  exit 1
}

# ── Verify git repository ───────────────────────────────────

if ! git -C "$TARGET_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
  echo -e "${YELLOW}Warning: ${TARGET_DIR} is not a git repository.${NC}"
  echo "IP-Shield works best with git. Initialize with: git init"
  echo ""
  read -p "Continue anyway? (y/N) " -n 1 -r
  echo ""
  [[ $REPLY =~ ^[Yy]$ ]] || exit 0
fi

# ── Install ──────────────────────────────────────────────────

echo -e "${BOLD}${BLUE}IP-SHIELD Installer${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Target:   ${BOLD}${TARGET_DIR}${NC}"
echo -e "Docs dir: ${DOCS_DIR}"
echo -e "Language: ${DEFAULT_LANG}"
echo ""

# 1. Create directory structure
echo -e "${BLUE}[1/5]${NC} Creating directory structure..."

mkdir -p "$TARGET_DIR/${DOCS_DIR}/specs"
mkdir -p "$TARGET_DIR/${DOCS_DIR}/decisions"
mkdir -p "$TARGET_DIR/${DOCS_DIR}/ip-log"
mkdir -p "$TARGET_DIR/${DOCS_DIR}/reviews"
mkdir -p "$TARGET_DIR/${DOCS_DIR}/process"

echo "  Created ${DOCS_DIR}/{specs,decisions,ip-log,reviews,process}"

# 2. Copy templates
echo -e "${BLUE}[2/5]${NC} Copying templates..."

copy_if_missing() {
  local src="$1" dest="$2" name="$3"
  if [[ -f "$dest" ]]; then
    echo -e "  ${YELLOW}Skipped${NC} ${name} (already exists)"
  else
    cp "$src" "$dest"
    echo -e "  ${GREEN}Copied${NC} ${name}"
  fi
}

copy_if_missing "$SCRIPT_DIR/ARCHITECTURE.md" "$TARGET_DIR/${DOCS_DIR}/ARCHITECTURE.md" "ARCHITECTURE.md"
copy_if_missing "$SCRIPT_DIR/ADR-TEMPLATE.md" "$TARGET_DIR/${DOCS_DIR}/decisions/ADR-TEMPLATE.md" "ADR-TEMPLATE.md"
copy_if_missing "$SCRIPT_DIR/FEATURE-SPEC.md" "$TARGET_DIR/${DOCS_DIR}/specs/FEATURE-SPEC-TEMPLATE.md" "FEATURE-SPEC-TEMPLATE.md"
copy_if_missing "$SCRIPT_DIR/ip-validator.md" "$TARGET_DIR/${DOCS_DIR}/process/ip-validator.md" "ip-validator.md"

# Copy and make executable
if [[ -f "$TARGET_DIR/${DOCS_DIR}/process/ip-evidence.sh" ]]; then
  echo -e "  ${YELLOW}Skipped${NC} ip-evidence.sh (already exists)"
else
  cp "$SCRIPT_DIR/ip-evidence.sh" "$TARGET_DIR/${DOCS_DIR}/process/ip-evidence.sh"
  chmod +x "$TARGET_DIR/${DOCS_DIR}/process/ip-evidence.sh"
  echo -e "  ${GREEN}Copied${NC} ip-evidence.sh"
fi

# 3. Git hook
echo -e "${BLUE}[3/5]${NC} Installing Git hook..."

GIT_DIR="$TARGET_DIR/.git"
if [[ -d "$GIT_DIR" ]]; then
  mkdir -p "$GIT_DIR/hooks"
  if [[ -f "$GIT_DIR/hooks/prepare-commit-msg" ]]; then
    echo -e "  ${YELLOW}Skipped${NC} prepare-commit-msg hook (already exists)"
    echo "  To replace: cp ${SCRIPT_DIR}/prepare-commit-msg ${GIT_DIR}/hooks/"
  else
    cp "$SCRIPT_DIR/prepare-commit-msg" "$GIT_DIR/hooks/prepare-commit-msg"
    chmod +x "$GIT_DIR/hooks/prepare-commit-msg"
    echo -e "  ${GREEN}Installed${NC} prepare-commit-msg hook"
  fi
else
  echo -e "  ${YELLOW}Skipped${NC} (no .git directory)"
fi

# 4. CLAUDE.md
echo -e "${BLUE}[4/5]${NC} Checking CLAUDE.md..."

CLAUDE_FILE="$TARGET_DIR/CLAUDE.md"
if [[ -f "$CLAUDE_FILE" ]]; then
  if grep -q "IP Documentation Rules" "$CLAUDE_FILE"; then
    echo -e "  ${GREEN}✓${NC} CLAUDE.md already has IP Documentation Rules"
  else
    echo -e "  ${YELLOW}Action needed:${NC} Add IP rules to your CLAUDE.md"
    echo "  Copy the content of CLAUDE_MD_IP_SECTION.md to the end of:"
    echo "  ${CLAUDE_FILE}"
  fi
else
  echo -e "  ${YELLOW}Action needed:${NC} Create CLAUDE.md with IP rules"
  echo "  cp ${SCRIPT_DIR}/CLAUDE_MD_IP_SECTION.md ${CLAUDE_FILE}"
fi

# 5. Summary
echo -e "${BLUE}[5/5]${NC} Writing environment config..."

# Write a small config file for ip-evidence.sh defaults
CONFIG_FILE="$TARGET_DIR/${DOCS_DIR}/process/.ip-shield-config"
cat > "$CONFIG_FILE" << EOF
# IP-SHIELD Configuration
# Generated: $(date +%Y-%m-%d)
IP_SHIELD_LANG=${DEFAULT_LANG}
IP_SHIELD_DOCS_DIR=${DOCS_DIR}
EOF
echo -e "  ${GREEN}Written${NC} .ip-shield-config"

echo ""
echo -e "${GREEN}${BOLD}IP-SHIELD installed successfully!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BOLD}Next steps:${NC}"
echo ""
echo "1. ${BOLD}Fill in ARCHITECTURE.md${NC} with your actual design decisions"
echo "   This is your most important IP document."
echo "   → ${TARGET_DIR}/${DOCS_DIR}/ARCHITECTURE.md"
echo ""
echo "2. ${BOLD}Add IP rules to CLAUDE.md${NC} (if not done above)"
echo "   → Copy content from: ${SCRIPT_DIR}/CLAUDE_MD_IP_SECTION.md"
echo ""
echo "3. ${BOLD}Start working${NC} — Claude will automatically:"
echo "   - Ask you for design decisions (Rückfragen-Pflicht)"
echo "   - Write IP-tagged commit messages"
echo "   - Update IP log and development diary"
echo ""
echo "4. ${BOLD}After your first commits${NC}, run:"
echo "   ${TARGET_DIR}/${DOCS_DIR}/process/ip-evidence.sh --feedback"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
