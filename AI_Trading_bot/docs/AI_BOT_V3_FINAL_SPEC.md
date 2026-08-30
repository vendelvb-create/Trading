# AI BOT V3 — FINAL SPECIFICATION

> **DRAFT — NOT APPROVED**
>
> **P0 BLOCKED — NO IMPLEMENTATION AUTHORIZATION**
>
> The filename identifies the intended authoritative location; it does not imply final approval.

## 1. Document control

| Field | Current value |
|---|---|
| Draft ID | `AI-BOT-V3-SPEC-DRAFT-2026-08-30.1` |
| Spec version | NOT FROZEN |
| Spec SHA-256 | NOT ASSIGNED — calculate over the frozen approved file bytes |
| Approval status | NOT APPROVED |
| Approver | NONE |
| Approval date/time | NONE |
| Approval evidence | NONE |
| Implementation authorization | NO |
| Target mode | PAPER / SIMULATED ONLY |

Approval requires zero unresolved P0 requirements, approved explicit parameter values, resolved HD-001 through HD-010, an approved MT5 evidence manifest, frozen version/hash identity, a named approver, durable approval evidence, and a separate affirmative implementation authorization.

Normative terms `MUST`, `MUST NOT`, `SHALL`, and `SHALL NOT` are binding only after approval. Pending values and recommendations are non-authoritative.

## 2. Scope and safety boundary

V3 is an XAUUSD H1 paper simulator that observes the standard/generic AI Bot MT5 environment, generates closed-bar signals, maintains virtual positions, and records deterministic evidence. It never places, modifies, or closes an MT5/broker order or position.

V3 source and reachable dependencies MUST NOT use an execution path involving:

- `CTrade`
- `OrderSend`
- `OrderSendAsync`
- `trade.Buy`
- `trade.Sell`
- `PositionOpen`
- `PositionClose`
- `MqlTradeRequest` for execution
- any equivalent direct, indirect, dynamically dispatched, imported, or wrapped broker-order operation

There SHALL be no live/demo-order mode, hidden toggle, environment variable, compile flag, input, fallback, or wrapper that enables broker execution. Demo account connectivity is market-data input only.

Passing V3 paper/demo testing SHALL NOT imply profitability, production readiness, live readiness, or real-money approval.

## 3. Project and environment isolation

- Repository: `vendelvb-create/Trading`
- In-scope path: `AI_Trading_bot/`
- Build/runtime environment: standard/generic MetaEditor 5 / MT5 AI Bot environment
- Exact symbol and broker contract: pending `AI_BOT_V3_MT5_EVIDENCE_REQUEST.md`
- GoldBot, `Goldbot/`, `GoldBot/`, `Goldbot_v3/`, Pepperstone MetaEditor/MT5, and all GoldBot state/branches/PRs are out of scope

The simulator MUST bind to an approved broker/symbol evidence-manifest hash and fail closed if runtime identity or critical symbol properties differ.

## 4. Historical V2 baseline and V3 change boundary

Recovered V2 evidence establishes historical behavior, not V3 approval:

- XAUUSD, H1
- SMA50, SMA200, RSI14
- last closed H1 bar, shift 1
- BUY, SELL, WAIT and CSV logging
- `RSI < 30 -> WAIT`; `RSI > 70 -> WAIT`; exactly 30 and 70 remain eligible
- `InpPullbackTolerance = 0.002`
- historical BUY pullback: `Close <= SMA50 * 1.002`
- historical SELL pullback: `Close >= SMA50 * 0.998`
- no identified live execution code

HD-001 must decide whether the first V3 build preserves those exact signal rules or intentionally changes them. Any strategy change requires a new strategy identity and cannot be justified by unsupported V2 profitability or validation claims.

## 5. Pending configuration freeze table

Every row is **PENDING APPROVAL**.

| Parameter / policy | Recommended draft value | Approval source |
|---|---|---|
| Exact symbol | From approved AI Bot MT5 manifest | HD-008 |
| Timeframe | H1 | Final config approval |
| Price bar | Last fully closed bar, shift 1 | P0-03 |
| Fast average | SMA, period 50, close | Final config approval |
| Slow average | SMA, period 200, close | Final config approval |
| RSI | RSI14, close | Final config approval |
| RSI exclusion | below 30 or above 70; 30/70 eligible | HD-001 bundle |
| Pullback | Exact recovered V2 0.002 one-sided rule | HD-001 |
| ATR for SL/TP | ATR14 from closed signal bar | HD-002 |
| Stop distance | 1.0 ATR | HD-002 |
| Target distance | 2.0 ATR | HD-002 |
| Starting balance | 10,000 account-currency units | HD-003 |
| Per-trade risk | 0.5% of pre-entry virtual equity | HD-003 |
| Concurrent positions | One; no pyramiding | HD-003 |
| Spread | Observed executable Bid/Ask | HD-004 |
| Slippage | One tick adverse on every entry/exit | HD-004 |
| Entry | First valid next-bar tick after closed-bar evaluation | HD-005 |
| Signal expiry | At the next H1 bar after the entry opportunity begins | HD-005 |
| Unknown intrabar order | Adverse-first with explicit ambiguity flag | HD-006 |
| Persistence | Single writer; append-only authority; derived atomic checkpoint | HD-007 |
| Broker property authority | Approved manifest plus runtime exact-match validation | HD-008 |
| Callback/action identity | Log all callbacks; stable business action keys | HD-009 |
| Equity sampling | Every accepted exposed tick; closed H1 evaluation while flat; every balance/state change | HD-010 |

No implementation may substitute a default for any unapproved or missing value.

## 6. Closed-bar evaluation and candidate signal rules

### 6.1 Bar identity and look-ahead prohibition

The logical evaluation key SHALL include strategy version, config hash, exact symbol, H1, and the closed bar's opening timestamp. Only shift 1 data from a confirmed new H1 bar event may be used. Shift 0 or a partially formed bar MUST NOT influence a signal.

All mandatory price/indicator values for the same closed bar MUST be acquired and validated before an evaluation is accepted. Processed-bar state MUST NOT advance on a partial read, failed copy, stale/misaligned buffer, invalid number, or failed durable write. The same bar must remain eligible for a retry.

### 6.2 Candidate V2-preserving signal sequence

Pending HD-001, the recommended first-baseline oracle is:

1. If any mandatory input is invalid, emit `BLOCKED_DATA` and do not commit the bar.
2. If `RSI < 30` or `RSI > 70`, result is WAIT with reason `RSI_EXTREME`.
3. If `SMA50 > SMA200` and `Close <= SMA50 * 1.002`, result is BUY.
4. If `SMA50 < SMA200` and `Close >= SMA50 * 0.998`, result is SELL.
5. Otherwise result is WAIT with one or more exact reason codes.

Equality at RSI 30 and 70 is eligible. Equality of SMA50 and SMA200 has no trend and yields WAIT. Numeric comparisons must use validated doubles; persisted prices and identity comparisons must also include normalized integer tick values.

BUY/SELL describes a signal, not an MT5 order. If state/risk/quote rules prevent a virtual entry, the event remains a signal and an additional `SIGNAL_BLOCKED` event records the reason.

## 7. Virtual entry, sizing, position, and exit

These rules remain blocked by HD-002 through HD-006 and HD-008.

### 7.1 Candidate entry

- Evaluate after a new H1 bar starts, using the just-closed shift 1 bar.
- If flat and eligible, enter virtually at the first valid current tick under HD-005.
- Long entry uses Ask plus approved adverse slippage; short entry uses Bid minus approved adverse slippage.
- Missing, crossed, non-finite, stale, or unsynchronized quotes block entry.
- A signal that reaches expiry without a valid entry emits `SIGNAL_EXPIRED`.

### 7.2 Candidate sizing

Pre-entry risk cash is `virtual_equity * approved_risk_rate`. Volume is calculated using approved stop distance, symbol tick size/tick value/contract properties, and account/profit currency. Volume must be rounded down to the valid volume step so approved risk is not exceeded. Below-minimum, above-maximum, invalid, or zero volume blocks entry. No fallback lot size is allowed.

### 7.3 Candidate SL/TP

ATR is snapshotted from the closed signal bar. Initial SL and TP are fixed for the position and rounded outward to valid tick size. Zero, missing, stale, or non-finite ATR blocks entry.

### 7.4 Candidate trigger and fill sides

- Long SL triggers when Bid is at/below SL; long TP when Bid is at/above TP.
- Short SL triggers when Ask is at/above SL; short TP when Ask is at/below TP.
- Exact touch triggers.
- A gap fills at the first executable adverse-side quote plus approved adverse slippage, not an unreachable level.
- Commissions and swap apply only from approved exact-account evidence and deterministic formulas.
- Unknown SL/TP ordering uses the approved HD-006 policy and an explicit ambiguity reason; it is never silently treated as observed tick order.

## 8. Draft state machine

| State | Meaning | Allowed next states |
|---|---|---|
| `STARTING` | Validate build/config/environment identity and acquire single-writer ownership | `RECOVERING`, `HALTED` |
| `RECOVERING` | Replay authority, verify checkpoint and derived logs | `FLAT`, `LONG`, `SHORT`, `HALTED` |
| `FLAT` | No virtual position; evaluate closed bars and WAIT/blocked events | `ENTRY_PENDING`, `HALTED` |
| `ENTRY_PENDING` | Valid BUY/SELL awaits the HD-005 entry event or expiry | `LONG`, `SHORT`, `FLAT`, `HALTED` |
| `LONG` | One open virtual long; evaluate exits and mark equity | `FLAT`, `HALTED` |
| `SHORT` | One open virtual short; evaluate exits and mark equity | `FLAT`, `HALTED` |
| `HALTED` | Fail-closed state; no new virtual entry | `RECOVERING` only after an explicit controlled restart/recovery event |

Every transition must be a durable event with before/after state, reason, action key, source identity, and sequence. An undefined transition is a fatal invariant error and enters `HALTED`. Final transitions depend on HD-004 through HD-007.

## 9. Event processing and idempotency

Candidate processing order for each callback:

1. capture the complete tick payload and assign a local monotonic event sequence;
2. validate symbol/time ordering and normalized quote values;
3. if exposed, evaluate SL/TP and equity using the approved executable side;
4. detect a new H1 bar;
5. acquire all aligned closed-bar prices and indicators;
6. calculate one signal result and reason set;
7. construct and durably accept the evaluation event;
8. only then commit processed-bar identity;
9. apply at most one idempotent state action for its stable action key;
10. emit derived CSV/metric records from accepted authority.

Identical tick payloads may be legitimate and must not be silently discarded. Signal evaluation, virtual entry, and virtual exit idempotency is enforced with stable business keys. Restart/replay must produce no duplicate position or balance effect.

## 10. Persistence, crash consistency, and reconciliation

Pending HD-007, the recommended design is:

- exactly one writer identified by run/config/symbol and protected by an exclusive lock;
- checksummed, append-only event journal as authority;
- monotonically increasing sequence and hash/CRC per complete record;
- flush policy recorded and deterministic;
- checkpoint written to a new file, flushed, validated, and atomically promoted;
- CSV and summaries are derived views, never co-equal authority;
- on restart, validate journal prefix, reject/quarantine an incomplete tail, replay complete events, compare checkpoint, and regenerate/reconcile derived views;
- any non-explainable state/log/balance mismatch enters `HALTED` without opening a virtual trade.

Crash tests must cover every boundary around event append, flush, state apply, checkpoint write/promote, and derived-log write.

## 11. Data integrity and fail-closed behavior

Before accepting an evaluation or fill, validate:

- exact symbol/manifest identity and synchronization;
- monotonic source timestamps subject to an explicitly handled duplicate callback;
- H1 bar continuity and sufficient lookback;
- all copied buffers refer to the same closed bar;
- finite positive prices, point, tick size, tick values, contract size, and valid volume constraints;
- `Ask >= Bid > 0`, unless a rejected data-quality event explains otherwise;
- quote age within an approved threshold;
- valid session and server-time mapping;
- config/build/schema hashes match the active run.

Failures emit structured data-quality/system events. They block the affected evaluation or entry and never trigger a fallback generic XAUUSD value.

## 12. Determinism and replay identity

Every run must bind:

- spec version and approved spec hash
- strategy version
- source/build identity and compiled-artifact hash
- canonical configuration serialization and SHA-256
- event/log schema version
- action-key algorithm version
- approved MT5 evidence-manifest SHA-256
- exact symbol and timeframe
- equity/metric policy version

Given the same normalized input-event stream and these identities, replay must produce the same ordered canonical business events, transitions, fills, P/L, balance, equity samples, drawdown, and summary metrics. Wall-clock ingestion timestamps and machine paths may differ but are excluded from the canonical comparison. No randomness is allowed unless a later approved model specifies a recorded seed and deterministic algorithm.

## 13. Automatic logging and audit requirements

Routine event/trade logging is automatic. Human documentation is reserved for approvals, strategy/config changes, exceptional incidents, and interpretation/decisions.

### 13.1 Common fields

Every authoritative event must contain, as applicable:

- schema version, event type, severity, reason code(s)
- run ID, event sequence, event ID, stable action key
- spec/strategy/build/config/manifest identities
- UTC time, MT5 server time, source tick `time_msc`, source closed-bar identity
- exact symbol and timeframe
- complete normalized Bid/Ask/Last/volume/flags when tick-derived
- state before and after
- input validity and data-quality flags
- checksum/integrity field

### 13.2 Required automatic events/data

- every evaluated closed bar
- BUY, SELL, WAIT
- blocked and expired signals with exact reason
- virtual entry and exit
- SL and TP definition, trigger, and fill
- observed spread and applied slippage/costs
- initial cash risk, reward target, volume, and exposure
- gross/net P/L, R-multiple, balance, equity, peak equity, currency and percentage drawdown
- all state transitions
- startup, lock acquisition, restart, replay, reconciliation, and recovery outcomes
- data-quality failures, rejected callbacks, invariant violations, and system errors
- metric snapshots and end-of-run summary

CSV may provide human-readable projections, but it must be reconcilable to the authoritative sequence and must not require manual trade/event entry.

## 14. Metric definitions

Pending HD-003, HD-004, and HD-010, the canonical formulas are:

- `closed_trades`: positions with exactly one accepted entry and one terminal exit.
- `winner`: net P/L after all approved costs is greater than zero.
- `loser`: net P/L is less than zero.
- `breakeven`: net P/L equals zero at account-currency precision.
- `win_rate = winners / closed_trades`; breakeven trades remain in the denominator.
- `gross_profit`: sum of positive net trade P/L.
- `gross_loss`: absolute value of the sum of negative net trade P/L.
- `net_pnl`: sum of all closed-trade net P/L.
- `profit_factor = gross_profit / gross_loss`; if gross loss is zero, report `UNDEFINED`, not infinity.
- `average_winner`: gross profit / winners; `UNDEFINED` when no winners.
- `average_loser`: gross loss / losers as a positive magnitude; `UNDEFINED` when no losers.
- `expectancy`: arithmetic mean net P/L over all closed trades.
- `R`: closed-trade net P/L divided by the frozen initial cash risk; zero/invalid initial risk is a fatal invariant error.
- `expectancy_R`: arithmetic mean R over all closed trades.
- `equity`: balance plus unrealized P/L after approved estimated exit costs at the executable side.
- `drawdown_currency`: prior peak canonical equity minus current canonical equity, lower-bounded at zero.
- `drawdown_percent`: drawdown currency divided by prior peak canonical equity; invalid if peak is non-positive.
- `maximum_drawdown`: maximum canonical drawdown under HD-010.
- `maximum_losing_streak`: greatest consecutive count of losing closed trades; a winner or breakeven ends a losing streak.
- BUY and SELL performance: the same formulas partitioned by entry direction.

Metric outputs must include counts and `UNDEFINED` explicitly; they must never turn missing evidence into zero or a favorable value.

## 15. Test gates

`AI_BOT_V3_TEST_PLAN.md` is normative for Levels 0–7 after approval. No level may start until all prerequisites pass. Current status:

- Level 0 — SPEC: BLOCKED
- Level 1 — STATIC SAFETY: NOT RUN
- Level 2 — COMPILE: NOT RUN
- Level 3 — UNIT / LOGIC: NOT RUN
- Level 4 — SYNTHETIC EDGE CASES: NOT RUN
- Level 5 — REPRODUCIBILITY: NOT RUN
- Level 6 — SHORT CONTROLLED PAPER TEST: NOT RUN
- Level 7 — EXTENDED PAPER/DEMO TEST: BLOCKED

## 16. Demo freeze and defect policy

Once a build is approved for an extended paper/demo run, source, strategy, configuration, spec, schema, and evidence-manifest identities are frozen.

No normal code or strategy/config change is permitted during the frozen run. If a critical defect appears:

1. stop the affected test;
2. preserve all logs and identities;
3. record the defect and impact;
4. fix under a new build/config identity;
5. rerun all required gates; and
6. start a new valid test period.

Pre-fix and post-fix observations must never be combined as one homogeneous run.

The initial Level 7 target is approximately two weeks, but duration alone is not proof. Review valid runtime, data completeness, signals, virtual trades, BUY/SELL and market-condition coverage, errors, recovery, determinism, and logging. Extend when evidence is insufficient. There is no automatic “four weeks is always enough” rule.

## 17. Open approvals

HD-001 through HD-010 are all `PENDING HUMAN DECISION`. The exact MT5 evidence bundle, final parameter/config table, spec/config/manifest hashes, and approval identities are absent. See `AI_BOT_V3_DECISION_LOG.md` and `AI_BOT_V3_KNOWN_ISSUES.md`.

## 18. Approval and authorization record

| Gate | Result | Person | Evidence |
|---|---|---|---|
| All P0 requirements resolved | NO | NONE | Known-issues register remains open |
| HD-001 through HD-010 approved | NO | NONE | Decision log pending |
| MT5 evidence manifest approved | NO | NONE | Not supplied |
| Config/version/hash frozen | NO | NONE | Not assigned |
| Final spec approved | NO | NONE | No approval record |
| Implementation authorized | NO | NONE | Explicitly prohibited in current task |

**This draft must not be used to implement, compile, attach, or run V3.**
