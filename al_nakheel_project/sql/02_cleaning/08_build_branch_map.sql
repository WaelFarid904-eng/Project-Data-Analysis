/* =============================================================
   08 - Build dbo.BranchNameMap
   -------------------------------------------------------------
   Design decision: store only the 5 CLEANED branch names as
   keys (not all 25 raw variants).

   Why: an earlier attempt tried to use the raw text as the
   primary key and kept hitting duplicate-key errors on rows
   that looked identical on screen but differed by invisible
   whitespace/encoding. Keying off the small, fully-controlled
   set of 5 clean names avoids that whole class of bug -- it's
   simpler and provably collision-free.

   Later, when resolving a branch for any given order, we
   recompute BranchGuess the same way (see 09) and join against
   this table on the clean name, not the raw text.
   ============================================================= */

USE AlNakheelDB;

TRUNCATE TABLE dbo.BranchNameMap;

-- BranchID values below come from dbo.DimBranches -- verify with:
-- SELECT BranchID, BranchName FROM dbo.DimBranches;
INSERT INTO dbo.BranchNameMap (BranchName_Raw, BranchID)
VALUES
    (N'الإسكندرية', 2),
    (N'أسيوط',      5),
    (N'الجيزة',     3),
    (N'القاهرة',    1),
    (N'المنصورة',   4);
