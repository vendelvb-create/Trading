# AI BOT V3 — DECISION LOG

## Control

- Status: **PENDING HUMAN DECISIONS**
- Decision authority: human project owner or explicitly named delegate
- Recommendation is not approval
- An approval is valid only when `Approved choice`, `Approver`, and `Approval evidence` are populated
- Until then, every entry below is `PENDING HUMAN DECISION`

## Summary

| ID | Question | Status | Recommended baseline |
|---|---|---|---|
| HD-001 | V3 pullback rule | PENDING HUMAN DECISION | Preserve exact recovered V2 rule for the first simulator baseline |
| HD-002 | SL/TP method and values | PENDING HUMAN DECISION | ATR14 snapshot; SL 1.0 ATR, TP 2.0 ATR |
| HD-003 | Virtual balance, risk, exposure | PENDING HUMAN DECISION | 10,000 account-currency units; 0.5% risk; one position |
| HD-004 | Spread, slippage, fill policy | PENDING HUMAN DECISION | Observed Bid/Ask plus deterministic one-tick adverse slippage |
| HD-005 | Entry timing and signal expiry | PENDING HUMAN DECISION | First valid tick after the signal bar closes; one-H1-bar expiry |
| HD-006 | Intrabar/downtime ambiguity | PENDING HUMAN DECISION | Forward tick order; deterministic conservative fallback when order is unknowable |
| HD-007 | Persistence authority / writer | PENDING HUMAN DECISION | One writer; append-only journal authoritative; atomic derived checkpoint |
| HD-008 | Broker symbol / contract source | PENDING HUMAN DECISION | Explicit approved MT5 evidence manifest; reject mismatches |
| HD-009 | Tick/callback identity | PENDING HUMAN DECISION | Log all callbacks; idempotency uses stable action keys, not tick suppression |
| HD-010 | Canonical equity cadence | PENDING HUMAN DECISION | Every accepted tick while exposed; each H1 evaluation while flat |

## HD-001 — V3 pullback rule

- Date raised: 2026-08-30
- Exact question: Must the first V3 simulator preserve the recovered V2 one-sided 0.2% MA50 thresholds, use a symmetric percentage distance, use an ATR-based proximity rule, or remove the pullback condition?
- Alternatives:
  1. Exact V2: BUY `Close <= SMA50 * 1.002`; SELL `Close >= SMA50 * 0.998`.
  2. Symmetric percentage: `abs(Close - SMA50) <= 0.002 * SMA50`.
  3. ATR proximity: `abs(Close - SMA50) <= k * ATR14`, with `k` separately approved.
  4. No pullback condition.
- Recommendation: Alternative 1 for the first V3 baseline, including historical RSI eligibility at exactly 30 and 70. This isolates simulator validation from a strategy change. Treat any later change as a separately versioned experiment.
- Technical reasoning: Alternatives 2 and 3 may better match ordinary “near MA50” language, but both change which signals qualify. Alternative 3 also adds ATR to signal generation rather than only risk management.
- Safety consequence: The one-sided V2 rule can admit a close far through SMA50; this must be visible in tests and logs. A silent rewrite would invalidate V2/V3 comparisons.
- Test consequence: Boundary fixtures must cover just below, equal to, and just above both thresholds; far-through prices; RSI 29.999/30/70/70.001; and floating-point/tick normalization.
- Affected spec sections: signal eligibility, configuration, unit tests
- Config/version impact: strategy identity and config hash
- Approved choice: **NOT APPROVED**
- Approver: **NONE**
- Approval evidence: **NONE**
- Status: **PENDING HUMAN DECISION**

## HD-002 — SL/TP methodology and values

- Date raised: 2026-08-30
- Exact question: How are initial virtual SL and TP distances set and frozen for each position?
- Alternatives: fixed price/ticks; ATR multiple; recent swing/structure; or another explicit formula.
- Recommendation: Snapshot ATR14 from the closed signal bar; SL distance `1.0 * ATR14`, TP distance `2.0 * ATR14`; round protective levels outward to the broker tick size and never recalculate them after entry.
- Technical reasoning: ATR scales with XAUUSD volatility and a 2:1 reward/risk target is simple to audit. Values are proposed baselines, not evidence of profitability.
- Safety consequence: Zero, missing, stale, or non-finite ATR must block entry. Rounding must not reduce the intended stop distance.
- Test consequence: Long/short symmetry, tick rounding, gap-through, exact-touch, and zero/invalid ATR fixtures are required.
- Affected spec sections: entry, position model, exit, metrics
- Config/version impact: adds ATR period, SL multiple, TP multiple, rounding policy
- Approved choice: **NOT APPROVED**
- Approver: **NONE**
- Approval evidence: **NONE**
- Status: **PENDING HUMAN DECISION**

## HD-003 — Starting virtual balance, risk, and exposure

- Date raised: 2026-08-30
- Exact question: What virtual account balance, account currency, per-trade risk, concurrent-position limit, and exposure cap apply?
- Alternatives: fixed volume; percentage-risk sizing; fixed notional; one or multiple positions.
- Recommendation: 10,000 account-currency units, 0.5% equity risk per new trade, maximum one open XAUUSD virtual position, no pyramiding, and no entry when valid broker volume rounding would exceed approved risk or produce less than minimum volume.
- Technical reasoning: Percentage-risk sizing makes stop distance and contract metadata explicit; one position removes overlap ambiguity during the first simulator validation.
- Safety consequence: Wrong tick value, contract size, account currency, or volume step can materially corrupt risk. Missing evidence must fail closed.
- Test consequence: Test minimum/maximum/step rounding, insufficient balance, loss sequences, equity-dependent sizing, and no-pyramiding.
- Affected spec sections: account model, sizing, state machine, metrics
- Config/version impact: balance, currency, risk rate, position/exposure limits
- Approved choice: **NOT APPROVED**
- Approver: **NONE**
- Approval evidence: **NONE**
- Status: **PENDING HUMAN DECISION**

## HD-004 — Spread, slippage, and fill policy

- Date raised: 2026-08-30
- Exact question: Which executable side, spread source, slippage model, commissions, and gap fill rule determine virtual fills?
- Alternatives: zero-cost mid/close; observed Bid/Ask with no slippage; observed Bid/Ask plus fixed adverse slippage; empirically calibrated deterministic slippage.
- Recommendation: Use observed Bid/Ask from the exact AI Bot MT5 symbol. Buy entry/short exit use Ask; sell entry/long exit use Bid. Apply one broker tick of adverse slippage to every entry and exit for the first controlled run. Apply documented commission only if the MT5 evidence shows it. Block entries on missing/stale quotes. Fill a gap-triggered protective exit at the first executable adverse-side quote, not the unreachable stop/target price.
- Technical reasoning: This is conservative, deterministic, and directly replayable. It avoids generic XAUUSD spreads.
- Safety consequence: A zero-cost or mid-price model overstates results; an unbounded or random model prevents reproducibility.
- Test consequence: Test zero/normal/extreme spread, exact-touch, gap-through, quote staleness, long/short sides, and deterministic replay.
- Affected spec sections: fill engine, data quality, metrics
- Config/version impact: quote source, slippage ticks, commission, staleness threshold, gap rule
- Approved choice: **NOT APPROVED**
- Approver: **NONE**
- Approval evidence: **NONE**
- Status: **PENDING HUMAN DECISION**

## HD-005 — Entry timing and signal expiry

- Date raised: 2026-08-30
- Exact question: When does a closed-bar BUY/SELL become a virtual entry, and when does an unfilled signal expire?
- Alternatives: signal-bar close; next bar open; first valid next-bar tick; limit-style entry with a fixed expiry.
- Recommendation: Evaluate shift 1 only after a new H1 bar is detected. Enter at the first valid executable tick belonging to the new bar after evaluation. Expire the signal when the following H1 bar begins; do not enter late after downtime.
- Technical reasoning: The signal-bar close is not an executable forward price. First-next-bar tick matches forward MT5 operation and remains auditable.
- Safety consequence: Late or same-bar entries create look-ahead or stale-signal bias.
- Test consequence: Test first tick, repeated callbacks, startup mid-bar, downtime across one or more bars, and expiration boundaries.
- Affected spec sections: closed-bar gate, entry, state machine
- Config/version impact: entry event and expiry policy
- Approved choice: **NOT APPROVED**
- Approver: **NONE**
- Approval evidence: **NONE**
- Status: **PENDING HUMAN DECISION**

## HD-006 — Intrabar and downtime ambiguity fallback

- Date raised: 2026-08-30
- Exact question: How does the simulator resolve SL/TP ordering when no tick sequence exists, including gaps and downtime?
- Alternatives: lower-timeframe/tick replay; pessimistic SL-first; optimistic TP-first; discard/mark the trade unresolved.
- Recommendation: Use observed forward tick order when available. If a recovered interval proves both levels were reachable but cannot establish order, resolve adverse-first, set `AMBIGUOUS_ADVERSE_FIRST`, and keep the run eligible only if the approved test plan permits the incident count. For a gap, use the first executable quote under HD-004.
- Technical reasoning: Adverse-first is deterministic and conservative; the ambiguity flag prevents the fallback from masquerading as observed execution.
- Safety consequence: Optimistic or silent ordering can materially inflate simulated performance.
- Test consequence: Test SL-only, TP-only, both-hit, open gaps, multi-bar downtime, and replay equivalence.
- Affected spec sections: exit engine, recovery, logging, validity rules
- Config/version impact: ambiguity policy and run-validity threshold
- Approved choice: **NOT APPROVED**
- Approver: **NONE**
- Approval evidence: **NONE**
- Status: **PENDING HUMAN DECISION**

## HD-007 — Persistence authority and single-writer ownership

- Date raised: 2026-08-30
- Exact question: Which persistent record is authoritative, and which process is allowed to write it?
- Alternatives: snapshot authority; CSV/log authority; append-only event journal plus derived snapshot; external database.
- Recommendation: One EA instance per run/symbol is the only writer. A checksummed append-only event journal is authoritative. An atomic replace-on-success checkpoint is derived and accelerates restart. On restart, replay the journal, verify the checkpoint, reconcile exported CSV views, and fail closed on disagreement.
- Technical reasoning: A journal makes state transitions auditable; a derived checkpoint provides fast recovery without becoming a second authority.
- Safety consequence: Multiple writers or two co-equal authorities can create duplicate positions and irreconcilable P/L.
- Test consequence: Test concurrent-start rejection, partial journal tail, partial checkpoint, stale checkpoint, duplicate action, crash at every write boundary, and deterministic recovery.
- Affected spec sections: persistence, crash consistency, reconciliation
- Config/version impact: storage schema and lock identity
- Approved choice: **NOT APPROVED**
- Approver: **NONE**
- Approval evidence: **NONE**
- Status: **PENDING HUMAN DECISION**

## HD-008 — Broker symbol and contract source

- Date raised: 2026-08-30
- Exact question: What exact MT5 source defines symbol name and contract/volume properties for the runnable configuration?
- Alternatives: generic XAUUSD assumptions; chart symbol at runtime; manually entered values; approved captured evidence manifest plus runtime verification.
- Recommendation: Use an approved evidence manifest captured in the standard AI Bot MT5 environment. Configure the exact symbol string and verify every critical property against runtime `SymbolInfo*` values before processing. Reject any mismatch; never fall back to generic XAUUSD assumptions.
- Technical reasoning: Broker suffixes, digits, tick values, contract size, and volume constraints can differ.
- Safety consequence: A mismatch corrupts fills, risk, and P/L.
- Test consequence: Test exact match, suffix mismatch, property change, unavailable symbol, and unsupported session.
- Affected spec sections: environment, configuration, startup validation
- Config/version impact: broker/environment and symbol-manifest hash
- Approved choice: **NOT APPROVED**
- Approver: **NONE**
- Approval evidence: **NONE**
- Status: **PENDING HUMAN DECISION**

## HD-009 — Forward tick identity and duplicate callback identity

- Date raised: 2026-08-30
- Exact question: How are tick callbacks recorded and how are trade-affecting actions made idempotent when MT5 does not guarantee a globally unique tick ID?
- Alternatives: deduplicate by timestamp; deduplicate by full tick payload; assign only a local sequence; log all callbacks and deduplicate actions by stable business key.
- Recommendation: Log every accepted callback with local monotonic `event_seq` and the complete normalized source tuple (`symbol`, `time_msc`, Bid/Ask/Last in integer ticks, volume/volume_real, flags). Do not discard a callback merely because its payload matches another. Enforce idempotency with stable action keys based on strategy version, config hash, symbol, timeframe, closed signal-bar identity, position ID, and action type.
- Technical reasoning: Identical tick payloads can be legitimate, while a timestamp alone is not unique. The dangerous duplicate is a repeated state transition, not a repeated market observation.
- Safety consequence: Weak identity can duplicate entries/exits; over-aggressive tick dedupe can hide real callbacks.
- Test consequence: Test identical payloads, identical milliseconds with different prices, restart replay, repeated signal evaluation, and repeated exit callbacks.
- Affected spec sections: event identity, idempotency, logging, replay
- Config/version impact: event schema and action-key algorithm version
- Approved choice: **NOT APPROVED**
- Approver: **NONE**
- Approval evidence: **NONE**
- Status: **PENDING HUMAN DECISION**

## HD-010 — Canonical equity sampling cadence

- Date raised: 2026-08-30
- Exact question: Which observations form the canonical equity series used for drawdown and metrics?
- Alternatives: closed H1 bars only; state transitions only; every accepted tick; mixed cadence with explicit rules.
- Recommendation: Sample at every accepted tick while a virtual position is open, and at every evaluated closed H1 bar while flat; also emit a sample immediately after every balance-changing/state transition. Use the ordered canonical samples for maximum drawdown and preserve the sampling-policy version.
- Technical reasoning: Closed-bar-only sampling can miss intrabar adverse excursions. Continuous flat-account ticks add volume without changing equity.
- Safety consequence: An undersampled series can materially understate drawdown.
- Test consequence: Test intrabar troughs, gaps, transitions at identical timestamps, flat periods, restart continuation, and replay-identical maximum drawdown.
- Affected spec sections: metrics, logging, replay
- Config/version impact: equity-policy version and metric hash
- Approved choice: **NOT APPROVED**
- Approver: **NONE**
- Approval evidence: **NONE**
- Status: **PENDING HUMAN DECISION**

## Approval record

No HD-001 through HD-010 approval exists in this file. When decisions are made, record the exact selected alternative/value, approver identity, date/time with timezone, and durable approval evidence; then update the final spec and its version/hash in the same controlled change.
