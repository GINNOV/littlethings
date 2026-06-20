# CRAP (Change Risk Anti-Patterns) Index

This project enforces a **CRAP score ≤ 30** for all functions.

The CRAP index is a metric that identifies code that is risky to change. It combines Cyclomatic Complexity (CC) with Code Coverage to ensure that complex logic is well-tested.

## The Formula

$$CRAP(f) = CC(f)^2 \times (1 - Coverage(f))^3 + CC(f)$$

Where:
- **CC(f)**: Cyclomatic Complexity of the function (number of decision points + 1).
- **Coverage(f)**: Test coverage of the function (expressed as a decimal from 0 to 1).

## Why CRAP ≤ 30?

- **High CC + Low Coverage = Danger**: If a function is complex but has no tests, any change is likely to introduce a bug.
- **Incentivizes Testing**: To lower a CRAP score, you must either simplify the function (lower CC) or add more tests (higher Coverage).
- **Quality Gate**: New code should not be merged if it violates this threshold.

## How to Check

Run the automated CRAP report:

```bash
npm run test:crap
```

This will:
1. Run all unit tests with coverage enabled.
2. Perform a complexity analysis using ESLint.
3. Generate a per-function report.
4. Fail (exit 1) if any function exceeds the threshold.

## How to Fix a Violation

If a function fails the CRAP check, you have two options:
1. **Refactor**: Split the function into smaller, simpler pieces to reduce Cyclomatic Complexity.
2. **Test**: Add unit tests that cover the branches of the function.

Note: Because coverage is cubed in the formula, increasing coverage is the most effective way to lower an extremely high CRAP score quickly.
