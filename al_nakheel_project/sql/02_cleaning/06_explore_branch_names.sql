/* =============================================================
   06 - Data Exploration: Branch Name Inconsistencies
   -------------------------------------------------------------
   Goal: quantify how messy dbo.Sales_Staging.BranchName_Raw is
   before deciding on a cleaning strategy.

   Finding: 6 real branches were entered as ~25 different
   text variants (extra spaces, "فرع" prefix sometimes present,
   different spellings of hamza أ/إ/ا, "-" vs " " as separator).
   ============================================================= */

USE AlNakheelDB;

SELECT
    BranchName_Raw,
    COUNT(*) AS Cnt
FROM dbo.Sales_Staging
GROUP BY BranchName_Raw
ORDER BY Cnt DESC;

-- Sanity check: how many distinct raw variants exist in total?
SELECT COUNT(DISTINCT BranchName_Raw) AS DistinctRawVariants
FROM dbo.Sales_Staging;
