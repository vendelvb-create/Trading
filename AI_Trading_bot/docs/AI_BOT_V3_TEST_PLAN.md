# AI BOT V3 — TEST PLAN

## Control

- Status: **DRAFT — NOT APPROVED**
- Current executable tests: **NONE; PRODUCTION IMPLEMENTATION IS NOT AUTHORIZED**
- Rule: levels are sequential gates; a FAIL/BLOCKED level prevents every later level
- Evidence: every run records tester, UTC/timezone, source commit, build hash, spec/config/manifest hashes, environment, commands/procedure, raw logs, result, and anomaly references

An oracle is the exact expected result, not a visual “looks good” judgment.

## LEVEL 0 — SPEC

### Preconditions

Current documentation branch is clean and the proposed approved file set is identified.

### Checks and oracle

1. All P0-01 through P0-20 are `PASS` at the specification gate.
2. HD-001 through HD-010 contain exact approved choices, named approver, date/time with timezone, and durable evidence.
3. No `TBD`, `pending`, conflicting normative value, or silent default remains in the approved configuration.
4. The exact AI Bot MT5 manifest passes its evidence request and has a recorded SHA-256.
5. Strategy, config, schema, action-key, equity-policy, spec, and environment identities are complete.
6. Final spec file bytes and canonical config have SHA-256 values; approval references those exact hashes.
7. GoldBot/Pepperstone content is absent from the V3 build/config inputs.
8. The final spec states paper-only, no reachable order execution, demo success is not live approval, and the freeze/defect policy.
9. Every requirement maps to one or more later tests, and every P0 test has an objective oracle.

### Pass oracle

PASS only when all nine checks pass with zero exception. Otherwise FAIL or BLOCKED with an issue ID. Current status: **BLOCKED**.

## LEVEL 1 — STATIC SAFETY

### Preconditions

Level 0 PASS and separately authorized implementation at the approved source commit.

### Checks and oracle

1. Scan all compiled V3 source, includes, libraries, imports, generated files, and reachable wrappers for `CTrade`, `OrderSend`, `OrderSendAsync`, `trade.Buy`, `trade.Sell`, `PositionOpen`, `PositionClose`, execution use of `MqlTradeRequest`, and equivalents.
2. Trace every external/imported call and event path; prove none can create, modify, or close a broker order/position.
3. Verify there is no live/demo-order input, compile flag, environment switch, hidden toggle, dynamic dispatch, or fallback.
4. Verify all file writes stay in the approved AI Bot data namespace and no GoldBot file/state is read or written.
5. Verify secrets/account logins are neither required nor logged.

Text appearing only in safety assertions/comments is not an automatic failure, but every hit must be classified. Any reachable or unresolved execution capability is a FAIL.

### Pass oracle

Zero reachable broker-order paths; zero unclassified scan hits; zero GoldBot dependency; zero secret logging. Current status: **NOT RUN**.

## LEVEL 2 — COMPILE

### Preconditions

Levels 0–1 PASS; clean checkout of the approved source commit; exact standard/generic MetaEditor 5 build from the approved AI Bot manifest.

### Procedure and oracle

1. Compile only the approved AI Bot V3 target in the standard AI Bot MetaEditor environment.
2. Record compiler/build identity, command/procedure, complete compile log, MQ5 size/hash, and EX5 size/hash.
3. Repeat from a second clean work directory with the same declared inputs.

### Pass oracle

Both compiles complete with **0 errors and 0 warnings**. Input/source hashes match. If EX5 bytes are not reproducible because the tool embeds metadata, record that limitation and compare all available deterministic compiler outputs; do not falsely claim byte-for-byte reproducibility. Current status: **NOT RUN**.

## LEVEL 3 — UNIT / LOGIC

### Required deterministic fixtures

1. SMA trend: fast above, below, and exactly equal to slow.
2. RSI: 29.999, 30, a normal value, 70, and 70.001.
3. Pullback: immediately below, equal to, and above each approved threshold; far-through cases; tick-normalized boundary.
4. Closed-bar gate: shift 1 only; shift 0 mutation cannot alter accepted result.
5. Read sequencing: each mandatory read fails in turn; processed-bar identity remains uncommitted and the retry succeeds exactly once.
6. Entry timing and expiry at the exact new-bar boundaries.
7. Long/short Bid/Ask side, spread, slippage, exact-touch SL/TP, and gap fill.
8. ATR/SL/TP and volume rounding for min/max/step, below-minimum, and risk-cap cases.
9. Long/short P/L, costs, R, balance, equity, drawdown, profit factor undefined case, breakeven, and losing streak.
10. Every allowed/forbidden state transition.
11. Duplicate action key and repeated callback behavior.
12. Config, manifest, schema, and source identity mismatch.

### Pass oracle

100% of listed fixtures match the approved formulas and reason codes; no balance/state effect occurs twice; invalid input fails closed; zero test failures. Current status: **NOT RUN**.

## LEVEL 4 — SYNTHETIC EDGE CASES

### Required scenarios

- insufficient H1 history; missing bar; duplicate/out-of-order bar; DST/server-offset transition
- missing/stale/misaligned indicator buffer; NaN/infinite/zero values
- zero, negative, crossed, stale, duplicate, and out-of-order quotes
- spread spike and tick/point mismatch
- gap through SL, gap through TP, and a recovered interval where both were reachable
- downtime spanning one or multiple H1 bars; signal expires during downtime
- identical tick payloads and same-millisecond distinct ticks
- restart while flat, entry pending, long, short, and immediately before/after an exit
- crash before/during/after journal append, flush, state apply, checkpoint promotion, and CSV projection
- truncated/corrupt journal tail; stale/corrupt checkpoint; derived CSV ahead/behind authority
- second writer/start attempt
- disk full/write denial and file reopen failure
- runtime broker/symbol property change

### Pass oracle

Each scenario produces the exact approved event/reason, state, fill or no-fill, and recovery outcome. No scenario opens an MT5 order, invents missing market data, advances a failed bar, duplicates a virtual balance effect, or continues from irreconcilable state. Fatal integrity cases enter `HALTED`. Zero unexplained differences. Current status: **NOT RUN**.

## LEVEL 5 — REPRODUCIBILITY

### Comparisons

1. Replay the same normalized input stream twice from empty state.
2. Replay once uninterrupted and once with crashes/restarts at every Level 4 persistence boundary.
3. Replay on two clean directories/machines when available using identical approved identities.
4. Regenerate CSV/summary from authority and compare with original projections.

### Canonical comparison

Exclude only documented non-canonical ingestion wall-clock timestamps, machine paths, and run-local identifiers. Compare ordered business event types/reasons, action keys, source identities, states, signals, fills, costs, P/L, R, balances, canonical equity samples, drawdown, and summaries.

### Pass oracle

100% canonical equality for all four comparisons; no missing/duplicate action; regenerated projections and summary reconcile exactly to authority. Any unexplained difference is FAIL. Current status: **NOT RUN**.

## LEVEL 6 — SHORT CONTROLLED PAPER TEST

### Preconditions

Levels 0–5 PASS; approved build/config/manifest identities; standard AI Bot demo environment; source/config freeze; baseline account trade history captured to prove the V3 EA does not create orders.

### Minimum observation

Run until **both** conditions are satisfied:

- at least 24 market-open hours of valid attached runtime; and
- at least 20 distinct closed H1 bars are accepted.

Stop earlier on any critical safety, integrity, persistence, or determinism defect.

### Pass oracle

1. No MT5 order/position is created, modified, or closed by V3; baseline/end trade history shows no V3 broker action.
2. Every H1 bar during declared valid runtime is accepted exactly once or has one explicit fail-closed data event; any unresolved gap fails the test.
3. BUY/SELL/WAIT/blocked events and every virtual state transition contain complete required fields and reconcile to authority.
4. Zero duplicate virtual entries/exits, zero balance mismatch, zero unhandled error, and zero unexplained data-quality failure.
5. At least one controlled restart completes and yields exact state/log reconciliation. If a virtual position occurs, perform or capture one restart while exposed; otherwise the synthetic exposed-restart evidence from Level 4 remains required and the absence is recorded.
6. End-of-run metrics recompute exactly from events.
7. A replay of the collected normalized input/events passes Level 5 canonical comparison.

Signal profitability and a minimum trade count are not Level 6 pass criteria. Current status: **NOT RUN**.

## LEVEL 7 — EXTENDED PAPER/DEMO TEST

### Preconditions

Level 6 PASS; human authorization for the exact frozen build/config; incident and stop procedures ready.

### Initial target and extension rule

Target approximately 14 calendar days spanning market-open periods. At review, evidence must include:

- at least 10 distinct market days with valid observations;
- at least 95% of scheduled market-open minutes as valid runtime after excluding predeclared maintenance;
- 100% accounting for closed H1 bars during valid runtime;
- at least one BUY and one SELL signal;
- at least one closed virtual trade in each direction;
- observed trending and non-trending conditions plus a documented volatility range;
- all error, downtime, ambiguity, and recovery events;
- complete deterministic replay and metric reconciliation.

If market behavior does not produce required BUY/SELL/trade/condition coverage, or any data/completeness criterion is unmet, the run is not failed solely for low activity; it is **insufficient evidence** and must be extended without changing the frozen build/config. There is no automatic four-week sufficiency rule.

### Pass oracle

1. All freeze identities remain unchanged for the entire accepted run.
2. No V3 broker order path/action exists or occurs.
3. Runtime, bar accounting, signal/trade direction, and market-condition evidence meet every threshold above.
4. Zero unresolved critical/high defect, state/log mismatch, duplicate action, or unexplained error.
5. Every restart/recovery reconciles exactly; full replay is canonically identical.
6. Required logs and metrics are complete and independently recomputable.
7. The review explicitly separates technical validity from economic results.

If a critical defect occurs, stop, preserve evidence, create a new issue/fix/build/config identity, rerun required levels, and start a fresh valid period. Never combine pre-fix and post-fix data as one run. Current status: **BLOCKED**.

## Interpretation boundary

A Level 7 PASS means the approved V3 paper simulator operated and recorded evidence according to this plan. It does not mean the strategy is profitable, production ready, live ready, or approved for real money.
