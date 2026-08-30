# AI BOT V3 — KNOWN ISSUES AND P0 REGISTER

## Control

- Authority: single current issue/blocker register for AI Bot V3
- Assessment date: 2026-08-30
- Base audited: `origin/main` at `45dca18b5904d8e683a71bf9005fa4871dc9289b`
- Scope: documentation and eventual V3 paper simulator only

Issue status values are `CLOSED`, `PARTIALLY RESOLVED`, `UNRESOLVED`, or `NEW`. P0 review status values are `PASS`, `FAIL`, `BLOCKED`, or `HUMAN DECISION REQUIRED`.

For the current documentation gate, `PASS` means the requirement and its acceptance rule are unambiguous; it does not claim future implementation tests passed. `FAIL` means current evidence proves noncompliance. `BLOCKED` means evidence or dependent design is unavailable. `HUMAN DECISION REQUIRED` means a named approval is the next dependency.

## Issue register

| Issue | Class | Evidence | Affected component | Status | Required fix / decision | Test required for closure |
|---|---|---|---|---|---|---|
| KI-001 — Former “missing exact V2 MQ5/test provenance” blocker | P0 | Recovered MQ5/EX5 names, sizes, SHA-256 values, and MATCH reports now exist; exact build linkage and historical test dataset remain unproven | Provenance / governance | PARTIALLY RESOLVED | Preserve the split finding; do not claim exact EX5 build identity or V2 validation results | Artifact hash recheck if archived; build reproduction only if exact-build claim is later required; dataset manifest if V2 outcome is cited |
| KI-002 — Processed-bar state can advance before all required reads succeed | P0 confirmed defect in historical V2 pattern | Recovered V2 source review reported the sequencing weakness | Closed-bar processing / idempotency / data integrity | UNRESOLVED | In later authorized V3 code, read and validate all mandatory inputs, construct and durably accept the evaluation event, then commit processed-bar state | Failure injection for every read; retry same bar; restart replay; prove exactly one accepted evaluation |
| KI-003 — No approved V3 final specification | P0 governance | Prior spec/draft status was not approved; no approval record or spec hash exists | Entire V3 | UNRESOLVED | Resolve all P0 dependencies, freeze explicit values, calculate identity hash, record human approval, then separately authorize implementation | Level 0 spec audit |
| KI-004 — HD-001 through HD-010 are unapproved | P0 strategy/simulator | Decision log has recommendations but no approved choice, approver, or evidence | Signals, fills, risk, state, persistence, metrics | UNRESOLVED | Human owner decides every entry and records approval evidence | Level 0 decision-to-spec traceability; affected Level 3–5 tests |
| KI-005 — Exact AI Bot MT5 broker/symbol evidence is missing | P0 environment/data | Repository contains no approved evidence manifest for the standard AI Bot environment | Configuration, fills, sizing, P/L | UNRESOLVED | Satisfy `AI_BOT_V3_MT5_EVIDENCE_REQUEST.md`; approve and hash the manifest | Manifest schema/integrity check; runtime property match; negative mismatch fixtures |
| KI-006 — V3 implementation, compile, static scan, and runtime tests do not exist | P0 demo gate; expected at this phase | This task explicitly prohibits production implementation and compile | Build and demo readiness | NEW | After final-spec approval and separate authorization, implement and run Levels 1–6 before any extended test | Test plan Levels 1–6 |
| KI-007 — Repository documents blurred V2 technical recovery, V2 test status, and V3 implementation status | P1 documentation | README/history/issue #1 said V2 testing; old plan said V2 technically complete and V3 design/implementation | Documentation / governance | CLOSED | Current README and plan distinguish artifact recovery from test-validation completion and state no implementation authorization | Documentation cross-reference review |
| KI-008 — Completion of the V2 test and post-test validation is not proven | P0 for any deliberate V3 strategy change; P1 for an exact-rule simulator | V2 README/history and open issue #1 describe incomplete workflow; no exported dataset review or validation report was found | Strategy-change authorization / historical claims | PARTIALLY RESOLVED | Preserve exact V2 rules for a simulator baseline, or obtain explicit human authorization to change strategy and reconcile the open V2 validation gate | Decision trace; dataset/report review if used as evidence; Level 0 approval check |
| KI-009 — Repository archive policy for recovered MQ5/EX5 is undecided | P2 provenance | Current task explicitly permits identity documentation but not artifact commit | Repository artifacts | UNRESOLVED | Separate human decision on whether, where, and under what retention/security rules to archive source/binary | Hash and size match before any later archive commit |

## Current P0 review

| P0 | Requirement | Status | Current basis / next dependency |
|---|---|---|---|
| P0-01 | No live execution | PASS | Paper-only is an explicit fixed boundary; no code was added. Later static/code tests must still prove the implementation has no reachable order path. |
| P0-02 | GoldBot isolation | PASS | Separate project/environment is explicit; this branch changes only `AI_Trading_bot/`. |
| P0-03 | Closed-bar / look-ahead | PASS | Draft requirement is shift 1 closed H1 data only and commit-after-success. Entry timing remains HD-005. |
| P0-04 | Signal boundaries / pullback | HUMAN DECISION REQUIRED | HD-001 must approve exact V2, symmetric percentage, ATR proximity, or another rule. |
| P0-05 | Intrabar ambiguity | HUMAN DECISION REQUIRED | HD-006. |
| P0-06 | Gap handling | HUMAN DECISION REQUIRED | HD-004 and HD-006. |
| P0-07 | Bid/Ask / spread | HUMAN DECISION REQUIRED | HD-004 and HD-008; exact MT5 evidence also missing. |
| P0-08 | Slippage | HUMAN DECISION REQUIRED | HD-004. |
| P0-09 | SL / TP | HUMAN DECISION REQUIRED | HD-002. |
| P0-10 | Risk / virtual position sizing | HUMAN DECISION REQUIRED | HD-003 and HD-008; contract evidence missing. |
| P0-11 | State machine | BLOCKED | Draft state model exists, but final transitions depend on HD-004 through HD-007 and no implementation exists. |
| P0-12 | Idempotency | HUMAN DECISION REQUIRED | HD-009; KI-002 must be fixed in later implementation. |
| P0-13 | Persistence / restart recovery | HUMAN DECISION REQUIRED | HD-007. |
| P0-14 | Crash consistency | HUMAN DECISION REQUIRED | HD-007 must approve authority/write protocol. |
| P0-15 | State/log reconciliation | HUMAN DECISION REQUIRED | HD-007. |
| P0-16 | Data integrity | BLOCKED | Mandatory validation behavior is drafted, but exact symbol/session properties and runtime fixtures require the MT5 evidence manifest. |
| P0-17 | Determinism / replay | HUMAN DECISION REQUIRED | HD-009 and HD-010; final config identity also absent. |
| P0-18 | Configuration freeze | HUMAN DECISION REQUIRED | Freeze/change policy is fixed, but HD-001–HD-010 values and config hash are absent. |
| P0-19 | Logging / auditability | PASS | Required automatic event categories, common fields, state transitions, errors, and integrity behavior are specified at the documentation gate. Runtime verification is NOT RUN. |
| P0-20 | Metrics | HUMAN DECISION REQUIRED | Metric formulas are drafted; HD-010 controls the canonical equity/drawdown series and cost inputs remain unapproved. |

No P0 is marked `FAIL` because no V3 implementation has been attempted. `PASS` for P0-01, P0-02, P0-03, and P0-19 is limited to the documentation/specification gate.

## Exact blockers that remain

1. Human approval of HD-001 through HD-010.
2. A complete, integrity-checked AI Bot MT5 evidence bundle and approved broker/symbol manifest.
3. A final explicit configuration with strategy/config/schema identities and hashes.
4. A human final-spec approval record and separate implementation authorization.
5. Later correction and verification of KI-002 in V3 code; the historical V2 weakness must not be inherited.
6. Later implementation, static safety scan, compile, logic, synthetic, recovery, and reproducibility tests.
7. Before any deliberate V3 strategy change is justified by V2 results, proof/review of the V2 dataset and validation workflow or an explicit human decision to proceed without that evidence.

The unproven exact MQ5-to-EX5 build linkage is a limitation on historical claims, not by itself a blocker to drafting a new paper simulator from an approved specification.
