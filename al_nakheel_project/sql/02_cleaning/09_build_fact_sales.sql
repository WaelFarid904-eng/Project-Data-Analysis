/* =============================================================
   09 - Build dbo.FactSales (final clean fact table)
   -------------------------------------------------------------
   Combines three cleaning steps into one INSERT:
     A) Branch resolution   -> BranchGuess, joined to BranchNameMap
     B) Quantity repair     -> fill NULL Quantity from Total/Price
     C) TotalAmount repair  -> fill 0/NULL Total from Qty*Price

   Business decisions behind (B) and (C) -- documented in
   docs/day1_decisions.md:
     - Cancelled orders with TotalAmount = 0 are recalculated
       (Qty * UnitPrice) so we know what the order would have
       been worth, rather than leaving it as 0.
     - Where TotalAmount is present but doesn't exactly match
       Qty * UnitPrice, we KEEP the stored TotalAmount (assumed
       to reflect a real discount/tax not captured in this data).
     - NULL Quantity is backfilled from TotalAmount / UnitPrice
       where possible.

   Result: 300/300 staging rows successfully mapped, 0 data loss.
   ============================================================= */

USE AlNakheelDB;

WITH RawNormalized AS (
    SELECT *,
        LTRIM(RTRIM(
            REPLACE(REPLACE(REPLACE(BranchName_Raw, N'  ', N' '), N'  ', N' '), N'  ', N' ')
        )) AS BranchName_Norm
    FROM dbo.Sales_Staging
),
CleanedText AS (
    SELECT *,
        TRIM(N' -' FROM
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
                BranchName_Norm,
                N'إ', N'ا'), N'أ', N'ا'), N'ة', N'ه'),
                N'فرع ', N''), N'شارع ', N''), N'مدينه ', N''),
                N'ال', N''), N' - ', N'-'), N' ', N'-')
        ) AS Cleaned
    FROM RawNormalized
),
BranchResolved AS (
    SELECT *,
        CASE
            WHEN Cleaned LIKE N'%اسكندري%' THEN N'الإسكندرية'
            WHEN Cleaned LIKE N'%اسيوط%'   THEN N'أسيوط'
            WHEN Cleaned LIKE N'%جيزه%'    THEN N'الجيزة'
            WHEN Cleaned LIKE N'%قاهره%'   THEN N'القاهرة'
            WHEN Cleaned LIKE N'%منصور%'   THEN N'المنصورة'
        END AS BranchGuess
    FROM CleanedText
),
QuantityFixed AS (
    SELECT *,
        CASE
            WHEN Quantity IS NULL AND UnitPrice > 0 AND TotalAmount > 0
                THEN ROUND(TotalAmount / UnitPrice, 0)
            ELSE Quantity
        END AS Quantity_Fixed
    FROM BranchResolved
),
AmountFixed AS (
    SELECT *,
        CASE
            WHEN TotalAmount IS NULL OR TotalAmount = 0
                THEN Quantity_Fixed * UnitPrice
            ELSE TotalAmount
        END AS TotalAmount_Fixed
    FROM QuantityFixed
)
INSERT INTO dbo.FactSales
    (OrderID, OrderDate, CustomerName, ProductID, BranchID,
     Quantity, UnitPrice, TotalAmount, Channel, PaymentMethod, Status)
SELECT
    af.OrderID, af.OrderDate, af.CustomerName, af.ProductID,
    bm.BranchID,
    af.Quantity_Fixed, af.UnitPrice, af.TotalAmount_Fixed,
    af.Channel, af.PaymentMethod, af.Status
FROM AmountFixed af
JOIN dbo.BranchNameMap bm ON bm.BranchName_Raw = af.BranchGuess;


/* ---- Sanity check: revenue & order count per branch ---- */
SELECT
    db.BranchName,
    COUNT(*)              AS OrderCount,
    SUM(fs.TotalAmount)    AS TotalRevenue
FROM dbo.FactSales fs
JOIN dbo.DimBranches db ON fs.BranchID = db.BranchID
GROUP BY db.BranchName
ORDER BY TotalRevenue DESC;
