# AI BOT MT5 EVIDENCE REQUEST

## Purpose

Provide the one read-only evidence bundle still required to freeze a runnable V3 simulated configuration. Capture it only from the **standard/generic MetaEditor 5 / MT5 AI Bot environment**, never the Pepperstone GoldBot environment.

Do not place an order, attach a V3 EA, expose credentials, or copy the recovered MQ5/EX5 into GitHub.

## Requested bundle

Create a timestamped UTF-8 text, CSV, or JSON export plus screenshots sufficient to cross-check the export. Redact account number/login and all secrets. The export must contain:

### 1. Environment identity

- capture timestamp in ISO 8601 with local UTC offset
- broker/company name
- trade server name
- explicit confirmation that the account is demo/simulated
- account deposit currency
- MT5 terminal build
- MetaEditor build intended for later AI Bot compilation
- server time, UTC time, and local time captured together
- observed server UTC offset and daylight-saving behavior if known

### 2. Exact symbol identity

- exact symbol string, including any prefix/suffix
- symbol description and path/category
- whether the symbol is selected and currently synchronized
- first/last available H1 history timestamps
- current quote timestamp in milliseconds, Bid, Ask, Last, and flags

### 3. Price, contract, and volume properties

Capture the exact runtime values and whether each query succeeded:

- digits
- point
- trade tick size
- trade tick value
- trade tick value for profit
- trade tick value for loss
- contract size
- trade calculation mode
- base currency
- profit currency
- margin currency
- volume minimum
- volume maximum
- volume step
- volume limit
- stops level
- freeze level

### 4. Sessions and carrying costs

- quote and trade sessions for every day of the broker week
- server rollover time
- commission schedule for this exact demo account/symbol, including units and when charged; state explicitly if zero/not applicable
- swap mode, long swap, short swap, and triple-swap day; state explicitly if the approved V3 holding policy will make swap not applicable

### 5. Spread observations

Provide a raw timestamped Bid/Ask sample from normal forward quotes in the AI Bot environment, expressed both as price difference and integer points/ticks. Minimum evidence:

- at least 1,000 consecutive market-open quotes
- at least one session transition or rollover observation if feasible
- minimum, median, 95th percentile, 99th percentile, and maximum spread computed from the raw sample
- count of zero, negative, stale, or out-of-order quotes

The sample is characterization evidence only. The proposed V3 fill policy still uses the observed executable Bid/Ask for each event and does not substitute a generic fixed XAUUSD spread.

## Integrity record

For every exported file, record filename, byte size, and SHA-256. Include the exact capture command/script version or manual property-list version. Do not include credentials or account login identifiers in filenames, screenshots, or exports.

## Acceptance criteria

The request passes only when:

1. the source is explicitly the standard AI Bot MT5 environment and demo account;
2. every required field has a value or an explicit, technically justified `NOT APPLICABLE`;
3. screenshots and exported values do not conflict;
4. symbol math is internally consistent (digits/point/tick size, tick values, contract size, and volume step);
5. timestamps identify server/UTC relationship;
6. files have size and SHA-256 identity; and
7. no secret or account login is present.

If any criterion fails, P0-07, P0-10, and P0-16 remain blocked and no runnable V3 configuration may be approved.
