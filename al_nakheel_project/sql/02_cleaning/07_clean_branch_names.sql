/* =============================================================
   07 - Text Normalization: Reducing 25 raw variants down to 5
   -------------------------------------------------------------
   Strategy (order matters! see notes below):
     1. Collapse multiple consecutive spaces into one.
        (Found some rows had double/triple spaces, e.g.
        "القاهرة  - مدينة نصر" -- invisible on screen but
        caused duplicate-key errors later.)
     2. Normalize Arabic letter variants BEFORE removing words,
        because some words appear with either spelling
        (e.g. "مدينة" vs "مدينه"). Normalizing first means one
        REPLACE for the word covers both spellings.
     3. Remove descriptive words that don't identify the branch
        ("فرع", "شارع", "مدينه", "ال" definite article).
     4. Normalize separators (spaces/dashes) to a single "-".
     5. TRIM stray leading/trailing spaces AND dashes -- plain
        LTRIM/RTRIM only strips spaces, not dashes, so a leading
        dash could survive without this.

   This CTE (CleanedText) is reused by 08_build_branch_map.sql.
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
                N'إ', N'ا'), N'أ', N'ا'), N'ة', N'ه'),   -- normalize hamza + taa marbuta
                N'فرع ', N''), N'شارع ', N''), N'مدينه ', N''),  -- strip descriptive words
                N'ال', N''), N' - ', N'-'), N' ', N'-')          -- strip "ال", unify separators
        ) AS Cleaned
    FROM RawNormalized
)
SELECT DISTINCT BranchName_Raw, Cleaned
FROM CleanedText
ORDER BY Cleaned;

-- Verify: how many distinct cleaned values remain? (target: 5)
-- SELECT COUNT(DISTINCT Cleaned) FROM CleanedText;  -- run separately, CTE scope is single-statement
