# AI BOT V3 — DEMO-READINESS WORKSTREAM

## Status

**DOCUMENTATION / GOVERNANCE ONLY — NO IMPLEMENTATION AUTHORIZED**

Current phase:

`CURRENT STATE AUDIT -> DOCUMENTATION / BLOCKER RECONCILIATION -> HUMAN P0 DECISIONS`

Later gates remain:

`APPROVED FINAL SPEC -> IMPLEMENTATION -> COMPILE / TEST -> SHORT CONTROLLED PAPER TEST -> EXTENDED PAPER/DEMO TEST`

No gate may be skipped.

## Fixed project boundary

- Repository: `vendelvb-create/Trading`
- Project path: `AI_Trading_bot/`
- Instrument/timeframe context: XAUUSD H1, subject to exact AI Bot MT5 symbol evidence
- Environment: standard/generic MetaEditor 5 and MT5 AI Bot environment
- GoldBot and the Pepperstone MetaEditor 5 / MT5 environment are out of scope
- V3 is paper/simulated trading only and may not contain a reachable live-order execution path

## Document authority map

| Document | Authority / purpose |
|---|---|
| `AI_BOT_V3_FINAL_SPEC.md` | Sole normative strategy/simulator specification. Must remain `DRAFT — NOT APPROVED` while any P0 is open. |
| `AI_BOT_V3_KNOWN_ISSUES.md` | Single authoritative current issue and blocker register. |
| `AI_BOT_V3_DECISION_LOG.md` | Human strategy, simulator, and governance decisions. Recommendations are not approvals. |
| `AI_BOT_V3_FIX_LOG.md` | Implementation fix evidence; no unimplemented fix may be called complete. |
| `AI_BOT_V3_DEMO_READINESS.md` | Binary gate checklist using only PASS, FAIL, BLOCKED, or NOT RUN. |
| `AI_BOT_V3_TEST_PLAN.md` | Test levels, fixtures, oracles, and pass/fail rules. |
| `AI_BOT_V3_PROVENANCE.md` | V2 artifact identity, recovered behavior, and limits of proof. |
| `AI_BOT_V3_MT5_EVIDENCE_REQUEST.md` | One precise request for broker/demo and symbol evidence still required. |
| `AI_BOT_V3_PLAN.md` | Workstream index and documentation audit; not a second specification. |
| `../VERSJON_HISTORY.md` | Historical roadmap; not current V3 approval or specification authority. |

If documents conflict, stop and reconcile the conflict in the known-issues and decision registers. A filename, recommendation, roadmap statement, or historical behavior never substitutes for an approval record in the final specification.

## Existing documentation audit — 2026-08-30

Reviewed:

- repository `README.MD`
- repository `PROJECT_CONTEXT.md`
- repository `CHANGELOG.md` (empty)
- `AI_Trading_bot/README.md`
- `AI_Trading_bot/VERSJON_HISTORY.md`
- the prior version of this plan
- Git history affecting `AI_Trading_bot/`
- GitHub issue #1
- all repository pull requests visible on 2026-08-30

### Contradictions and reconciliation

1. **V2 “testing” versus “complete as technical signal/logger test.”** The README, version history, and open issue #1 retain the V2 testing/validation workflow. The old V3 plan called V2 technically complete. Current evidence supports recovery and technical characterization of the V2 artifacts; it does not prove completion of the V2 test, exported-results review, or validation pipeline. Those claims are now kept distinct.
2. **V3 “Design / Implementation” versus current authorization.** The old plan could imply implementation had begun. It has not been authorized in this workstream. Current status is documentation/governance only.
3. **Generic `MA50/MA200` versus recovered `SMA50/SMA200`.** The historical roadmap uses generic MA wording. Recovered V2 evidence specifically identifies simple moving averages. V3 may use SMA50/SMA200 only if the final spec approves that baseline.
4. **Informal pullback versus exact recovered V2 behavior.** The historical roadmap says to wait near MA50 but gives no number. Recovered source evidence gives `InpPullbackTolerance = 0.002` and one-sided BUY/SELL inequalities. This is historical evidence, not automatic V3 approval.
5. **Future roadmap live/demo-order language versus V3 safety.** Historical V6, V10, and V11 roadmap text discusses demo or later live orders. It is not authority for V3. V3 has a permanent paper-only boundary and no hidden live-mode toggle.
6. **Test duration versus evidence quality.** Historical V2 text uses 48–80 hours. Current V3 progression is evidence-gated; elapsed time alone is never sufficient.

## GitHub context

- Open AI Bot issue: #1, V2 post-test validation pipeline. It is not marked complete.
- Open AI Bot pull requests: none found.
- Closed AI Bot pull requests: none found by repository search.
- GoldBot awareness only: draft PR #3 is open; merged PR #2 exists. Neither belongs to this workstream.

## Workstream completion rule

Documentation preparation completes only when the repository records the current evidence, unresolved decisions, exact MT5 evidence request, P0 status, test oracles, and binary readiness status without claiming implementation or approval. The next step after this branch is a single human decision session, not production implementation.
