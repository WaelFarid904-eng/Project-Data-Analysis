/* =============================================================
   02 - Branch Monthly Revenue + Month-over-Month Growth
   -------------------------------------------------------------
   Uses LAG() window function, partitioned per branch, to pull
   each branch's previous month's revenue into the same row so
   growth % can be computed without a self-join.

   NULLIF(prev_value, 0) guards against divide-by-zero -- if a
   branch's previous month revenue was 0 (or this is its first
   month, where LAG returns NULL), the growth % is NULL rather
   than throwing an error.

   * 100.0 (not * 100) forces decimal arithmetic; otherwise SQL
   Server may perform integer division and truncate the result.
   ============================================================= */

USE AlNakheelDB;

WITH BranchMonthly AS (
    SELECT
        db.BranchName,
        dc.YearMonth,
        SUM(fs.TotalAmount) AS MonthlyRevenue
    FROM dbo.FactSales fs
    JOIN dbo.DimCalendar dc ON fs.OrderDate = dc.[Date]
    JOIN dbo.DimBranches db ON fs.BranchID = db.BranchID
    GROUP BY db.BranchName, dc.YearMonth
)
SELECT
    BranchName,
    YearMonth,
    MonthlyRevenue,
    LAG(MonthlyRevenue, 1) OVER (PARTITION BY BranchName ORDER BY YearMonth) AS PrevMonthRevenue,
    ROUND(
        (MonthlyRevenue - LAG(MonthlyRevenue, 1) OVER (PARTITION BY BranchName ORDER BY YearMonth))
        * 100.0
        / NULLIF(LAG(MonthlyRevenue, 1) OVER (PARTITION BY BranchName ORDER BY YearMonth), 0)
    , 1) AS MoM_Growth_Pct
FROM BranchMonthly
ORDER BY BranchName, YearMonth;
