# AI BOT V3 — DEMO READINESS

## Current verdict

**DOCUMENTATION PREPARED — P0 DECISIONS STILL REQUIRED**

This is a binary gate register. Allowed criterion states are only `PASS`, `FAIL`, `BLOCKED`, or `NOT RUN`. A documentation-level PASS does not substitute for a code/runtime test.

| Criterion | Status | Current evidence | Required next evidence |
|---|---|---|---|
| SPEC | BLOCKED | Draft authority structure, P0 register, decisions, and recommended values exist | Approve HD-001–HD-010, MT5 manifest, exact config, spec version/hash, and approval record; Level 0 PASS |
| SAFETY | NOT RUN | Paper-only boundary and prohibited execution APIs are documented; no V3 code exists | Authorized code plus Level 1 static/reachable-path PASS |
| COMPILE | NOT RUN | Compile prohibited in current task | Level 2 in exact standard AI Bot MetaEditor environment, 0 errors/0 warnings |
| LOGIC | NOT RUN | Candidate formulas and exact unit oracles are documented | Level 3 PASS against approved rules |
| PERSISTENCE | BLOCKED | Recommended authority/checkpoint design exists | HD-007 approval, implementation, crash tests, and reconciliation PASS |
| RECOVERY | BLOCKED | Restart/replay requirements and failure fixtures exist | HD-007 approval plus Level 4–6 recovery PASS |
| DETERMINISM | BLOCKED | Required identities and canonical comparison are defined | HD-009/HD-010 approval plus Level 5 PASS |
| LOGGING | NOT RUN | Automatic event categories/common fields are specified; no implementation exists | Schema/config approval, implementation, completeness/integrity/reconciliation tests PASS |
| METRICS | BLOCKED | Formulas are drafted | HD-003/HD-004/HD-010 and broker cost evidence approved; unit/recompute tests PASS |
| SHORT PAPER TEST | NOT RUN | Exact Level 6 minimum and oracle are documented | Levels 0–5 PASS, authorization, then Level 6 PASS |
| EXTENDED PAPER TEST | BLOCKED | Freeze, two-week target, evidence coverage, and extension rule are documented | Level 6 PASS and explicit authorization for frozen Level 7 run |

## Freeze gate

Before Level 7, record and approve exact source commit, MQ5/EX5 hashes, spec hash, config hash, schema/action-key/equity-policy versions, broker-manifest hash, symbol, environment, start time, and authorized operator. Any critical fix creates a new identity and a fresh run.

## Non-progression statements

- Calendar time alone cannot change a criterion to PASS.
- Missing signal/trade/market-condition coverage means insufficient evidence and extension, not an automatic favorable result.
- Pre-fix and post-fix evidence cannot be pooled as one homogeneous run.
- Paper/demo PASS is not profitability, production, live, or real-money approval.
