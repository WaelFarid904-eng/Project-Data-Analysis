# Cafe Sales: Data Cleaning & Analysis in SQL

A SQL-only project: take a deliberately corrupted cafe transactions dataset, clean it with a documented, reproducible process, and answer business questions with CTEs and window functions.

**Tool:** SQLite  |  **Data:** 10,000 transactions, Jan–Dec 2023  |  **Findings:** see [INSIGHTS.md](INSIGHTS.md)

---

## 1. The dataset

The "Cafe Sales – Dirty Data" dataset from Kaggle, included in this repo as `data/dirty_cafe_sales.csv`.

| Column | Meaning |
|---|---|
| `Transaction ID` | Unique id (10,000 unique, no duplicates) |
| `Item` | Coffee, Tea, Cake, Cookie, Juice, Smoothie, Sandwich, Salad |
| `Quantity`, `Price Per Unit`, `Total Spent` | Numeric fields |
| `Payment Method` | Cash, Credit Card, Digital Wallet |
| `Location` | In-store, Takeaway |
| `Transaction Date` | 2023-01-01 to 2023-12-31 |

## 2. Data quality problems found

Invalid values appear in three forms: empty string, the text `ERROR`, and the text `UNKNOWN`. **6,911 of 10,000 rows (69%) contain at least one of them.** Only 3,089 rows are fully valid, so deleting dirty rows would have destroyed most of the dataset.

| Column | Invalid values |
|---|---|
| Item | 969 |
| Quantity | 479 |
| Price Per Unit | 533 |
| Total Spent | 502 |
| Payment Method | 3,178 |
| Location | 3,961 |
| Transaction Date | 460 (159 empty, 159 `UNKNOWN`, 142 `ERROR`) |

## 3. Approach: four layers

```
raw_sales  ->  stg_sales  ->  clean_sales  ->  v_sales
(CSV as-is)   (standardize)   (recover)       (analysis view)
```

| Layer | What it does | Why |
|---|---|---|
| `raw_sales` | The CSV imported untouched, every column TEXT | Original is never modified, so every step can be re-run and audited |
| `stg_sales` | Converts `''` / `ERROR` / `UNKNOWN` to `NULL`, casts to proper types | One consistent way to represent "missing"; `SUM`/`AVG` ignore NULL, while the text `ERROR` would corrupt them |
| `clean_sales` | Recovers missing values with business rules (below) | Keeps rows instead of deleting them |
| `v_sales` | View of rows with a known `Total Spent` | Every analysis query reuses one definition of "usable row" |

## 4. How each problem was handled

**Principle: recover only when the data proves the answer. Never guess.**

| Problem | Treatment | Result |
|---|---|---|
| `ERROR`/`UNKNOWN`/empty in any column | Standardized to `NULL` with nested `NULLIF` | One missing-value representation |
| Missing `Total Spent` | `Quantity x Price Per Unit` | 462 recovered |
| Missing `Quantity` | `Total Spent / Price Per Unit` | 441 recovered |
| Missing `Price Per Unit` | `Total Spent / Quantity` | 495 recovered |
| Missing `Item` | Look up by price **only where one item has that price** (1.0 = Cookie, 1.5 = Tea, 2.0 = Coffee, 5.0 = Salad) | 489 recovered |
| Item with ambiguous price | Price 3.0 fits Cake and Juice; 4.0 fits Smoothie and Sandwich. Left `NULL` | 480 remain unknown |
| Missing `Payment Method` / `Location` | Nothing in the data can derive them. Labelled `'Unknown'` so the rows still appear in group-bys | Reported as its own category |
| Invalid `Transaction Date` | Cannot be derived from any other column. Left `NULL`, excluded from time-based queries only | 460 rows |
| Rows where two of {qty, price, total} are missing | One equation cannot solve two unknowns. Not guessed | 40 rows excluded from `v_sales` |

**Why the recovery rule is safe:** before using `Total = Quantity x Price`, I tested it on every row where all three values were valid. It held on every one of them (0 violations). I also checked that each item has exactly one price in the valid data.

**What I deliberately did not do:**
- No mean/median imputation. It invents numbers and distorts distributions.
- No picking one of two possible items for ambiguous prices.
- No deleting every row with a problem (would have lost 69% of the data).

### Before / after

| Column | NULL before | NULL after |
|---|---|---|
| Total Spent | 502 | 40 |
| Quantity | 479 | 38 |
| Price Per Unit | 533 | 38 |
| Item | 969 | 480 |
| Transaction Date | 460 | 460 (not recoverable) |

Rows kept: **9,960 of 10,000 (99.6%)**.

## 5. SQL techniques used

| Technique | Where |
|---|---|
| `NULLIF`, `COALESCE`, `CAST`, `CASE` | Standardization and recovery |
| Layered tables and a `VIEW` | Reproducible pipeline |
| `strftime` | Month extraction from text dates |
| CTEs (`WITH`) | Reusable intermediate results |
| Aggregate over window: `SUM(SUM(x)) OVER ()` | Percent of total without a subquery |
| `RANK() OVER (...)` and `PARTITION BY` | Item rankings, best item per month |
| `LAG()` | Month-over-month growth |
| Running total and `AVG() OVER (ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)` | Cumulative revenue, 3-month moving average |
| `UNION ALL` | Before/after quality report |

## 6. Analysis queries

| # | Question |
|---|---|
| Q1 | Revenue, units and revenue share per item |
| Q2 | Which items rank high in volume but low in revenue, and the reverse? |
| Q3 | Revenue share and average order value by payment method and location |
| Q4 | Monthly revenue and month-over-month growth |
| Q5 | Running total and 3-month moving average |
| Q6 | Top-revenue item in every month |
| Q7 | Revenue by order quantity |

## 7. Limitations

- **No cost data**, so this is revenue analysis, not profitability.
- Each item has a single fixed price, so revenue differences between items are driven by price.
- Item-level queries exclude the 480 unresolved items; time-based queries exclude the 460 undated rows (about 4.7% of revenue).
- The dataset appears synthetic (uniform distributions, no seasonality), so conclusions describe this data, not real cafe behavior.

## 8. How to run

1. Open SQLite (for example DB Browser for SQLite, or the `sqlite3` CLI).
2. Import `data/dirty_cafe_sales.csv` as a table named `raw_sales` with **all columns as TEXT**.
3. Run `sql/cafe_project.sql` from top to bottom: Part 1 builds the clean layers, Part 2 runs the analysis queries.

## 9. Repository structure

```
.
├── README.md
├── INSIGHTS.md
├── data/
│   └── dirty_cafe_sales.csv
└── sql/
    └── cafe_project.sql
```
