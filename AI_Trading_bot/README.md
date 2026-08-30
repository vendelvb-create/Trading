# AI Trading Bot

## Current controlled status

AI Bot V3 is in a **documentation and demo-readiness workstream**.

- V3 production simulator implementation is **not authorized**.
- V3 is restricted to paper/simulated trading. It must not have a reachable MT5 order-execution path.
- No V3 compile, EA attachment, short paper test, or extended paper/demo test has started.
- The V3 final specification is a draft until every P0 item, human decision, configuration value, identity hash, and approval record is resolved.
- GoldBot is a completely separate project and environment.

The recovered V2 source and compiled-artifact identities materially improve historical provenance. They establish technical evidence about the V2 signal/logger, but they do **not** prove that the earlier V2 test/validation program was completed. GitHub issue #1, "Implement post-test validation pipeline for V2," remains open as of 2026-08-30.

## Historical V2 test record

The earlier repository record says V2 was under active testing and frozen to collect unbiased data. During such a test, no strategy, entry, exit, risk, indicator, pullback, filter, sizing, or other trading-parameter change was permitted.

The historical post-test sequence was:

1. Export and preserve the V2 results and CSV logs.
2. Review the collected data.
3. Run the fixed validation pipeline.
4. Evaluate results before approving strategy changes.

No repository evidence reviewed in the current audit proves that this sequence completed. A V3 simulator that preserves the exact V2 signal rule can be specified separately, but any deliberate V3 strategy change still requires an explicit human decision and approval.

## V3 documentation entry point

Start with [`docs/AI_BOT_V3_PLAN.md`](docs/AI_BOT_V3_PLAN.md), which defines the role of each V3 document and records the current documentation audit.

The sole normative V3 strategy/simulator specification is [`docs/AI_BOT_V3_FINAL_SPEC.md`](docs/AI_BOT_V3_FINAL_SPEC.md). Its filename does not imply approval; its status banner and approval record control.

## Development rule

Do not implement, compile, attach, or run V3 until the final specification is approved and implementation is separately authorized. Passing a V3 paper/demo test would validate the simulator and evidence process only; it would not establish profitability, production readiness, live readiness, or real-money approval.
