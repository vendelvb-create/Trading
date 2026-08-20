# AI Trading Bot

## Current Status

**AI Trading Bot V2 is currently under active testing.**

During this test period, the bot is considered **frozen**.

No changes should be made to:

- Strategy logic
- Entry rules
- Exit rules
- Risk management
- ATR parameters
- RSI parameters
- Risk/Reward (RR)
- Pullback rules
- Filters
- Lot sizing
- Other trading parameters

The purpose of the current test is to collect unbiased data without changing the strategy during the test period.

---

## Next Step After Test Completion

When the current V2 test is complete:

1. Export and preserve the test results and CSV logs.
2. Review the collected data.
3. Run the fixed validation pipeline.
4. Evaluate the results before making any strategy changes.
5. Only then decide whether V3 should be developed or whether corrections are required.

### Planned Validation Pipeline

The validation pipeline will include:

- Walk-Forward Analysis
- Statistical Significance Testing
- Bootstrap Analysis
- BCa Bootstrap Confidence Intervals
- Monte Carlo Analysis
- Equity Curve Monte Carlo
- Jackknife Influence Analysis
- Trimmed Mean Analysis
- Winsorized Mean Analysis
- Median Absolute Deviation (MAD) / Robust Outlier Analysis

These tools are intended for **validation and analysis only**. They must not automatically alter the trading strategy.

---

## Development Rule

**No strategy changes until the current V2 test has finished and the results have been reviewed.**

Any potential improvements identified during analysis must first be documented and evaluated before implementation.

The goal is to avoid changing the strategy based on incomplete data or overfitting to a limited test period.

---

## Version Policy

Each version must be tested and evaluated before moving to the next development stage.

Changes to strategy logic, parameters, risk management, or signal generation should only be made after the relevant test results have been reviewed.

The AI Trading Bot should be developed incrementally, with clear separation between:

- Development
- Testing
- Validation
- Optimization
- Final implementation

---

## Current Test

**Version:** V2  
**Status:** Testing  
**Strategy:** Frozen during test  
**Purpose:** Data collection and validation preparation

After the V2 test is complete, the collected data will be used to determine the next development step.
