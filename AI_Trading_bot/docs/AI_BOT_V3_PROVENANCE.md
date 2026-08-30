# AI BOT V3 — V2 PROVENANCE

## Scope and evidence date

This record captures the recovered AI Bot V2 artifact evidence supplied and independently reported as verified on or before 2026-08-30. The artifacts are not committed to this branch. No file was copied from an MT5 directory.

Evidence classifications in this document are deliberately narrower than ordinary confidence language:

- `PROVEN`: directly established by the current artifact verification record or exact recovered source content described in that record.
- `STRONGLY EVIDENCED`: supported by direct source behavior but not independently reproduced in this repository worktree.
- `INFERRED`: plausible from names/context but not directly established.
- `NOT PROVEN`: evidence is insufficient and no claim may be made.

## Artifact identity

| Artifact | Filename | Size | SHA-256 | Verification result |
|---|---|---:|---|---|
| Recovered source | `AI_BOT_V2_Logger.mq5` | 6,961 bytes | `b98c1c59f59093c13a23ccbef1e1a9d3f8efa44c2cbf9d09432cef18001eae5e` | MATCH reported |
| Recovered compiled artifact | `AI_BOT_V2_Logger.ex5` | 12,108 bytes | `a928ea810fd8550744c9d2a988f5706a2fe403eb793bc60bb82a13991453da51` | MATCH reported |

Recovery environment:

- **STANDARD / GENERIC METAEDITOR 5 / AI BOT ENVIRONMENT**
- **NOT PEPPERSTONE**
- **NOT GOLDBOT**

## PROVEN within the current evidence record

1. The two filenames, byte sizes, and SHA-256 identities in the table above were reported as independently verified matches.
2. The recovered MQ5 contains historical V2 logic for XAUUSD, H1, SMA50, SMA200, RSI14, evaluation of the last closed H1 bar at shift 1, BUY/SELL/WAIT results, and CSV logging.
3. Historical RSI behavior is `RSI < 30 -> WAIT` and `RSI > 70 -> WAIT`; therefore exactly 30 and exactly 70 remain eligible for the other signal conditions.
4. Historical V2 declares `InpPullbackTolerance = 0.002` and applies:
   - BUY: `Close <= SMA50 * 1.002`
   - SELL: `Close >= SMA50 * 0.998`
5. The recovered MQ5 has no identified live-order execution code.
6. The recovered source has a known sequencing weakness: processed-bar state can be updated before all required indicator reads succeed.

These are historical V2 facts. They do not approve any V3 signal, risk, fill, or position rule.

## STRONGLY EVIDENCED

1. The recovered MQ5 is the historical V2 signal/logger source used to explain the documented V2 behavior.
2. V2 was intended as a non-executing logger rather than an order-sending EA.
3. The recovered source is materially better strategy provenance than the earlier informal roadmap alone.

The qualifiers remain because the source bytes and an executable verification report are not stored on this branch and were not rebuilt during this documentation-only task.

## INFERRED

1. The MQ5 and EX5 are companion source/compiled artifacts because their base filenames and recovery context match.
2. The EX5 likely implements behavior related to the recovered source.

Neither inference establishes exact compiler input/output identity.

## NOT PROVEN

1. That `AI_BOT_V2_Logger.ex5` was compiled from the exact 6,961 MQ5 bytes identified above.
2. Compiler/MetaEditor build, compile time, flags, included dependencies, or reproducible-build identity.
3. That the earlier V2 48–80 hour test completed.
4. Completeness or integrity of historical V2 CSV/test datasets.
5. Completion of GitHub issue #1's post-test validation pipeline.
6. V2 signal accuracy, simulated profit/loss, robustness, or profitability.
7. Any V3 strategy approval, configuration approval, implementation authorization, demo readiness, or live readiness.
8. Any AI Bot broker symbol/contract property not captured by the current MT5 evidence request.

## Former blocker reassessment

The former compound blocker “missing exact V2 MQ5/test provenance” is **PARTIALLY RESOLVED**:

- **CLOSED component:** recovered MQ5/EX5 identities and the historical MQ5 behavior listed above.
- **UNRESOLVED component:** exact MQ5-to-EX5 build linkage, raw historical test-data provenance, and proof that the V2 validation workflow completed.

The unresolved component forbids claims about the exact EX5 build and V2 test outcomes. It does not justify discarding the recovered source evidence, and it does not require committing either artifact to GitHub.

## Archive decision

Whether to archive the recovered MQ5 and/or EX5 in GitHub is a separate explicit human decision. This branch records identity only and does not add either file.
