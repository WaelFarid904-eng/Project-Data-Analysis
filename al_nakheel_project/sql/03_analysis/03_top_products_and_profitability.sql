/* =============================================================
   03 - Top Products & Category Profitability
   -------------------------------------------------------------
   Two related but distinct questions:
     A) Which products sell the most BY QUANTITY?
     B) Which category is most PROFITABLE (revenue - cost),
        not just highest revenue?

   Note: top-selling-by-quantity is NOT the same ranking as
   top-selling-by-revenue -- a cheap product can outsell an
   expensive one in units while generating far less revenue.
   See query A's results for a concrete example in this dataset.
   ============================================================= */

USE AlNakheelDB;

-- A) Top 5 products by quantity sold
SELECT TOP 5
    dp.ProductName,
    SUM(fs.Quantity) AS TotalQtySold,
    SUM(fs.TotalAmount) AS TotalRevenue
FROM dbo.FactSales fs
JOIN dbo.DimProducts dp ON fs.ProductID = dp.ProductID
GROUP BY dp.ProductName
ORDER BY TotalQtySold DESC;


-- B) Category profitability (revenue - cost, using DimProducts.CostPrice)
-- Note: alias TotalRevenue/TotalCost can't be reused within the same
-- SELECT to compute TotalProfit -- SQL Server evaluates all SELECT
-- expressions before aliases exist, so the full expression is repeated.
SELECT
    dp.Category,
    SUM(fs.TotalAmount) AS TotalRevenue,
    SUM(fs.Quantity * dp.CostPrice) AS TotalCost,
    SUM(fs.TotalAmount) - SUM(fs.Quantity * dp.CostPrice) AS TotalProfit
FROM dbo.FactSales fs
JOIN dbo.DimProducts dp ON fs.ProductID = dp.ProductID
GROUP BY dp.Category
ORDER BY TotalProfit DESC;
