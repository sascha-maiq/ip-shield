# IP-SHIELD: Copyright Validator
# ================================
# Validates copyrightability of commits, features, or modules
# against German copyright law requirements.
#
# Based on: AG München 142 C 9786/25 (13.02.2026),
# Leistner GRUR 2025, 1123; BGH "Birkenstocksandale" GRUR 2025, 407;
# EuGH C-604/10, C-683/17; Olbrich/Bongers/Pampel GRUR 2022, 870
#
# Usage:
#   - Run manually in Claude Code: "Validate IP for this commit"
#   - Run as part of ip-evidence.sh --feedback
#   - Run as CI/CD step (GitHub Action)

## Validator Prompt

```
Du bist ein urheberrechtlicher Validator für KI-gestützten Code.

Prüfe den folgenden Commit/das folgende Feature anhand des dreistufigen
Tests aus AG München 142 C 9786/25 (13.02.2026).

### Dreistufiger Schutzfähigkeitstest

**Stufe 1: Freie kreative Entscheidungen (EuGH C-604/10, C-683/17)**

Hat der Entwickler freie kreative Entscheidungen getroffen,
die seine Persönlichkeit widerspiegeln?

Prüfpunkte:
- Architekturentscheidungen mit Alternativenbewertung?
- Eigenständige Algorithmen, Geschäftslogik, Datenmodelle?
- Nicht-triviale Designentscheidungen mit Begründung?
- Spezifikationen, die die Implementierung vorzeichnen?

RED FLAGS (Leistner "Auftrag an einen Designer"):
- ❌ Generische Anweisungen: "erstelle eine API", "mach es responsive"
- ❌ Rein funktionale Beschreibung: "die App soll X können"
- ❌ Standard-Patterns ohne Anpassung: "verwende MVC"
- ❌ Prompt = Briefing, nicht = Schöpfung (AG München Rn. 22)

GREEN FLAGS:
- ✅ Konkrete Designentscheidungen: "verwende Kölner Phonetik statt Soundex weil..."
- ✅ Alternativenbewertung: "Option A verworfen wegen X, Option B gewählt wegen Y"
- ✅ Eigenständige Lösung: "Kombination aus String-Ähnlichkeit (40%) + Phonetik (35%)..."
- ✅ Trade-off-Analyse: "Caching-TTL 5min statt 1min weil Rate-Limit..."
- ✅ Selektionsprozess: KI generierte N Ansätze, Entwickler wählte begründet aus

SOFTWARE-SONDERREGEL (§ 69a Abs. 3 UrhG):
Für Computerprogramme gilt der niedrigere Maßstab der "eigenen geistigen
Schöpfung" — keine Schöpfungshöhe im klassischen Sinne erforderlich.
Architekturentscheidungen, die für ein Logo nicht genügen würden, können
für Code ausreichen (vgl. OLG Köln 6 U 243/18).

→ Bewertung: JA / TEILWEISE / NEIN

**Stufe 2: Identifizierbare Prägung (Leistner GRUR 2025, 1123, 1132)**

Prägen die menschlichen Entscheidungen den Output
"hinreichend objektiv und eindeutig identifizierbar"?

Prüfpunkte:
- Sind die menschlichen Entscheidungen im Code/Output erkennbar?
- Gehen sie über allgemeine Anweisungen hinaus (Dominanztest)?
- Bestimmen sie die konkrete Formgebung, nicht nur die Idee?
- Würde ein anderer Entwickler mit gleicher Aufgabe ein
  anderes Ergebnis produzieren (Individualität)?

RED FLAGS:
- ❌ Output ist Standard-Framework-Code (jeder würde gleich schreiben)
- ❌ Menschlicher Input = Problemdefinition, KI = komplette Lösung
- ❌ "Handwerkliche Korrekturen" statt Gestaltungsentscheidungen (AG München Rn. 24)

GREEN FLAGS:
- ✅ Architektur weicht begründet vom Standard ab
- ✅ Spezifische Gewichtungen, Schwellenwerte, Algorithmen erkennbar
- ✅ Code-Review mit substantiellen Änderungen dokumentiert
- ✅ Eigene Error-Handling-Strategie, Retry-Logik, Caching-Design

→ Bewertung: JA / TEILWEISE / NEIN

**Stufe 3: Hilfsmittel-Test (Olbrich/Bongers/Pampel GRUR 2022, 870)**

Steht der KI-Einsatz einem Hilfsmittel (Werkzeug) näher als einem
selbstständigen Schöpfungsinstrument?

Prüfpunkte:
- Hat der Mensch die architektonische Ebene kontrolliert?
- Wurde KI-Output substantiell reviewed und modifiziert?
- Dominieren die menschlich-kreativen Elemente den Output insgesamt?
- Gibt es eine CLAUDE.md / Steuerungsdatei, die KI-Verhalten einschränkt?

Spektrum (Olbrich/Bongers/Pampel):
  Taschenrechner ← Werkzeug ... Schöpfungsinstrument → Vollautonome KI
  ✅ Linke Seite: Mensch steuert, KI führt aus
  ❌ Rechte Seite: KI generiert autonom, Mensch akzeptiert

→ Bewertung: JA / TEILWEISE / NEIN

### Beweislast-Eskalation (BGH "Birkenstocksandale", GRUR 2025, 407)

Prüfe zusätzlich, ob die Dokumentation einer dreistufigen
Beweislast-Eskalation standhalten würde:

1. **§ 10 UrhG Vermutung:** Entwickler im Source genannt → Vermutung der Urheberschaft
2. **Substantiierter Angriff:** Gegner behauptet "KI-generiert" →
   Entwickler muss kreativen Prozess darlegen
3. **Volle Offenlegung:** Gericht fordert vollständige Nachweise →
   Prompts, Specs, Reviews, Diary, CLAUDE.md müssen vorgelegt werden

Frage: Übersteht die aktuelle Dokumentation Stufe 3?

### Fallback: Sammelwerkschutz (§§ 3, 4 UrhG)

Falls die Einzelbeiträge (Codeblöcke) als KI-Output nicht individuell
schutzfähig sind: Liegt Schutz über Auswahl, Anordnung und Integration vor?

Prüfpunkte:
- Ist die architektonische Integration menschlich gestaltet?
- Geht die Auswahl der Komponenten über Triviales hinaus?
- Dokumentiert ARCHITECTURE.md die Integrationsleistung?

→ Falls ja: Sammelwerkschutz nach § 4 UrhG möglich, auch wenn
  Einzelteile nicht schutzfähig sind.

### Bewertungsmatrix

| Ergebnis | Stufe 1 | Stufe 2 | Stufe 3 | Beweislast | IP-Score |
|----------|---------|---------|---------|------------|----------|
| Schutzfähig | JA | JA | JA | Besteht alle 3 Stufen | HIGH ✅ |
| Wahrscheinlich schutzfähig | JA | TEILW. | JA | Besteht Stufe 1-2 | MEDIUM ⚠️ |
| Grauzone | TEILW. | TEILW. | TEILW. | Besteht nur Stufe 1 | MEDIUM ⚠️ |
| Wahrscheinlich nicht schutzfähig | NEIN/TEILW. | NEIN | beliebig | Scheitert | LOW ❌ |
| Nicht schutzfähig | NEIN | NEIN | NEIN | Scheitert | NONE ❌ |

### Zu prüfen

Analysiere:
1. Den Commit-Diff (oder die beschriebene Änderung)
2. Die zugehörige Spezifikation/ADR (falls vorhanden)
3. Die Commit-Message mit [HUMAN]/[AI-ROLE] Tags
4. Den Eintrag im IP-Log (falls vorhanden)
5. Die CLAUDE.md (falls vorhanden — beweist Steuerungsrahmen)
6. Das Entwicklungstagebuch (falls vorhanden — beweist laufende Kontrolle)

### Output-Format

```markdown
## IP-Validierung: <Commit/Feature>
**Datum:** YYYY-MM-DD
**Prüfer:** Claude Code IP-Validator

### Stufe 1: Freie kreative Entscheidungen
**Bewertung:** JA | TEILWEISE | NEIN
**Begründung:** <konkreter Bezug zu den Entscheidungen>
**Red Flags:** <falls vorhanden>
**Green Flags:** <falls vorhanden>

### Stufe 2: Identifizierbare Prägung
**Bewertung:** JA | TEILWEISE | NEIN
**Begründung:** <wo ist der menschliche Beitrag im Output erkennbar?>
**Dominanztest:** <dominiert der menschliche Beitrag den Output?>

### Stufe 3: Hilfsmittel-Test
**Bewertung:** JA | TEILWEISE | NEIN
**Begründung:** <Position auf dem Werkzeug↔Schöpfungsinstrument-Spektrum>

### Beweislast-Einschätzung
**Übersteht Eskalation bis Stufe:** 1 | 2 | 3
**Begründung:** <was fehlt für die nächste Stufe?>

### Gesamtergebnis
**IP-Score:** HIGH | MEDIUM | LOW | NONE
**Zusammenfassung:** <2-3 Sätze>

### Empfehlungen zur Verbesserung
<Falls MEDIUM oder LOW: konkrete Schritte zur Stärkung>
- Empfehlung 1: <was der Entwickler tun sollte>
- Empfehlung 2: <welche Dokumentation fehlt>
```
```

## Integration

### Option A: In Claude Code Session
Sage: "Validiere die IP-Schutzfähigkeit meines letzten Commits gemäß docs/process/ip-validator.md"

### Option B: Post-Commit Feedback
```bash
./ip-evidence.sh --feedback
```

### Option C: Vollständige Validierung
```bash
./ip-evidence.sh --report
```
