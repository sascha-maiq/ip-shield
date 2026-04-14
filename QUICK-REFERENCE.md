# IP-SHIELD Quick Reference
<!-- Keep at desk or pin to monitor -->

## Was macht Code schutzfähig?

**DEINE Entscheidungskette** — Anforderung → Recherche → Entscheidung.

| Schutzfähig ✅ | Nicht schutzfähig ❌ |
|---|---|
| "§203 verlangt verschlüsselte Speicherung → Storage+CSE vs DB-native Encryption evaluiert → Storage+CSE **weil** Backup-Abdeckung" | "Mach eine Suchfunktion" |
| "API-Rate-Limit erfordert Caching → fixed vs adaptive TTL geprüft → adaptive **wegen** Sliding-Window" | "Füg Caching hinzu" |
| "Design-Partner-Feedback: Intent-basiert statt flat tags **weil** Anwalts-Denkmodell" | "Nimm eine Datenbank" |
| Spec mit Decision Log → Code reviewed → Änderungen gemacht | Prompt → Akzeptiert |

## Commit [HUMAN]-Tag: REQUIREMENT → RESEARCH → DECISION

```
[HUMAN]: §203 verlangt verschlüsselte Speicherung [REQ].
Evaluiert: Storage+CSE vs DB-native vs separater Store [RES].
Storage+CSE gewählt — native deckt keine Backups ab [DEC].
```

**Wortminimum:** HIGH ≥40 Wörter, MEDIUM ≥30 Wörter (entfällt bei Spec mit Decision Log)

## Decision Log in Specs

Jede Spec braucht einen Decision Log — dort lebt die volle Begründung:

```
| ID | Anforderung | Optionen | Entscheidung | Begründung |
| D-1 | §203 Speicherung | Storage+CSE, DB-native, sep. Store | Storage+CSE | Backup-Abdeckung |
```

## Dreistufiger Test (AG München)

1. **Kreative Entscheidung?** → Du hast Alternativen evaluiert und gewählt
2. **Im Output erkennbar?** → Deine Wahl prägt den Code, nicht nur die Idee
3. **KI = Werkzeug?** → Du steuerst, KI führt aus

**Alle drei JA = schutzfähig.**

## Was du tun musst

| Aufgabe | Aufwand | Wer macht's |
|---------|---------|-------------|
| Entscheidungen treffen & begründen | 0 Extra | Du (im Chat mit Claude) |
| Decision Log in Specs pflegen | 5 Min./Spec | Claude draftet, du prüfst |
| Commit-Message prüfen & genehmigen | 30 Sek. | Du (Claude schreibt) |
| ARCHITECTURE.md aktuell halten | 15 Min./Woche | Claude draftet, du prüfst |

## IP-Score Schnelltest

**HIGH (≥40 Wörter)** → Architektur entworfen, Alternativen evaluiert, Code reviewed
**MEDIUM (≥30 Wörter)** → Richtung vorgegeben, Spec mit Decision Log, KI-Output geprüft
**LOW (kein Minimum)** → Routine, kein Design-Entscheid → **Wahrscheinlich nicht schutzfähig!**

## Post-Commit Check

```bash
./docs/process/ip-evidence.sh --feedback
```

## Evidence Package (für Anwalt/DD)

```bash
./docs/process/ip-evidence.sh --report --lang DE
```
