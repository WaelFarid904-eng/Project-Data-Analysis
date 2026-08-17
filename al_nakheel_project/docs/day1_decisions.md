# Day 1 — Data Cleaning: Decisions Log

Documenting *why*, not just *what*, since these are judgment calls a real
analyst has to justify to stakeholders.

## 1. Branch name normalization
**Problem:** `Sales_Staging.BranchName_Raw` had ~25 distinct text variants
representing only 6 real branches (extra spaces, optional "فرع" prefix,
inconsistent hamza spelling, "-" vs " " as separator, even invisible
double-spaces that caused primary-key collisions).

**Decision:** Normalize progressively (collapse spaces → unify letters →
strip descriptive words → unify separators → trim), then match against a
small keyword list (`LIKE '%اسكندري%'`, etc.) rather than aiming for exact
string equality. Store the mapping in a 5-row `BranchNameMap` keyed by the
*cleaned* name, not the raw text — keying off raw text kept breaking on
whitespace/encoding differences invisible on screen.

## 2. Cancelled orders with `TotalAmount = 0`
**Decision:** Recalculate as `Quantity × UnitPrice` instead of leaving 0.
**Reasoning:** We want to know what the order *would have been worth* had
it completed, for analyses like "revenue lost to cancellations". Leaving
it at 0 would understate that.

## 3. Rows where `TotalAmount ≠ Quantity × UnitPrice` (38 rows)
**Decision:** Trust the stored `TotalAmount`, don't overwrite it.
**Reasoning:** Assumed to reflect a real discount/tax/fee not captured
elsewhere in this dataset. The stored value is closer to "what the
customer actually paid" than a recalculated one would be.

## 4. NULL `Quantity`
**Decision:** Backfill from `TotalAmount / UnitPrice` where both are
available and non-zero; otherwise leave as-is.
**Reasoning:** Derivable with confidence when we have the other two
numbers — no need to drop the row or guess with an average.

## Result
All 300 raw staging rows made it into `FactSales` — 0 rows dropped,
0 duplicate keys, branch totals reconcile to 300 orders across 5 branches.
