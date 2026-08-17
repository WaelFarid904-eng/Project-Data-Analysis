/* =============================================================
   05 - Revenue Distribution by Channel & Payment Method
   -------------------------------------------------------------
   SUM(SUM(fs.TotalAmount)) OVER () is a "window function over
   an aggregate" pattern: the inner SUM() gives each group's
   (channel's / payment method's) revenue, and the outer
   SUM(...) OVER () -- with no PARTITION BY -- sums those group
   totals across ALL rows, producing the grand total repeated
   on every row. Dividing group revenue by that grand total
   gives revenue share without a separate subquery.
   ============================================================= */

USE AlNakheelDB;

-- A) By channel (online vs in-store)
SELECT
    fs.Channel,
    COUNT(*) AS OrderCount,
    SUM(fs.TotalAmount) AS ChannelRevenue,
    ROUND(
        SUM(fs.TotalAmount) * 100.0 / SUM(SUM(fs.TotalAmount)) OVER ()
    , 1) AS RevenuePct
FROM dbo.FactSales fs
GROUP BY fs.Channel
ORDER BY ChannelRevenue DESC;


-- B) By payment method
SELECT
    fs.PaymentMethod,
    COUNT(*) AS OrderCount,
    SUM(fs.TotalAmount) AS PaymentRevenue,
    ROUND(
        SUM(fs.TotalAmount) * 100.0 / SUM(SUM(fs.TotalAmount)) OVER ()
    , 1) AS RevenuePct
FROM dbo.FactSales fs
GROUP BY fs.PaymentMethod
ORDER BY PaymentRevenue DESC;
