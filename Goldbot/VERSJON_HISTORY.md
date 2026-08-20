# Gold Bot – Complete Project History

## 1. Project Identity

Gold Bot is a separate trading project inside the `Trading` repository.

Gold Bot must remain completely separate from:

- AI Trading Bot
- MediaServer
- XTrend Scheduling

The current project version is:

**GoldBotV3**

The current active testing version is:

**GoldBotV3**

GoldBotV3 is the version we are currently testing, optimizing, fixing and developing.

---

## 2. Version Naming and Version Rules

Gold Bot uses the following project version history:

**GoldBotV1 → GoldBotV2 → GoldBotV3**

The current project version is:

**GoldBotV3**

GoldBotV2 is the previous version.

GoldBotV1 is an earlier historical version.

GoldBotV3 is the current active development and testing version.

### Important version distinction

The project version and the internal code version are not necessarily the same thing.

The project version is:

**GoldBotV3**

A source file may contain its own internal code version such as:

`#property version "1.00"`

That internal source-code version must not be confused with the project version.

The project version remains **GoldBotV3** unless we explicitly change the project's versioning system.

---

# 3. Purpose of VERSION_HISTORY.md

This document preserves the complete Gold Bot development history.

The goal is to document:

- What we started with
- What changed
- What was fixed
- What was tested
- What worked
- What failed
- What was learned
- Why decisions were made
- What version we reached
- What remains before final production release

The history must be kept chronological and accurate.

No historical information may be invented.

Information that has not been verified must be marked:

**NOT YET VERIFIED**

---

# 4. GoldBotV1

## Status

Historical version.

## Purpose

GoldBotV1 represents the early stage of the Gold Bot project.

V1 is part of the complete historical record even where the original discussion is not currently available in the verified project material.

## Required Historical Information

The V1 history should contain:

- Original strategy
- Original entry rules
- Original exit rules
- Risk management
- Position sizing
- Indicators
- Timeframe
- Trading conditions
- Filters
- Testing method
- Test results
- Problems
- Fixes
- Major decisions
- Planned improvements

## Verification Status

The complete V1 history still needs to be reconstructed from the original Gold Bot development discussions.

Until verified:

**NOT YET VERIFIED**

No assumptions should be presented as historical facts.

---

# 5. GoldBotV2

## Status

Historical development version.

## Purpose

GoldBotV2 is the version developed after V1.

GoldBotV2 remains part of the project history and is kept separately so that it can be compared with GoldBotV3.

The current MetaTrader environment confirms that GoldBotV2 exists separately from GoldBotV3.

## Required Historical Information

The V2 history should contain:

- Changes from V1
- Strategy changes
- Entry changes
- Exit changes
- Risk-management changes
- Position-management changes
- Indicator changes
- Timeframe changes
- Filters added
- Filters removed
- Bugs discovered
- Fixes applied
- Testing performed
- Test results
- Reasons for developing V3

## Verification Status

The complete V2 discussion history still needs to be reconstructed from the original Gold Bot development material.

Until verified:

**NOT YET VERIFIED**

---

# 6. GoldBotV3

## Status

**CURRENT ACTIVE VERSION**

GoldBotV3 is the current Gold Bot version.

GoldBotV3 is the version currently being:

- Tested
- Optimized
- Debugged
- Improved
- Documented

GoldBotV3 is not yet the final production version.

---

# 7. Current GoldBotV3 Testing Environment

GoldBotV3 is currently being tested in:

**MetaTrader 5 Strategy Tester**

Current verified testing setup:

**Expert Advisor:** GoldBotV3

**Instrument:** XAUUSD

**Timeframe:** M30

GoldBotV2 remains available in MetaTrader as the previous version.

GoldBotV3 is the active version being tested.

---

# 8. GoldBotV3 Testing and Optimization

GoldBotV3 contains a significantly larger set of configurable inputs than the earlier simple test implementation.

The current version is therefore being treated as an optimization and testing build rather than as a finished fixed configuration.

The purpose of the current testing phase is to:

- Test the trading logic
- Evaluate parameter combinations
- Find stable configurations
- Identify weak configurations
- Measure performance
- Detect overfitting
- Identify bugs
- Apply fixes
- Retest
- Improve robustness
- Prepare the bot for final validation

---

# 9. Verified Gold Bot Strategy Framework

A verified Gold Bot implementation available in the project material is based on:

**XAUUSD**

The verified implementation includes a moving-average crossover framework with:

- Fast EMA
- Slow EMA
- Closed-candle evaluation
- Position limits
- Monetary TP
- Monetary SL
- Broker tick-value calculations

The verified configuration in that implementation contains:

- Lot size: 0.01
- Maximum positions: 2
- Take profit: 50 USD
- Stop loss: 25 USD
- Fast EMA: 20
- Slow EMA: 50
- Timeframe: M30
- Magic number: 26081101

These values are directly defined in the available source. :contentReference[oaicite:1]{index=1}

These values are documented as verified implementation details and must not automatically be assumed to represent every optimized GoldBotV3 configuration.

---

# 10. Verified Indicator Framework

The verified implementation creates:

- Fast EMA
- Slow EMA
- Close price as the applied price
- Configured timeframe

The available implementation creates indicator handles during initialization and releases them during deinitialization. :contentReference[oaicite:2]{index=2}

---

# 11. Verified Candle Evaluation

The verified implementation evaluates the trading logic once per newly formed M30 candle.

The last processed candle is stored to prevent repeated evaluation of the same candle. :contentReference[oaicite:3]{index=3}

---

# 12. Verified Entry Logic

The available verified implementation uses closed candles for the crossover decision.

## Bullish signal

A bullish crossover occurs when:

- The fast EMA was at or below the slow EMA on the previous closed candle.
- The fast EMA is above the slow EMA on the latest closed candle.

## Bearish signal

A bearish crossover occurs when:

- The fast EMA was at or above the slow EMA on the previous closed candle.
- The fast EMA is below the slow EMA on the latest closed candle.

This logic is directly present in the available source. :contentReference[oaicite:4]{index=4}

---

# 13. Position Management

The verified implementation counts positions associated with:

- The current symbol
- The configured magic number

If the maximum configured number of positions has been reached, another position is not opened. :contentReference[oaicite:5]{index=5} :contentReference[oaicite:6]{index=6}

Verified maximum in that implementation:

**2 open positions**

---

# 14. Risk Management Framework

The verified implementation converts monetary TP and SL values into approximate price distances using:

- Broker tick size
- Broker tick value
- Position volume

This is handled by `MoneyToPriceDistance()`. :contentReference[oaicite:7]{index=7}

If the required broker tick information is unavailable or invalid, the trade calculation stops. :contentReference[oaicite:8]{index=8}

Verified implementation targets:

**Take profit: 50 USD**

**Stop loss: 25 USD**

These values are documented as verified source parameters, not as a permanent final V3 configuration.

---

# 15. Buy Behaviour

When a bullish signal occurs in the verified implementation:

- A Buy position is opened.
- Stop loss is calculated below the ask price.
- Take profit is calculated above the ask price.
- The configured lot size is used.

The source contains the Buy execution logic. :contentReference[oaicite:9]{index=9}

---

# 16. Sell Behaviour

When a bearish signal occurs in the verified implementation:

- A Sell position is opened.
- Stop loss is calculated above the bid price.
- Take profit is calculated below the bid price.
- The configured lot size is used.

The source contains the Sell execution logic. :contentReference[oaicite:10]{index=10}

---

# 17. Error Handling

The verified implementation contains checks for:

- Invalid indicator handles
- Missing candle data
- Missing indicator-buffer data
- Invalid broker tick information
- Maximum-position limits

Indicator handles are released during deinitialization. :contentReference[oaicite:11]{index=11}

These protections are part of the verified implementation already present in the project material.

---

# 18. Current GoldBotV3 Testing State

Current state:

**ACTIVE TESTING**

GoldBotV3 is currently being tested in MetaTrader 5 Strategy Tester.

The current verified test environment is:

- GoldBotV3
- XAUUSD
- M30

The current testing phase is not complete.

The bot should not yet be considered production-ready.

---

# 19. Optimization

GoldBotV3 is being developed with optimization and testing in mind.

The current MetaTrader environment exposes many configurable parameters.

Optimization must be used carefully.

A parameter combination must not be considered good merely because it produces a high historical profit.

The following must also be evaluated:

- Drawdown
- Stability
- Number of trades
- Win rate
- Profit factor
- Average trade
- Losing periods
- Market-condition behaviour
- Robustness
- Out-of-sample performance
- Risk

---

# 20. Anti-Overfitting Rule

A high backtest result alone is not enough.

GoldBotV3 must be checked for overfitting.

A configuration that performs extremely well only on one historical period must not automatically be accepted.

The goal is a stable and robust strategy rather than a curve-fitted result.

---

# 21. Testing Results To Record

When tests are completed, the following must be documented:

- Test period
- Initial balance
- Final balance
- Net profit
- Gross profit
- Gross loss
- Profit factor
- Win rate
- Number of trades
- Average trade
- Maximum drawdown
- Maximum consecutive losses
- Maximum consecutive wins
- Long performance
- Short performance
- Equity curve
- Margin usage
- Parameter configuration
- Market conditions
- Optimization result
- Out-of-sample result

No test result may be entered until it has actually been measured.

---

# 22. Fixes and Corrections Already Established

The following project/documentation corrections have been established during the current organization work:

- Gold Bot is kept separate from AI Trading Bot.
- Gold Bot has its own folder.
- Gold Bot has its own README.
- Gold Bot has its own VERSION_HISTORY.md.
- The current project version is explicitly identified as GoldBotV3.
- GoldBotV2 remains preserved as the previous version.
- GoldBotV3 is the active testing version.
- MediaServer is kept in a separate repository.
- XTrend Scheduling is postponed.
- GitHub is used as the shared documented project source.
- Project version names are kept separate from internal source-code version numbers.
- `GoldBot_Demo.mq5` is not used as the current project-version name.
- GoldBotV3 is the name of the current project/testing version.

---

# 23. Important Naming Correction

The current project must be referred to as:

**GoldBotV3**

Not:

- GoldBot Demo
- GoldBot_Demo
- GoldBotV1
- GoldBotV2

Those names may refer to previous versions or source files, but they are not the current project version.

The current active version is:

**GoldBotV3**

---

# 24. Source File Version vs Project Version

The available source file `GoldBot_Demo.mq5` contains:

`#property version "1.00"`

This does not change the project version.

It means that the source file contains its own internal code-version field.

Project version:

**GoldBotV3**

Source-code version:

**1.00**

These values must remain separate unless the versioning system is deliberately changed later. :contentReference[oaicite:12]{index=12}

---

# 25. V3 Development Cycle

GoldBotV3 follows this development process:

**Build**

→

**Test**

→

**Measure**

→

**Find problems**

→

**Fix**

→

**Retest**

→

**Optimize**

→

**Validate**

→

**Production release**

Every important fix must be tested again.

A change must not be accepted simply because it looks better in code.

---

# 26. Remaining GoldBotV3 Work

Before GoldBotV3 can become a final production version, we must:

- Finish testing
- Review optimization results
- Test parameter stability
- Check for overfitting
- Verify entry behaviour
- Verify exit behaviour
- Verify risk management
- Measure drawdown
- Measure profitability
- Measure consistency
- Test different market conditions
- Identify remaining bugs
- Fix identified issues
- Retest after fixes
- Document final settings
- Define production criteria
- Approve the final version

---

# 27. Historical Reconstruction

The complete Gold Bot history must eventually be reconstructed as:

**GoldBotV1 → GoldBotV2 → GoldBotV3**

The historical record should contain every significant:

- Strategy change
- Parameter change
- Fix
- Bug
- Test
- Failure
- Improvement
- Decision
- Result

The original V1 and V2 conversations must be used to fill the historical gaps.

Until those details are verified:

**NOT YET VERIFIED**

No invented history is allowed.

---

# 28. Documentation Rules

Every future Gold Bot version must document:

- Version
- Purpose
- Changes
- Fixes
- Strategy
- Entry rules
- Exit rules
- Risk management
- Position management
- Indicators
- Timeframe
- Filters
- Testing configuration
- Test results
- Known issues
- Improvements
- Release criteria

Previous versions must never be silently overwritten.

---

# 29. Production Release Rules

GoldBotV3 must not be declared production-ready until:

- Strategy is fully documented.
- Entry rules are verified.
- Exit rules are verified.
- Risk management is verified.
- Testing is complete.
- Optimization has been reviewed.
- Overfitting has been evaluated.
- Drawdown has been evaluated.
- Stability has been evaluated.
- Known issues are addressed.
- Fixes are retested.
- Final parameters are documented.
- Final results are documented.
- Production criteria are met.

---

# 30. Current Project Structure

Trading repository:

- AI_Trading_bot/
- Goldbot/
- README.md
- PROJECT_CONTEXT.md
- CHANGELOG.md

Gold Bot documentation belongs inside:

`Goldbot/`

Gold Bot-specific history belongs in:

`Goldbot/VERSION_HISTORY.md`

Gold Bot must not be mixed with AI Trading Bot documentation.

---

# 31. Relationship to Other Projects

## AI Trading Bot

Separate project.

Its code, strategy, testing and documentation must remain separate from Gold Bot.

## MediaServer

Completely separate repository.

MediaServer must not be mixed into Gold Bot documentation.

## XTrend Scheduling

Delayed until a later project phase.

It is not part of the current Gold Bot development priority.

---

# 32. GitHub as Source of Truth

GitHub is the shared project source for:

- Documentation
- Decisions
- Version history
- Current status
- Testing
- Fixes
- Improvements
- Future plans

The goal is that ChatGPT, Grok and future AI tools can use the repository as a common project foundation.

AI tools must read the existing documentation before making major recommendations.

Unverified information must not be presented as confirmed information.

---

# 33. Current Gold Bot Summary

**Project:** Gold Bot

**Current project version:** GoldBotV3

**Current testing version:** GoldBotV3

**Previous version:** GoldBotV2

**Historical beginning:** GoldBotV1

**Current test platform:** MetaTrader 5 Strategy Tester

**Current test symbol:** XAUUSD

**Current test timeframe:** M30

**Current status:** Active testing / optimization / development

**Production status:** Not yet final

---

# 34. Final GoldBotV3 Definition

For the current project documentation:

**GoldBotV3 is the current active Gold Bot version being tested and optimized in MetaTrader 5.**

GoldBotV3 is the successor to GoldBotV2.

GoldBotV2 is preserved as the previous version.

GoldBotV1 remains part of the historical record.

The project path is:

**GoldBotV1 → GoldBotV2 → GoldBotV3 → Testing → Fixes → Optimization → Validation → Final Production Version**

---

# 35. Final Documentation Principle

The purpose of this document is to preserve the actual history of Gold Bot.

It must record:

**Where we started**

**What we built**

**What we changed**

**What we fixed**

**What we tested**

**What worked**

**What failed**

**What we learned**

**Where GoldBotV3 is now**

**What remains before production**

The documentation must remain accurate, chronological and verifiable.

No details may be invented to fill gaps in the historical record.
