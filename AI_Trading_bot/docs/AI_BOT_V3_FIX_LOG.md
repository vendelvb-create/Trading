# AI BOT V3 — FIX LOG

## Rules

Allowed status values:

- `NOT STARTED`
- `PLANNED`
- `IMPLEMENTED`
- `VERIFIED`
- `REOPENED`

`IMPLEMENTED` requires an implementation commit. `VERIFIED` additionally requires named tests and recorded results. A documentation change does not fix production code.

## Current entries

| Fix ID | Issue ID | Status | File(s) | Commit | Change summary | Tests | Verification result |
|---|---|---|---|---|---|---|---|
| FIX-001 | KI-002 | NOT STARTED | TBD | NONE | Ensure processed-bar state advances only after all mandatory indicator/price reads and the complete evaluation event are durably accepted. | Unit failure injection; retry; restart replay | NOT RUN |

No V3 production fixes are implemented or verified in this documentation workstream.
