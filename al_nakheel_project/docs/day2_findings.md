# Day 2 — Analysis: Key Findings

Quick reference of the headline numbers from `sql/03_analysis/`, useful
for interview talking points ("what did you find?").

## Branch performance
- 5 branches, revenue and order volume vary significantly by branch and month.
- **الجيزة - الدقي** has the highest cancellation rate (15.4%), more than
  3x the best-performing branch, **أسيوط - شارع المحطة** (4.5%).

## Products & profitability
- Top-seller by *quantity* (جوال شاومي 14, 58 units) is not the top
  earner by *revenue* — a pattern worth flagging: unit volume and
  revenue contribution can rank products very differently.
- Category profit: "إلكترونيات" generates ~2x the absolute profit of
  "أجهزة منزلية" (1.72M vs 0.87M EGP), though profit *margin* is similar
  (~29.5% vs ~30.1%) — the gap is driven by sales volume, not margin.

## Channel & payment mix
- In-store ("متجر") accounts for 77.6% of revenue vs 22.4% online —
  relevant if evaluating investment in the online channel.
- Cash is the leading payment method (42.1% of revenue), card-based
  payment ("فيزا") only 14.9%.

## SQL techniques used
`LAG()` window function for month-over-month growth · `SUM(CASE WHEN...)`
conditional aggregation · `SUM(SUM(...)) OVER ()` for revenue-share-of-total
without a subquery · `NULLIF()` to guard against divide-by-zero.
