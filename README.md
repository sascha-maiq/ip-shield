# IP-SHIELD

**Protect the copyright of AI-assisted code through systematic documentation.**

When developers use AI coding tools (Claude Code, Copilot, Cursor, etc.), the resulting code risks losing copyright protection entirely. IP-SHIELD solves this by documenting the *human* creative decisions that make code protectable — automatically, during development, not after the fact.

---

## The Problem: Why AI-Assisted Code Can Lose Copyright

On February 13, 2026, the Munich District Court (AG München, case 142 C 9786/25) denied copyright protection to an AI-generated logo. The ruling established a test that applies to all AI-assisted creative works — including software.

**The core issue:** Copyright protects "personal intellectual creations" (§ 2(2) German Copyright Act). When AI generates the output, the human must prove that *their* creative decisions shaped the result. Without proof, the work is treated as unprotectable — anyone can copy it freely.

**The "Designer Brief" trap (AG München para. 22):** The plaintiff had written a 1,700-character prompt describing the desired logo in detail. The court rejected this as equivalent to "giving a brief to a designer" — describing *what* you want is not a creative act. The *design decisions themselves* are.

For code, this means:
- "Implement user authentication" = a brief (not protectable)
- Designing the session management strategy, choosing JWT over sessions with reasoning, defining the token rotation policy = creative decisions (protectable)

**The burden of proof lies with you** (BGH "Birkenstock Sandal", GRUR 2025, 407). If challenged, you must demonstrate your creative contribution. Without documentation, you cannot.

### Three requirements for copyright (all must be met)

| # | Requirement | Source | What it means |
|---|-------------|--------|---------------|
| 1 | **Free creative choices** | CJEU C-604/10 | You made design decisions with alternatives |
| 2 | **Identifiable shaping** | Leistner GRUR 2025, 1123 | Your choices visibly shape the output |
| 3 | **AI as tool, not creator** | Olbrich/Bongers/Pampel GRUR 2022, 870 | AI was under your control |

**All three YES = protectable. Any NO = risk.**

**Software gets a lower bar** (§ 69a(3) UrhG): Code only needs to be an "individual intellectual creation" — no classical "creative height" required. Architecture decisions that wouldn't protect a logo may well protect code.

---

## The Solution: Document During Development, Prove On Demand

IP-SHIELD uses a two-phase approach:

```
Phase 1 (Development)            Phase 2 (Evidence)
┌──────────────────────┐         ┌──────────────────────┐
│ CLAUDE.md Rules      │         │ ip-evidence.sh       │
│  → Decision points   │         │  → Post-commit       │
│  → IP tags in commits│  git    │    feedback           │
│  → IP log            │ ──────► │  → Evidence package   │
│  → Diary entries     │         │  → Court-grade report │
│  → ARCHITECTURE.md   │         │    (DE/EN)            │
└──────────────────────┘         └──────────────────────┘
```

### Phase 1: Documentation During Development

**Paradigm: "Claude writes, human decides."**

IP-SHIELD adds rules to your `CLAUDE.md` that instruct Claude Code to:
- **Ask** for your design decisions at every meaningful choice point ("Rückfragen-Pflicht")
- **Write** commit messages with structured IP tags automatically
- **Maintain** IP log, development diary, and architecture docs

You make decisions and control the documentation — Claude handles the writing. The key insight: *writing* documentation is not creative work. *Making* design decisions is. IP-SHIELD captures the decisions, not the typing.

**What a development session looks like:**

```
You:     "Implement feature X"
Claude:  "I see three approaches: A, B, C — which direction and why?"  ← asks
You:     "B, because..."                                               ← you decide
Claude:  Implements, writes commit message with IP tags                 ← documents
You:     Review commit message, approve                                 ← you control
```

### Phase 2: Evidence On Demand

**`ip-evidence.sh` extracts proof from your git history.**

When you need evidence — for a lawyer review, due diligence, court proceeding, or IP audit — the script generates a structured evidence package:

- **`--feedback`**: Post-commit quality check (developer learns, improves)
- **`--report`**: Structured report mapped to the three-stage legal test
- **(default)**: Full evidence package with all documents and analysis

The report is generated from *existing* data in your repository. No retroactive documentation needed — everything was captured during development in Phase 1.

---

## Worked Example: IP-SHIELD's Own Development

This repository was developed using IP-SHIELD itself. Here's what Phase 1 and Phase 2 look like in practice.

### Phase 1: A Real Commit

During development, the developer designed a 2-stage architecture. Claude Code asked about alternatives, the developer chose, and Claude wrote the commit:

```
feat(ip-shield): initial release — copyright protection framework

[HUMAN]: Designed complete 2-stage IP documentation architecture based on
analysis of AG München 142 C 9786/25 (13.02.2026). Key design decisions:
(1) 2-stage architecture separating development documentation (CLAUDE.md
rules) from evidence extraction (ip-evidence.sh) — because documentation
must happen during development, not after the fact.
(2) "Claude writes, human decides" paradigm — solves the documentation
overhead problem while preserving legally required human creative control.
(3) Rückfragen-Pflicht with negative examples — Claude must ask for design
decisions but NOT for trivial choices, because documentation noise weakens
the IP case (AG München para. 24: "routine corrections").
...
[AI-ROLE]: Claude Code generated implementation from human-designed specs.
[CREATIVE-DECISIONS]: 2-stage architecture over monolithic approach, "Claude
writes" paradigm over manual documentation, negative examples in decision
points (AG München para. 24 analysis), ...
[IP-SCORE]: HIGH
[ALTERNATIVES-REJECTED]: (1) Monolithic approach — rejected because
documentation must happen during development. (2) New [SELECTION] tag —
rejected because existing [ALTERNATIVES-REJECTED] covers the same ground.
...
```

This single commit documents: what the developer decided, why, what alternatives were rejected, and what role AI played. All written by Claude, all controlled by the developer.

### Phase 2: The Evidence Report

Running `./ip-evidence.sh --report --lang EN` on this repository produces:

```
Stage 1: Free Creative Choices
  ARCHITECTURE.md: No | ADRs: No | Specs: No | Diary: No | CLAUDE.md: No
  → "None of the five planning documents are present..."
  → Recommendation: Create at minimum ARCHITECTURE.md and CLAUDE.md.

Stage 2: Identifiable Shaping
  3 of 4 commits (75%) contain IP tags.
  1 commit classified as HIGH — human decisions dominate the output.

Stage 3: Tool Test
  1 mechanism: IP tags in commits document human-AI role distribution.
```

The report honestly shows what's documented and what's missing. It adapts its legal assessment to the actual evidence found — no false claims.

---

## Creating ARCHITECTURE.md

**ARCHITECTURE.md is your most important IP document.** It proves that the system design is yours — even if every line of code was AI-generated.

### Three ways to create it

| Approach | When to use | Effort |
|----------|------------|--------|
| **A. Claude analyzes, you validate** | Mid-project, code exists | ~30 min |
| **B. You write it yourself** | Project start, you have the vision | ~1-2 hours |
| **C. Claude extracts from existing docs** | You have design docs, specs, ADRs | ~30 min |

**Option A (recommended for existing projects):**

```
You:     "Analyze the codebase and draft an ARCHITECTURE.md.
          Focus on my design decisions, not implementation details."
Claude:  Produces draft with module structure, data flow, key decisions.
You:     Review. Add your reasoning for WHY you chose this architecture.
         Remove anything that's just describing code structure.
         Add: alternatives you considered, trade-offs you accepted.
Claude:  Incorporates your changes, commits with [HUMAN] tag.
```

**What makes a strong ARCHITECTURE.md:**
- System overview with module boundaries (your decomposition decisions)
- Data flow between components (your integration design)
- Key decisions **with reasoning and rejected alternatives**
- Technology choices **with trade-off analysis**

**What does NOT help:**
- Code-level documentation (that's what comments are for)
- Lists of files and folders without design reasoning
- Generic descriptions that any project could have

### Updating mid-project

If your project already has commits without IP documentation, you can:

1. Create ARCHITECTURE.md now (Option A above)
2. Start using IP tags in new commits going forward
3. Run `ip-evidence.sh` — the report shows partial coverage honestly

The evidence package always reflects reality. Partial documentation is better than none — and the ARCHITECTURE.md proves architectural control regardless of when it was created, as long as it accurately reflects decisions you made.

---

## Quick Start

### Option A: Automated (recommended)

```bash
./install.sh /path/to/your/project
```

### Option B: Manual (5 minutes)

```bash
# 1. Create folder structure
cd /path/to/your/project
mkdir -p docs/{specs,decisions,ip-log,reviews,process}

# 2. Copy templates
cp ip-shield/ARCHITECTURE.md docs/ARCHITECTURE.md
cp ip-shield/ADR-TEMPLATE.md docs/decisions/
cp ip-shield/FEATURE-SPEC.md docs/specs/
cp ip-shield/ip-validator.md docs/process/
cp ip-shield/ip-evidence.sh docs/process/
chmod +x docs/process/ip-evidence.sh

# 3. Extend your CLAUDE.md
# Append the content of CLAUDE_MD_IP_SECTION.md
# to the end of your project's CLAUDE.md

# 4. Fill in ARCHITECTURE.md (MOST IMPORTANT file!)
# → Enter your actual architecture decisions

# 5. Start developing — Claude will handle the rest
```

## Scope

| Dimension | Supported | Not supported |
|-----------|-----------|---------------|
| **Platform** | macOS, Linux, WSL | Windows native |
| **AI Tool** | Claude Code (Phase 1 + 2) | Cursor, Copilot, Windsurf (Phase 2 only*) |
| **Legal framework** | German UrhG, EU (CJEU) | US Copyright, UK Copyright |

*Phase 2 (ip-evidence.sh) reads only git — works with any tool. Phase 1 (CLAUDE.md rules) is Claude Code specific. Users of other tools must follow the commit tag convention manually or adapt the rules to their tool's instruction format (.cursorrules, etc.).

## Files Overview

```
ip-shield/
├── README.md                    ← This file
├── CLAUDE_MD_IP_SECTION.md      ← Rules for CLAUDE.md (Phase 1)
├── ip-evidence.sh               ← Evidence Package Generator (Phase 2)
├── install.sh                   ← Automated installation
├── ARCHITECTURE.md              ← Template: system architecture
├── ADR-TEMPLATE.md              ← Template: decision documentation
├── FEATURE-SPEC.md              ← Template: feature specification
├── QUICK-REFERENCE.md           ← Quick reference (printable)
├── DECISION-LOG-TEMPLATE.md     ← Template: Decision Log for specs
├── ip-validator.md              ← Copyrightability validator (prompt)
└── prepare-commit-msg           ← Git hook for IP tags
```

## Post-Commit Feedback

```bash
./docs/process/ip-evidence.sh --feedback
```

Output:
```
IP-SHIELD: Post-Commit Feedback
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Commit: a1b2c3d by Jane Developer

IP Quality Check:
  ✓ [HUMAN] tag substantive (24 words)
  ✓ [AI-ROLE] tag present
  ✓ [CREATIVE-DECISIONS] tag with content
  ✓ [IP-SCORE]: HIGH
  ✓ [SPEC-REF] present (expected for HIGH)

IP Documentation Score: 7/7 (100%) — Excellent
```

## Evidence Package

```bash
# Full evidence package
./docs/process/ip-evidence.sh --output ./evidence

# Report only (for lawyer)
./docs/process/ip-evidence.sh --report --lang EN

# Since specific date
./docs/process/ip-evidence.sh --since 2026-01-01 --author "Jane Developer"
```

## Minimal Viable Documentation

The absolute minimum (with Phase 1 active):

1. **CLAUDE.md** with IP section → Claude writes commit messages automatically
2. **ARCHITECTURE.md** kept current → ~15 min/week
3. **Make decisions** and answer Claude's questions → 0 extra effort

Time investment: **~15 minutes per week** (Claude handles the rest).

## Case-Law Update — OLG Düsseldorf 20 W 2/26 (2 Apr 2026)

The Düsseldorf Higher Regional Court (GRUR-RS 2026, 6153) confirmed the
Munich District Court's line and sharpened it on three points:

1. **Copyright protection for AI-generated output IS possible** — "by
   human intervention in AI results, also retrospective or *successive
   during the prompting process*." Covers IP-SHIELD's Rückfragen-Pflicht
   and iterative decision points.
2. **"Sufficiently individual pre-settings in programming the generation
   process"** are required. Covered by ARCHITECTURE.md + specs + Decision
   Logs.
3. **"The mere selection of an AI output from several suggestions is, on
   its own, not sufficient."** ⚠️ The sharpest warning: listing rejected
   alternatives without domain reasoning fails the test. IP-SHIELD's
   REQUIREMENT → RESEARCH → DECISION chain plus the new **Shapes** column
   in Decision Logs (which links the decision to the concrete artifact it
   shapes) address this directly.

The OLG case concerned a photographic work; **software still benefits from
§ 69a(3) UrhG's lower threshold** ("eigene geistige Schöpfung"). The
direction still applies.

## Legal Disclaimer

This toolkit is not legal advice. It is based on the analysis of AG München
142 C 9786/25, OLG Düsseldorf 20 W 2/26 (GRUR-RS 2026, 6153), prevailing
academic opinion (as of April 2026), and recommendations from specialized
IP law firms. The legal landscape is evolving. For specific questions,
consult an IP attorney.

---

---

# IP-SHIELD (Deutsch)

**Urheberrechtlichen Schutz von KI-gestütztem Code durch systematische Dokumentation sichern.**

Wenn Entwickler KI-Coding-Tools nutzen (Claude Code, Copilot, Cursor etc.), riskiert der resultierende Code, den Urheberrechtsschutz vollständig zu verlieren. IP-SHIELD löst das, indem es die *menschlichen* kreativen Entscheidungen dokumentiert, die Code schutzfähig machen — automatisch, während der Entwicklung, nicht im Nachhinein.

---

## Das Problem: Warum KI-gestützter Code den Urheberrechtsschutz verlieren kann

Am 13. Februar 2026 verweigerte das AG München (Az. 142 C 9786/25) einem KI-generierten Logo den Urheberrechtsschutz. Das Urteil etablierte einen Test, der für alle KI-gestützten kreativen Werke gilt — auch für Software.

**Der Kern:** Das Urheberrecht schützt "persönliche geistige Schöpfungen" (§ 2 Abs. 2 UrhG). Wenn KI den Output generiert, muss der Mensch beweisen, dass *seine* kreativen Entscheidungen das Ergebnis geprägt haben. Ohne Beweis wird das Werk als nicht schutzfähig behandelt — jeder darf es frei kopieren.

**Die "Designer-Briefing"-Falle (AG München Rn. 22):** Der Kläger hatte einen 1.700 Zeichen langen Prompt geschrieben, der das gewünschte Logo detailliert beschrieb. Das Gericht wertete dies als "Auftrag an einen Designer" — zu beschreiben *was* man will, ist keine schöpferische Leistung. Die *Designentscheidungen selbst* sind es.

Für Code bedeutet das:
- "Implementiere User-Authentifizierung" = ein Briefing (nicht schutzfähig)
- Die Session-Management-Strategie entwerfen, JWT statt Sessions mit Begründung wählen, die Token-Rotation-Policy definieren = kreative Entscheidungen (schutzfähig)

**Die Beweislast liegt bei dir** (BGH "Birkenstocksandale", GRUR 2025, 407). Bei einer Anfechtung musst du deinen kreativen Beitrag nachweisen. Ohne Dokumentation ist das nicht möglich.

### Drei Voraussetzungen für Urheberrechtsschutz (alle müssen erfüllt sein)

| # | Voraussetzung | Quelle | Bedeutung |
|---|---------------|--------|-----------|
| 1 | **Freie kreative Entscheidungen** | EuGH C-604/10 | Du hast Designentscheidungen mit Alternativen getroffen |
| 2 | **Identifizierbare Prägung** | Leistner GRUR 2025, 1123 | Deine Entscheidungen prägen den Output erkennbar |
| 3 | **KI als Werkzeug, nicht Schöpfer** | Olbrich/Bongers/Pampel GRUR 2022, 870 | Die KI war unter deiner Kontrolle |

**Alle drei JA = schutzfähig. Eines NEIN = Risiko.**

**Software hat eine niedrigere Schwelle** (§ 69a Abs. 3 UrhG): Code muss nur eine "eigene geistige Schöpfung" sein — keine klassische "Schöpfungshöhe" erforderlich. Architekturentscheidungen, die für ein Logo nicht reichen würden, können für Code genügen.

---

## Die Lösung: Während der Entwicklung dokumentieren, bei Bedarf beweisen

IP-SHIELD nutzt einen Zwei-Phasen-Ansatz:

```
Phase 1 (Entwicklung)            Phase 2 (Nachweis)
┌──────────────────────┐         ┌──────────────────────┐
│ CLAUDE.md Regeln     │         │ ip-evidence.sh       │
│  → Rückfragen-Pflicht│         │  → Post-Commit       │
│  → IP-Tags in Commits│  git    │    Feedback           │
│  → IP-Log pflegen    │ ──────► │  → Evidence Package   │
│  → Diary schreiben   │         │  → Gerichtsfester     │
│  → ARCHITECTURE.md   │         │    Report (DE/EN)     │
└──────────────────────┘         └──────────────────────┘
```

### Phase 1: Dokumentation während der Entwicklung

**Paradigma: "Claude schreibt, Mensch entscheidet."**

IP-SHIELD integriert Regeln in deine `CLAUDE.md`, die Claude Code anweisen:
- Bei jeder Designentscheidung den Entwickler zu **fragen** (Rückfragen-Pflicht)
- Commit-Messages automatisch mit IP-Tags zu **schreiben**
- IP-Log, Diary und Architektur-Docs zu **pflegen**

Der Entwickler trifft Entscheidungen und kontrolliert die Dokumentation — Claude übernimmt die Fleißarbeit. Der entscheidende Punkt: *Aufschreiben* ist keine kreative Leistung. *Designentscheidungen treffen* schon. IP-SHIELD erfasst die Entscheidungen, nicht das Tippen.

**So sieht eine Entwicklungssession aus:**

```
Du:     "Implementiere Feature X"
Claude: "Ich sehe drei Ansätze: A, B, C — welche Richtung und warum?"   ← fragt
Du:     "B, weil..."                                                     ← du entscheidest
Claude: Implementiert, schreibt Commit-Message mit IP-Tags               ← dokumentiert
Du:     Prüfst Commit-Message, approved                                  ← du kontrollierst
```

### Phase 2: Nachweis bei Bedarf

**`ip-evidence.sh` extrahiert Beweise aus deiner Git-History.**

Wenn du Nachweise brauchst — für Anwaltsprüfung, Due Diligence, Gerichtsverfahren oder IP-Audit — generiert das Script ein strukturiertes Beweispaket:

- **`--feedback`**: Post-Commit-Qualitätsprüfung (Entwickler lernt, verbessert)
- **`--report`**: Strukturierter Bericht, der den dreistufigen Test abbildet
- **(default)**: Vollständiges Evidence Package mit allen Dokumenten und Analysen

Der Bericht wird aus *vorhandenen* Daten im Repository generiert. Keine nachträgliche Dokumentation nötig — alles wurde während der Entwicklung in Phase 1 erfasst.

---

## Praxisbeispiel: IP-SHIELDs eigene Entwicklung

Dieses Repository wurde mit IP-SHIELD selbst entwickelt. So sehen Phase 1 und Phase 2 in der Praxis aus.

### Phase 1: Ein echter Commit

Während der Entwicklung entwarf der Entwickler eine 2-Stufen-Architektur. Claude Code fragte nach Alternativen, der Entwickler entschied, und Claude schrieb den Commit:

```
feat(ip-shield): initial release — copyright protection framework

[HUMAN]: Designed complete 2-stage IP documentation architecture based on
analysis of AG München 142 C 9786/25 (13.02.2026). Key design decisions:
(1) 2-stage architecture separating development documentation (CLAUDE.md
rules) from evidence extraction (ip-evidence.sh) — because documentation
must happen during development, not after the fact.
(2) "Claude writes, human decides" paradigm — solves the documentation
overhead problem while preserving legally required human creative control.
(3) Rückfragen-Pflicht with negative examples — Claude must ask for design
decisions but NOT for trivial choices, because documentation noise weakens
the IP case (AG München Rn. 24: "handwerkliche Korrekturen").
...
[AI-ROLE]: Claude Code generated implementation from human-designed specs.
[CREATIVE-DECISIONS]: 2-stage architecture over monolithic approach, ...
[IP-SCORE]: HIGH
[ALTERNATIVES-REJECTED]: (1) Monolithic approach — rejected because
documentation must happen during development. ...
```

Dieser eine Commit dokumentiert: was der Entwickler entschied, warum, welche Alternativen verworfen wurden, und welche Rolle die KI spielte. Alles von Claude geschrieben, alles vom Entwickler kontrolliert.

### Phase 2: Der Evidence Report

`./ip-evidence.sh --report --lang DE` auf diesem Repository erzeugt:

```
Stufe 1: Freie kreative Entscheidungen
  ARCHITECTURE.md: Nein | ADRs: Nein | Specs: Nein | Diary: Nein | CLAUDE.md: Nein
  → "Keines der fünf Planungsdokumente liegt vor..."
  → Handlungsempfehlung: Mindestens ARCHITECTURE.md und CLAUDE.md anlegen.

Stufe 2: Identifizierbare Prägung
  3 von 4 Commits (75%) enthalten IP-Tags.
  1 Commit als HIGH klassifiziert — menschliche Entscheidungen dominieren den Output.

Stufe 3: Hilfsmittel-Test
  1 Mechanismus: IP-Tags in Commits dokumentieren die Mensch-KI-Rollenverteilung.
```

Der Bericht zeigt ehrlich, was dokumentiert ist und was fehlt. Er passt seine rechtliche Bewertung an die tatsächlich vorhandene Evidenz an — keine falschen Behauptungen.

---

## ARCHITECTURE.md erstellen

**ARCHITECTURE.md ist dein wichtigstes IP-Dokument.** Sie beweist, dass der Systementwurf von dir stammt — selbst wenn jede Codezeile von KI generiert wurde.

### Drei Wege zur Erstellung

| Ansatz | Wann geeignet | Aufwand |
|--------|---------------|---------|
| **A. Claude analysiert, du validierst** | Mitten im Projekt, Code existiert | ~30 Min. |
| **B. Du schreibst selbst** | Projektstart, du hast die Vision | ~1-2 Stunden |
| **C. Claude extrahiert aus bestehenden Docs** | Design-Docs, Specs, ADRs vorhanden | ~30 Min. |

**Option A (empfohlen für bestehende Projekte):**

```
Du:     "Analysiere die Codebase und erstelle eine ARCHITECTURE.md.
         Fokus auf meine Designentscheidungen, nicht auf Implementierungsdetails."
Claude: Erstellt Entwurf mit Modulstruktur, Datenfluss, Schlüsselentscheidungen.
Du:     Prüfst. Ergänzt WARUM du diese Architektur gewählt hast.
        Entfernst alles, was nur Code-Struktur beschreibt.
        Ergänzt: Alternativen die du erwogen hast, Trade-offs die du akzeptierst.
Claude: Übernimmt deine Änderungen, committed mit [HUMAN]-Tag.
```

**Was eine starke ARCHITECTURE.md ausmacht:**
- Systemüberblick mit Modulgrenzen (deine Zerlegungsentscheidungen)
- Datenfluss zwischen Komponenten (dein Integrationsdesign)
- Schlüsselentscheidungen **mit Begründung und verworfenen Alternativen**
- Technologiewahl **mit Trade-off-Analyse**

**Was NICHT hilft:**
- Code-Level-Dokumentation (dafür gibt es Kommentare)
- Datei- und Ordnerlisten ohne Design-Begründung
- Generische Beschreibungen, die jedes Projekt haben könnte

### Erstellung mitten im Projekt

Wenn dein Projekt bereits Commits ohne IP-Dokumentation hat:

1. ARCHITECTURE.md jetzt erstellen (Option A oben)
2. In neuen Commits IP-Tags verwenden
3. `ip-evidence.sh` ausführen — der Report zeigt die teilweise Abdeckung ehrlich

Das Evidence Package spiegelt immer die Realität wider. Teilweise Dokumentation ist besser als keine — und die ARCHITECTURE.md belegt architektonische Kontrolle unabhängig davon, wann sie erstellt wurde, solange sie Entscheidungen korrekt wiedergibt, die du getroffen hast.

---

## Schnellstart

### Option A: Automatisch (empfohlen)

```bash
./install.sh /path/to/your/project
```

### Option B: Manuell (5 Minuten)

```bash
# 1. Ordnerstruktur anlegen
cd /path/to/your/project
mkdir -p docs/{specs,decisions,ip-log,reviews,process}

# 2. Templates kopieren
cp ip-shield/ARCHITECTURE.md docs/ARCHITECTURE.md
cp ip-shield/ADR-TEMPLATE.md docs/decisions/
cp ip-shield/FEATURE-SPEC.md docs/specs/
cp ip-shield/ip-validator.md docs/process/
cp ip-shield/ip-evidence.sh docs/process/
chmod +x docs/process/ip-evidence.sh

# 3. CLAUDE.md erweitern
# Kopiere den Inhalt von CLAUDE_MD_IP_SECTION.md
# an das Ende deiner CLAUDE.md

# 4. ARCHITECTURE.md ausfüllen (WICHTIGSTE Datei!)
# → Deine echten Architekturentscheidungen eintragen

# 5. Entwicklung starten — Claude übernimmt den Rest
```

## Geltungsbereich

| Dimension | Unterstützt | Nicht unterstützt |
|-----------|-------------|-------------------|
| **Plattform** | macOS, Linux, WSL | Windows nativ |
| **AI-Tool** | Claude Code (Phase 1 + 2) | Cursor, Copilot, Windsurf (nur Phase 2*) |
| **Rechtsrahmen** | Deutsches UrhG, EU (EuGH) | US Copyright, UK Copyright |

*Phase 2 (ip-evidence.sh) liest nur git — funktioniert mit jedem Tool. Phase 1 (CLAUDE.md-Regeln) ist Claude-Code-spezifisch. Wer andere Tools nutzt, muss die Commit-Tag-Konvention manuell einhalten oder die Regeln in das jeweilige Instruction-Format übertragen (.cursorrules, etc.).

## Dateien im Überblick

```
ip-shield/
├── README.md                    ← Diese Datei
├── CLAUDE_MD_IP_SECTION.md      ← Regeln für CLAUDE.md (Phase 1)
├── ip-evidence.sh               ← Evidence Package Generator (Phase 2)
├── install.sh                   ← Automatische Installation
├── ARCHITECTURE.md              ← Template: Systemarchitektur
├── ADR-TEMPLATE.md              ← Template: Entscheidungsdokumentation
├── FEATURE-SPEC.md              ← Template: Feature-Spezifikation
├── QUICK-REFERENCE.md           ← Kurzreferenz (zum Ausdrucken)
├── ip-validator.md              ← Schutzfähigkeits-Validator (Prompt)
└── prepare-commit-msg           ← Git Hook für IP-Tags
```

## Minimale Dokumentation

Das absolute Minimum (wenn Phase 1 aktiv ist):

1. **CLAUDE.md** mit IP-Section → Claude schreibt Commit-Messages automatisch
2. **ARCHITECTURE.md** aktuell halten → ~15 Min./Woche
3. **Entscheidungen treffen** und Claudes Rückfragen beantworten → 0 Extra-Aufwand

Zeitaufwand: **~15 Minuten pro Woche** (Claude übernimmt den Rest).

## Rechtsprechungs-Update — OLG Düsseldorf 20 W 2/26 (2.4.2026)

Das OLG Düsseldorf (GRUR-RS 2026, 6153) bestätigt die Linie des AG München
und präzisiert sie um drei Punkte:

1. **Schutz ist bei KI-Erzeugnissen möglich** — "infolge menschlichen Eingriffs
   in KI-Ergebnisse, der auch nachträglich bzw. sukzessive während des
   Promptings stattfinden kann". Deckt die Rückfragen-Pflicht + iterative
   Decision Points.
2. **Erforderlich: "hinreichend individuelle Voreinstellungen bei der
   Programmierung des Entstehungsprozesses"**. Deckt ARCHITECTURE.md +
   Specs + Decision Logs.
3. **"Die bloße Auswahl eines KI-Erzeugnisses aus mehreren Vorschlägen ist
   für sich genommen nicht ausreichend."** ⚠️ Wichtigster Warnschuss:
   rejected alternatives ohne Begründung reichen nicht. Antwort: REQ→RES→DEC
   chain mit Begründung + neue **Shapes**-Spalte im Decision Log
   (verknüpft Entscheidung und konkretes Werk).

OLG-Fall war ein Lichtbildwerk; für **Software** gilt weiter die niedrigere
Schwelle § 69a Abs. 3 UrhG. Die Richtung gilt dennoch.

## Rechtlicher Hinweis

Dieses Toolkit ist kein Rechtsrat. Es basiert auf der Analyse von AG München
142 C 9786/25, OLG Düsseldorf 20 W 2/26 (GRUR-RS 2026, 6153), der h.M. in
der Literatur (Stand April 2026) und den Empfehlungen diverser Fachkanzleien.
Die Rechtslage entwickelt sich dynamisch. Für konkrete Fragen konsultiere
einen IP-Anwalt.

---

*Developed by Dr. Sascha Theissen / MAIQ GmbH, February 2026.*
*License: MIT — Free to use, including commercially.*
