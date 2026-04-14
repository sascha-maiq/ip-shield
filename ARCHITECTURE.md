# System Architecture
<!-- 
  THIS IS YOUR MOST IMPORTANT IP DOCUMENT.
  It proves that a human designed the system architecture.
  Keep it current. Update with every architectural change.
  Commit changes to this file SEPARATELY with detailed reasoning.
  
  Legal basis: This document evidences "freie kreative Entscheidungen"
  (EuGH C-604/10) and shows AI was used as "Hilfsmittel" not
  "Schöpfungsinstrument" (Olbrich/Bongers/Pampel GRUR 2022, 870).
-->

## Project Overview

**Project:** [Name]
**Author(s):** [Developer names — these are the claimed copyright holders]
**Created:** [Date]
**Last updated:** [Date]

## Architectural Vision

<!-- WHY this architecture? What problem does it solve?
     This section shows your creative intent. -->

[Describe the high-level vision and the key insight that drives the design]

## System Design

### Core Architecture Pattern

<!-- What pattern did you choose and WHY?
     Alternatives you considered and rejected are strong IP evidence. -->

**Chosen approach:** [e.g., event-driven microservices, modular monolith, etc.]

**Why this over alternatives:**
- Alternative A: [rejected because...]
- Alternative B: [rejected because...]
- Chosen approach: [selected because...]

### Module Structure

<!-- Your decomposition into modules is a creative decision.
     Document the reasoning, not just the result. -->

```
[ASCII diagram or description of module relationships]
```

| Module | Purpose | Key Design Decision |
|--------|---------|-------------------|
| [name] | [what it does] | [why designed this way] |

### Data Architecture

<!-- Schema design, data flow, storage choices — all human decisions -->

**Data model rationale:** [Why these entities? Why these relationships?]

**Storage choices:** [Why this database? Why this caching strategy?]

### API Design

<!-- Endpoint structure, authentication strategy, error handling approach -->

**Design principles:** [What guides your API design?]

### Integration Architecture

<!-- How external services are integrated — orchestration is a human decision -->

## Technology Choices

<!-- Each technology choice with reasoning is evidence of human decision-making -->

| Technology | Purpose | Why Chosen (over alternatives) |
|-----------|---------|-------------------------------|
| [tech] | [purpose] | [reasoning] |

## Security Architecture

<!-- Security design decisions are inherently human-creative -->

## Deployment Architecture

<!-- Infrastructure design choices -->

## Architecture Decision Log

<!-- Link to ADRs for major decisions -->

| ADR | Date | Decision | Status |
|-----|------|----------|--------|
| [ADR-001](decisions/ADR-001-xxx.md) | YYYY-MM-DD | [title] | accepted |

---

*This document is maintained by [developer name(s)] and represents
human architectural decisions that guide all AI-assisted implementation.*
