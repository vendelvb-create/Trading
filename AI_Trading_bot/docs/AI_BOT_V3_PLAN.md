# AI BOT V3 — PAPER TRADING

## Status
V1: Complete
V2: Complete as technical signal/logger test
V3: Design / Implementation

## Purpose
V3 introduces simulated trading and performance measurement.

V3 MUST NOT send real MT5 orders.

## Market
XAUUSD

## Timeframe
H1

## Baseline Indicators
- SMA50
- SMA200
- RSI14

## Baseline Signals
- BUY
- SELL
- WAIT

## V3 Adds
- Virtual entries
- Virtual positions
- Stop Loss
- Take Profit
- Virtual exits
- Spread modelling
- Slippage modelling
- P/L
- R-multiple
- Drawdown
- Performance statistics
- Persistent logging
- Restart/recovery

## Required Metrics
- Total trades
- Winners
- Losers
- Win rate
- Gross profit
- Gross loss
- Net P/L
- Profit factor
- Average winner
- Average loser
- Expectancy
- Maximum drawdown
- Maximum losing streak
- BUY performance
- SELL performance

## Safety
- Demo/testing only
- No CTrade
- No OrderSend
- No real orders
- No real money
- Goldbot remains separate
- Existing bots must not be modified accidentally

## Development Workflow
1. Finalize specification.
2. Codex repository audit.
3. Grok independent review.
4. Resolve disagreements.
5. Implement on separate branch.
6. Compile with zero errors.
7. Static/code review.
8. Controlled functional test.
9. Verify CSV and restart recovery.
10. Begin extended V3 demo/paper test only after acceptance criteria pass.

## Rule
Speed is useful, but correctness and reproducibility take priority.

No progression to the next version solely because a certain number of days has passed.
The measured results determine progression.
