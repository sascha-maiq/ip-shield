# ============================================================
# IP-SHIELD: Urheberrechtliche Dokumentation für KI-gestützten Code
# ============================================================
# Füge diesen Abschnitt in deine CLAUDE.md ein (Projekt-Root).
# Basiert auf: AG München 142 C 9786/25 (13.02.2026),
# Leistner GRUR 2025, 1123; Olbrich/Bongers/Pampel GRUR 2022, 870;
# Ory/Sorge NJW 2019, 710; EuGH C-604/10, C-683/17;
# BGH "Birkenstocksandale" GRUR 2025, 407
# ============================================================

## IP Documentation Rules

### Core Principle

German copyright law protects "persönliche geistige Schöpfungen" (§ 2 Abs. 2 UrhG).
For AI-assisted code, the developer must prove that human creative decisions
**dominate** the output ("Dominanztest", Leistner GRUR 2025, 1123, 1132):

> "Der Input muss den Output hinreichend objektiv und eindeutig identifizierbar prägen."

The burden of proof lies with the developer (BGH "Birkenstocksandale", GRUR 2025, 407).
Without documentation, the work risks being treated as unprotectable.

**Key paradigm: Claude writes the documentation, human makes the decisions.**
Writing documentation is not creative work — making design decisions is.
Claude captures decisions automatically from the conversation and commit context.
The human reviews, corrects, and approves.

### The "Designer Brief" Problem (AG München Rn. 22-24)

The court rejected a 1,700-character prompt as insufficient because it read like
a **briefing to a designer**, not creative work:

> "Erstelle ein originelles, abstraktes Logo" ≠ Schöpfung
> "Verwende eine asymmetrische Komposition mit 3 überlappenden Kreisen,
>  Farbverlauf von #2D5BFF nach #00D4AA, wobei der obere Kreis das
>  Datenmodell symbolisiert..." = Mögliche Schöpfung

**For code:** A prompt like "implement user authentication" is a brief.
Specifying the session management strategy, token rotation policy,
and multi-tenant isolation pattern **with reasoning** is creative work.

### What Constitutes Human Creative Contribution

**PROTECTABLE** (document these — they survive the three-stage test):
- **Architecture decisions**: System design, module structure, data flow WITH alternatives considered
- **Algorithm design**: Choosing approaches WITH reasoning, not just "use binary search"
- **Data modeling**: Entity relationships, schema decisions, normalization choices WITH trade-off analysis
- **API design**: Endpoint structure, error handling strategy, authentication patterns
- **Integration design**: How components connect, orchestration patterns, fallback strategies
- **Specification writing**: Detailed technical specs that constrain the implementation
- **Substantive review**: Modifications to AI output WITH design reasoning (not just bug fixes)
- **Creative problem-solving**: Novel solutions to technical challenges

**NOT PROTECTABLE** (don't overclaim — weakens the overall case):
- Boilerplate code, standard CRUD operations
- Mechanically following framework conventions
- Direct AI output accepted without substantive modification
- Trivial bug fixes, typo corrections ("handwerkliche Korrekturen", AG München Rn. 24)
- Generic instructions: "make it responsive", "add error handling", "optimize performance"

### MANDATORY: Human Decision Points (Rückfragen-Pflicht)

**Claude Code MUST actively ask the developer for decisions at every stage.**
The goal: the final result is the developer's "persönliche geistige Schöpfung"
— not AI output that was merely accepted.

**Before starting any new topic/feature/task, Claude MUST:**

1. **Present alternatives**: "I see options A, B, C — which direction and why?"
   Always present at least 2 substantively different approaches for non-trivial
   decisions. The developer's selection from alternatives is a protectable
   creative act (AG München Rn. 19: "Selektionsprozess"; Dreyer HK-UrhR § 2 Rn. 32).
2. **Ask about design**: "Key decisions needed: X, Y, Z — your call."
3. **Ask about trade-offs**: "This means X but costs Y — acceptable?"
4. **Ask during implementation**: "About to do X — confirm or different approach?"
5. **Ask during review**: "Here's what changed — modifications needed?"

**Golden rule:** If a decision could reasonably go two or more ways,
ASK the developer. Their choice is what makes the output protectable.

**Don't ask about:** Formatting, variable naming, import order, linter fixes,
standard framework conventions, trivial bug fixes. These are "handwerkliche
Korrekturen" (AG München Rn. 24) — documenting them as design decisions
weakens the overall evidence by diluting genuine creative choices.

**Document the answers:** Every developer decision becomes part of the
commit message, IP log, and development diary — automatically by Claude.

### Commit Message Format

Claude Code writes commit messages automatically. The developer reviews and approves.
Every commit MUST follow this structure:

```
<type>(<scope>): <short description>

[HUMAN]: <developer's creative decisions — 20-40 words for HIGH/MEDIUM>
[AI-ROLE]: <how AI was used — tool, not creator>
[CREATIVE-DECISIONS]: <specific design choices with reasoning>
[IP-SCORE]: HIGH | MEDIUM | LOW

Recommended (for MEDIUM and HIGH commits):
[ALTERNATIVES-REJECTED]: <what was considered and why rejected — documents selection process>

Optional (for HIGH-IP commits):
[SPEC-REF]: <link to spec/ADR that drove this change>
[REVIEW-NOTES]: <substantive modifications to AI output with reasoning>

Co-Authored-By: <AI model> <noreply@provider.com>
```

**[HUMAN] tag requirements (legally critical):**

The [HUMAN] tag is the primary evidence under the Dominanztest. It MUST:

1. **≥40 words for HIGH commits, ≥30 words for MEDIUM commits**
2. **Follow the REQUIREMENT → RESEARCH → DECISION chain** (condensed):
   - **REQUIREMENT** — what triggered the investigation (legal requirement, user need, DP feedback, architectural constraint)
   - **RESEARCH** — what was evaluated ("Evaluated X vs Y vs Z against [criteria]") — proof that research happened, not the full research itself
   - **DECISION** — what was chosen and why alternatives were rejected
3. **Name at least one rejected alternative** — the *Selektionsprozess* (AG München Rn. 19) is the strongest single indicator of protectable contribution. No alternative documented = no selection = no protection.
4. **State the reasoning** — why this option. Domain knowledge applied to a decision (compliance requirement, architectural constraint, UX principle) is protectable; generic approval is not.
5. **Use active verb form**:
   - "Chose X over Y because..." ✅
   - "Rejected X — would cause..." ✅
   - "Designed X to comply with §203..." ✅
   - "Resolved tension between X and Y by..." ✅
   - "Approved X" ❌ (no alternative, no reasoning)
   - "Direction: X" ❌ (passive, tells court nothing)

**For commits building from an approved spec where no new decisions were made:**
```
[HUMAN]: Implemented per SPEC-X §Y. Delta-decisions: [any implementation-time
decisions not covered by spec, or "none — spec fully determined implementation"].
```
This is honest and legally accurate — the spec carries the IP weight.
The ≥30/40 word minimum is waived when [SPEC-REF] points to a spec that
contains a Decision Log (see Decision Log section below).

**Formatting rule:** Separate tag blocks with **blank lines**. `ip-evidence.sh`
uses blank lines as block delimiters — a tag block ends at the next `[TAG]:`
marker OR the next blank line. Do NOT use blank lines within a tag block;
multiline content within a tag must be continuous (no empty lines).

**Example (HIGH — protectable, ≥40 words with REQUIREMENT→RESEARCH→DECISION chain):**
```
feat(search): implement trademark similarity scoring

[HUMAN]: Registry opposition guidelines require multi-dimensional
similarity scoring for trademark pre-search [REQUIREMENT]. Evaluated
three approaches: pure string distance, phonetic-only, and composite
scoring with configurable weights — assessed against target-language
name phonetics, registry API rate limits, and user review ergonomics
[RESEARCH]. Chose composite scoring with string similarity 40% +
phonetic matching 35% + semantic similarity 25%. Rejected pure string
distance (misses phonetic similarities critical in trademark
opposition). Rejected phonetic-only (misses orthographic variants).
Selected adaptive TTL caching over fixed TTL after registry
rate-limit analysis showed sliding-window enforcement [DECISION].
[AI-ROLE]: Claude Code generated implementation from detailed spec.
Human reviewed, redesigned retry logic from exponential to adaptive
backoff, added circuit breaker.
[CREATIVE-DECISIONS]: Weight factors (40/35/25), phonetic over pure
string matching, adaptive TTL over fixed, circuit breaker (3/60s)
[IP-SCORE]: HIGH
[SPEC-REF]: docs/specs/trademark-search.md (Decision Log D-1 to D-4)
[REVIEW-NOTES]: Rewrote retry logic — exponential backoff doesn't
account for the registry's sliding window rate limit.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

**Example (MEDIUM — building from spec, ≥30 words):**
```
feat(PROJ-123): wire enrichment workflow from intake handler

[HUMAN]: Per SPEC-INTAKE §5.1, intake handlers must route
mandate-intent emails through the enrichment workflow [REQUIREMENT].
Spec defined the routing logic but not the input contract —
discovered the enrichment step expects { traceId, inputObject }
wrapper during implementation [RESEARCH]. Added input shaper node as
bridge. Rejected direct passthrough — would cause null extractions
in the enrichment parser [DECISION].
[AI-ROLE]: Structural wiring, passthrough bug discovery, deployment
[CREATIVE-DECISIONS]: Input shaper added (not in original spec),
passthrough fix for trigger/input field forwarding
[IP-SCORE]: MEDIUM
[SPEC-REF]: docs/specs/SPEC-INTAKE-API-CONTRACT.md §5.1

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

**Example (MEDIUM — building from spec, no delta-decisions):**
```
feat(PROJ-123): implement conflict check handler per spec

[HUMAN]: Implemented per SPEC-INTAKE §5.2. No delta-decisions — spec
fully determined the handler logic, routing, and database query pattern.
[AI-ROLE]: Code generation from spec, structural wiring
[CREATIVE-DECISIONS]: none beyond spec — see SPEC-INTAKE Decision Log D-1 to D-4
[IP-SCORE]: MEDIUM
[SPEC-REF]: docs/specs/SPEC-INTAKE-API-CONTRACT.md §5.2

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

**Example (LOW — mark honestly):**
```
chore(deps): update dependencies and fix lint errors

[HUMAN]: Reviewed dependency updates for breaking changes
[AI-ROLE]: Claude Code ran updates and fixed lint errors
[CREATIVE-DECISIONS]: none — routine maintenance
[IP-SCORE]: LOW

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

**Note on `Co-Authored-By`:** This header follows GitHub convention for
transparency. It does NOT establish co-authorship under § 8 UrhG — AI cannot
be an author (§ 7 UrhG: only natural persons). The header documents tool usage,
not creative co-contribution.

### Decision Log in Specs (IP Evidence Chain)

Every spec (SPEC-*.md) and ADR should contain a **Decision Log** section.
This is where the full REQUIREMENT→RESEARCH→DECISION chain lives in detail.
Commits then reference specific Decision Log entries (e.g., "see Decision Log D-3").

**Template:**
```markdown
## Decision Log

| ID | Requirement | Options Evaluated | Decision | Reasoning |
|----|------------|-------------------|----------|-----------|
| D-1 | §203 requires encrypted client storage | (a) storage + CSE, (b) database native, (c) separate store | (a) storage + CSE | Native doesn't cover backups; (c) adds ops overhead without security uplift |
| D-2 | Design partner feedback: email taxonomy (session 2026-03-16) | (a) flat tags, (b) hierarchical, (c) intent-based | (c) intent-based | Matches attorney mental model; flat tags don't capture urgency dimension |
| D-3 | Multi-tenant isolation for playbook config | (a) per-org container, (b) shared container + partition key | (b) shared + partition | Consistent with existing document database pattern; per-org would require excessive resource overhead |
```

**Rules for the Decision Log:**
- **ID** — sequential per spec (D-1, D-2, ...). Commits reference these: `[SPEC-REF]: SPEC-X Decision Log D-1 to D-3`
- **Requirement** — what triggered the investigation: legal requirement, user need, DP feedback (with date/name), architectural constraint, performance requirement
- **Options Evaluated** — minimum 2 substantive alternatives. This is the Selektionsprozess (AG München Rn. 19). One option is not a choice.
- **Decision** — what was chosen
- **Reasoning** — why this option, with domain knowledge. "Best practice" is not reasoning. "§203 mandates..." or "the design partner's workflow shows..." is.

**When the Decision Log carries the IP weight:**
If a spec has a substantive Decision Log (≥2 entries with real alternatives),
commits implementing that spec can use the shorter [HUMAN] tag format
(referencing the Decision Log entries) without meeting the 30/40-word minimum.
The spec IS the creative pre-work; the commit documents execution + deltas.

**What about research prompts?**
Prompts directing research (e.g., "research German Fristen rules for Berufung")
are legally classified as "Auftrag an einen Designer" (AG München Rn. 22) —
they are NOT the protectable creative work. What IS protectable is the
**decision extracted from the research**: which option was chosen and why.
The spec's Decision Log captures this. Raw prompts do not need to be preserved,
but the decisions they led to must be documented.

### Automatic Documentation (Claude's Responsibilities)

**Before each commit, Claude Code MUST automatically:**

1. **Write the commit message** with all IP tags based on the conversation context.
   Don't ask the developer to fill in tags manually — extract decisions from the session.

2. **Update the IP log** (`docs/ip-log/YYYY-MM.md`) with a dated entry:
   ```markdown
   ## YYYY-MM-DD — <feature/component>
   - **Human contributions:** [extracted from conversation]
   - **AI role:** [what Claude did]
   - **Key creative decisions:** [with reasoning]
   - **Files affected:** [list]
   - **Estimated IP score:** HIGH | MEDIUM | LOW
   ```

3. **Check for planning docs**: For HIGH-IP work, verify specs/ADRs exist.
   If not, offer to draft one from the conversation for developer approval.

4. **Flag low-IP work**: If a commit is predominantly AI-generated with
   minimal human creative input, mark honestly as LOW and note:
   `This commit has limited human creative contribution.
   Consider: What design decisions did YOU make? Document them.`

5. **Update ARCHITECTURE.md** when architecture changes — draft the update,
   developer reviews.

6. **Update Development Diary** after each feature/topic session —
   draft the entry from conversation context, developer approves.

### Session Protocol: Development Diary

At the **end of each development session** (new feature, architecture change,
significant refactoring), Claude MUST draft a diary entry:

```markdown
## YYYY-MM-DD — <Topic>
**Developer:** <name>
**Context:** <what triggered this work>
**Decision timeline:**
- HH:MM — <design decision with reasoning>
- HH:MM — <selection from alternatives with reasoning>
- HH:MM — <review modification with reasoning>
**AI usage:** <how AI assisted — tool, not creator>
**What I changed from AI suggestions:** <substantive modifications>
```

The developer reviews and commits this. The diary is cumulative evidence
of ongoing human creative control over the project.

### File Structure for IP Documentation

```
docs/
├── ARCHITECTURE.md          # System design decisions (CRITICAL for IP)
├── specs/                   # Technical specifications (human-directed)
│   └── <feature>.md
├── decisions/               # Architecture Decision Records (ADRs)
│   ├── ADR-NNN-<title>.md
│   └── ADR-TEMPLATE.md
├── ip-log/                  # Monthly IP documentation log
│   └── YYYY-MM.md
├── reviews/                 # Code review notes with reasoning
│   └── <date>-<feature>.md
└── process/
    ├── DEVELOPMENT-DIARY.md # Running diary of human decisions
    ├── ip-validator.md      # Copyright validator prompt
    └── prepare-commit-msg   # Git hook for IP tags
```

### Pre-Commit Checklist (Claude verifies automatically)

Before finalizing any commit, Claude checks:
- [ ] Commit message includes [HUMAN], [AI-ROLE], [IP-SCORE] tags
- [ ] [HUMAN] tag: HIGH ≥40 words, MEDIUM ≥30 words (waived if spec has Decision Log)
- [ ] [HUMAN] tag follows REQUIREMENT → RESEARCH → DECISION chain
- [ ] [HUMAN] tag contains at least one rejected alternative and the reasoning
- [ ] [CREATIVE-DECISIONS] lists specific choices (not generic descriptions)
- [ ] If IP-SCORE is HIGH: spec or ADR with Decision Log exists or is being created
- [ ] If architecture changed: ARCHITECTURE.md update included
- [ ] Monthly IP log entry drafted for today's work
- [ ] No false IP claims (don't mark boilerplate as HIGH)
- [ ] Co-Authored-By header present when AI assisted

### Three-Stage Copyrightability Test

Every significant commit is measured against:

| # | Test | Source | Question |
|---|------|--------|----------|
| 1 | **Freie kreative Entscheidungen** | EuGH C-604/10, C-683/17 | Did the developer make free creative choices with alternatives? |
| 2 | **Identifizierbare Prägung** | Leistner GRUR 2025, 1123 | Do these choices visibly shape the output (not just the idea)? |
| 3 | **Hilfsmittel-Test** | Olbrich/Bongers/Pampel GRUR 2022 | Was AI a tool under human control, not an autonomous creator? |

**All three YES = protectable. Any NO = risk.**

**Software threshold (§ 69a Abs. 3 UrhG):** For computer programs, the lower
standard of "eigene geistige Schöpfung" applies — no classical "Schöpfungshöhe"
required. Architecture decisions that wouldn't suffice for a logo may well
suffice for code (cf. OLG Köln 6 U 243/18).

**Fallback: Compilation/Arrangement Protection (§§ 3, 4 UrhG)**

Even if individual code blocks (as pure AI output) are not independently
protectable, their architectural integration — the selection, arrangement,
and combination of modules — can constitute a protectable compilation
(§ 4 UrhG) or adaptation (§ 3 UrhG). This is the strongest argument
when most code is AI-generated but integration is human-designed.
ARCHITECTURE.md is the key evidence for this argument.

### Evidence Hierarchy (Beweislast, BGH "Birkenstocksandale")

If challenged, the three-stage escalation applies:

1. **§ 10 UrhG presumption**: Developer named in source → presumed author
2. **Substantiated challenge**: Opponent claims AI-generated → developer must show creative process
3. **Full disclosure**: Court demands complete evidence of human creative contribution

**What survives escalation (strongest to weakest):**
- CLAUDE.md + ARCHITECTURE.md in git history (proves architectural control)
- Specs and ADRs with alternatives analysis (proves design decisions)
- Commit messages with detailed [HUMAN] tags (proves per-change contribution)
- Development diary entries (proves ongoing creative engagement)
- IP log (proves awareness and documentation discipline)
- Chat transcripts / session logs (proves actual decision-making process)

### Legal Basis Quick Reference

| Requirement | Source | Practical Meaning |
|---|---|---|
| "persönliche geistige Schöpfung" | § 2 Abs. 2 UrhG | Human must CREATE, not just prompt |
| "eigene geistige Schöpfung" (Software) | § 69a Abs. 3 UrhG | Lower bar for code, but still requires human origin |
| Dominanztest | Leistner GRUR 2025, 1123, 1132 | Human creative elements must DOMINATE the output |
| "Hilfsmittel, nicht Schöpfungsinstrument" | Olbrich/Bongers/Pampel GRUR 2022, 870 | AI = tool under human control |
| Beweislast beim Anspruchsteller | AG München Rn. 23; BGH "Birkenstocksandale" | YOU must prove your creative contribution |
| "freie kreative Entscheidungen" | EuGH C-604/10, C-683/17 | Choices must reflect personality, not generic instructions |
| "Auftrag an einen Designer" ≠ Schöpfung | AG München Rn. 22 | A brief/prompt is not creative work; the design decisions are |
| Niedrigerer Schwellenwert für Software | § 69a Abs. 3 UrhG; OLG Köln 6 U 243/18 | "Eigene geistige Schöpfung" suffices — no classical "Schöpfungshöhe" |
| Sammelwerkschutz | §§ 3, 4 UrhG | Selection and arrangement of elements protectable even if parts aren't |
| Selektionsprozess | AG München Rn. 19; Dreyer HK-UrhR § 2 Rn. 32 | Selecting from AI alternatives based on expert judgment is creative work |
