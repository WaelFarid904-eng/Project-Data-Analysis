/* =============================================================
   04 - Cancellation Rate by Branch
   -------------------------------------------------------------
   Uses SUM(CASE WHEN ... THEN 1 ELSE 0 END) to count matching
   rows within a GROUP BY -- a very common SQL pattern for
   conditional aggregation.

   Status LIKE N'ملغ%' is used instead of exact equality (=)
   as a defensive measure against Arabic spelling variants
   (e.g. "ملغى" vs "ملغي") -- same lesson learned from the
   branch-name cleaning exercise: don't rely on exact string
   match on Arabic text unless verified necessary.

   No NULLIF needed here (unlike query 02) because COUNT(*)
   can never be 0 for a branch that appears in the JOIN result.
   ============================================================= */

USE AlNakheelDB;

SELECT
    db.BranchName,
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN fs.Status LIKE N'ملغ%' THEN 1 ELSE 0 END) AS CancelledOrders,
    ROUND(
        SUM(CASE WHEN fs.Status LIKE N'ملغ%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
    , 1) AS CancelledPct
FROM dbo.FactSales fs
JOIN dbo.DimBranches db ON fs.BranchID = db.BranchID
GROUP BY db.BranchName
ORDER BY CancelledPct DESC;
