# Insights: Cafe Sales Analysis

Based on 9,960 usable transactions (of 10,000) after cleaning. Method and treatment of bad values are in [README.md](README.md). All figures come from the queries in `sql/cafe_project.sql`.

> **Scope note:** the data contains revenue but no costs, so these are revenue insights, not profit insights.

---

## 1. Salad is the revenue leader

Salad generates **22.8% of known-item revenue** (19,070) from 3,813 units, more than any other item. It is also the top-revenue item in **all 12 months**.

## 2. Popularity and revenue tell different stories

| Item | Units | Volume rank | Revenue | Revenue rank |
|---|---|---|---|---|
| Coffee | 3,897 | **1** | 7,798 | **6** |
| Tea | 3,629 | 3 | 5,466 | 7 |
| Cookie | 3,585 | 4 | 3,589 | **8** |
| Sandwich | 3,411 | 7 | 13,664 | **2** |
| Smoothie | 3,324 | 8 | 13,320 | **3** |

- Coffee is the best-selling item by units but sixth by revenue. Cookie sells almost as much as Salad (3,585 vs 3,813) but earns about a fifth of the revenue (3,589 vs 19,070).
- Sandwich and Smoothie sell the fewest units but rank 2nd and 3rd by revenue.
- **Why:** units per item are close together (3,324 to 3,897, about a 17% spread) while unit prices range from 1.0 to 5.0. Revenue ranking is therefore mostly a price ranking, not a demand ranking.

**Implication:** low-price, high-volume items (Coffee, Tea, Cookie) are good candidates for bundling with higher-priced items or for a price test. Whether that is worthwhile depends on item margins, which this dataset does not contain.

## 3. Payment method and location do not change spending

Average order value is almost identical across payment methods (8.78 to 9.06) and locations (8.80 to 9.03), and revenue is split nearly evenly between Cash, Credit Card and Digital Wallet (about 23% each) and between In-store and Takeaway (about 30% each). No segment is meaningfully more valuable per order.

## 4. Revenue is flat across the year

Dated revenue totals 84,787. Monthly revenue stays between 6,634 (Feb) and 7,350 (Jun), and month-over-month changes stay within about 9%. There is no clear trend or seasonality, so growth-rate and moving-average queries are demonstrations of technique here, not evidence of a business trend.

## 5. The biggest finding is about data capture

- **69% of rows had at least one invalid value.**
- Payment method (3,178 invalid) and location (3,961 invalid) were the worst: about **31% of revenue has no payment method and 40% has no location**, so any comparison between payment methods or locations is approximate.
- Because `Total = Quantity x Price` held on every valid row, most numeric damage was recoverable (92% of missing totals).

**Recommendation:** enforce required fields and allowed values at the point of sale (no free-text `ERROR` or `UNKNOWN`), especially for payment method and location. Cleaning cannot recover what was never recorded.

## Caveats

- No cost data: nothing here measures profit.
- The dataset looks synthetically generated (even distributions, no seasonality), so findings describe this dataset rather than real customer behavior.
- Item-level figures exclude 480 transactions with an unresolved item; monthly figures exclude 460 transactions with no valid date.
