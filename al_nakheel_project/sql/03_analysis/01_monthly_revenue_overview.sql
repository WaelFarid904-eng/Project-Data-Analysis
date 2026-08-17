/* =============================================================
   01 - Monthly Revenue Overview (all branches combined)
   -------------------------------------------------------------
   Baseline trend query -- joins FactSales to DimCalendar to
   group revenue by calendar month using the pre-built
   YearMonth column (no need to derive year/month manually).
   ============================================================= */

USE AlNakheelDB;

SELECT
    dc.YearMonth,
    SUM(fs.TotalAmount) AS MonthlyRevenue
FROM dbo.FactSales fs
JOIN dbo.DimCalendar dc ON fs.OrderDate = dc.[Date]
GROUP BY dc.YearMonth
ORDER BY dc.YearMonth;
