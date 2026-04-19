# Decision Log Template for Specs

Add this section to every SPEC-*.md and ADR document.
Commits reference Decision Log entries by ID (e.g., `[SPEC-REF]: SPEC-X Decision Log D-1 to D-3`).

---

## Decision Log

| ID | Requirement | Options Evaluated | Decision | Reasoning | Shapes |
|----|------------|-------------------|----------|-----------|--------|
| D-1 | _What triggered this_ | _(a) option, (b) option, (c) option_ | _(b)_ | _Why (b), why not (a)/(c)_ | _File/module/schema shaped_ |

### Column Guide

**ID** — Sequential per spec: D-1, D-2, ... Commits reference these.

**Requirement** — What triggered the investigation. Be specific:
- Legal: "§203 StGB requires encrypted client data at rest"
- User need: "Users need per-client email tone (design partner session 2026-03-16)"
- Architectural: "Database document size limit requires split strategy"
- Design partner feedback: "Legacy system import must not overwrite manual edits"
- Performance: "External API rate limit requires caching"

**Options Evaluated** — Minimum 2 substantive alternatives. The Selektionsprozess
(AG Munchen Rn. 19) requires documented choice from alternatives.
One option is not a choice. Name the options concretely.

**Decision** — What was chosen. Reference the option letter.

**Reasoning** — Why this option, why NOT the others. Must include domain knowledge:
- "§203 mandates..." not "best practice"
- "The design partner's workflow shows..." not "users prefer"
- "Database partition strategy requires..." not "it's better"

Per OLG Düsseldorf 20 W 2/26 (2 Apr 2026), selection alone is insufficient
("Die bloße Auswahl eines KI-Erzeugnisses aus mehreren Vorschlägen ist für
sich genommen nicht ausreichend"). The Reasoning must show the "menschlich-
schöpferische Einflussnahme auf die Gestaltung des konkreten Werkes".

**Shapes** — Which concrete artifact does this decision shape? Name the
file(s), module(s), schema field(s), workflow IDs, or API endpoints the
decision visibly prägt. Examples:
- "src/auth/session-manager.ts + token-rotation.ts; Redis key layout"
- "OpenAPI /kyc endpoint: request.idDocument, response.riskScore"
- "documents container schema: version (int), milestoneTag (enum)"

This column maps the Decision to the concrete *konkretes Werk* (OLG Düsseldorf
Rn. 5 ff.). An empty Shapes column means the decision floats free of the
output and is legally weak. Fill it even if brief.

### Examples

```markdown
## Decision Log

| ID | Requirement | Options Evaluated | Decision | Reasoning | Shapes |
|----|------------|-------------------|----------|-----------|--------|
| D-1 | §203 requires encrypted client data storage | (a) cloud storage + client-side encryption, (b) database native encryption, (c) separate encrypted file store | (a) storage + CSE | Database native encryption doesn't cover backup snapshots; (c) adds operational complexity without security uplift for our threat model | storage adapter module; blob container naming convention; CSE key handling |
| D-2 | Design partner feedback: email taxonomy must match attorney mental model (session 2026-03-16) | (a) flat tags, (b) hierarchical categories, (c) intent-based classification | (c) intent-based | Flat tags don't capture urgency dimension; hierarchical requires attorney training; intent-based maps to how the design partner naturally describes incoming mail ("mandate request", "court deadline", "info only") | classifier prompt + output schema; emails container `intent` field enum; inbox filter UI chips |
| D-3 | Multi-tenant playbook config needs isolation | (a) per-org container, (b) shared container + partition key, (c) per-org database | (b) shared + partition | Consistent with existing document database pattern (matters, tasks, contacts all use shared containers); (a) requires excessive resource overhead per tenant; (c) exceeds database limits at scale | playbooks container schema; partitionKey=organizationId; data-access layer query helpers |
| D-4 | External KYC service must run without blocking intake (latency: 3-8s) | (a) synchronous in-flow, (b) async fire-and-forget, (c) async with result callback | (c) async + callback | (a) blocks attorney for 8s on every intake; (b) loses result — attorney never sees KYC flag; (c) writes result to task when ready, attorney sees it at review time | intake handler; KYC webhook receiver; tasks container task_type=kyc_review |
```

### When the Decision Log Carries IP Weight

If a spec has a substantive Decision Log (>=2 entries with real alternatives),
commits implementing that spec can use the shorter [HUMAN] tag:

```
[HUMAN]: Implemented per SPEC-INTAKE §5.2. Delta-decisions: none — spec fully
determined implementation. See Decision Log D-1 to D-4.
[SPEC-REF]: docs/specs/SPEC-INTAKE-API-CONTRACT.md
```

The word minimum (30/40) is waived because the spec IS the creative pre-work.

### What Does NOT Belong in the Decision Log

- **Implementation details** without alternatives (e.g., "used forEach loop")
- **Framework conventions** (e.g., "used Next.js App Router")
- **Trivial choices** that wouldn't "reasonably go two or more ways"
- **Prompts or research queries** — the Decision Log captures what was DECIDED, not what was ASKED. Per AG Munchen Rn. 22, prompts are "Auftrag an einen Designer" — the decisions extracted from research are protectable, not the research instructions themselves.

---

*Part of [IP-SHIELD](README.md) — Urheberrechtliche Dokumentation fur KI-gestutzten Code.*
*Developed by Dr. Sascha Theissen / MAIQ GmbH, April 2026.*
