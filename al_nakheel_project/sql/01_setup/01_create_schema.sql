-- =========================================================
-- Al Nakheel Trading Co. - Data Warehouse (Practice Project)
-- Schema design: Staging layer + Clean Star Schema
-- =========================================================

IF DB_ID('AlNakheelDB') IS NULL
BEGIN
    CREATE DATABASE AlNakheelDB;
END
GO

USE AlNakheelDB;
GO

-- Drop existing objects (safe re-run)
IF OBJECT_ID('dbo.Sales_Staging', 'U') IS NOT NULL DROP TABLE dbo.Sales_Staging;
IF OBJECT_ID('dbo.FactSales', 'U') IS NOT NULL DROP TABLE dbo.FactSales;
IF OBJECT_ID('dbo.DimProducts', 'U') IS NOT NULL DROP TABLE dbo.DimProducts;
IF OBJECT_ID('dbo.DimBranches', 'U') IS NOT NULL DROP TABLE dbo.DimBranches;
IF OBJECT_ID('dbo.DimCalendar', 'U') IS NOT NULL DROP TABLE dbo.DimCalendar;
IF OBJECT_ID('dbo.BranchNameMap', 'U') IS NOT NULL DROP TABLE dbo.BranchNameMap;
GO

-- =========================================================
-- STAGING TABLE: raw sales exactly as they came (messy on purpose)
-- Never clean data in place -- always land it raw first, then transform.
-- =========================================================
CREATE TABLE dbo.Sales_Staging (
    OrderID         NVARCHAR(20),
    OrderDate       DATE,
    CustomerName    NVARCHAR(100)   NULL,
    ProductID       INT,
    ProductName     NVARCHAR(200),
    Category        NVARCHAR(100),
    BranchID        INT,
    BranchName_Raw  NVARCHAR(200),   -- messy, 30+ variants of the same 5 branches
    Quantity        INT             NULL,
    UnitPrice       DECIMAL(10,2),
    TotalAmount     DECIMAL(12,2)   NULL,
    Channel         NVARCHAR(50),
    PaymentMethod   NVARCHAR(50),
    Status          NVARCHAR(50)
);
GO

-- =========================================================
-- DIM: Branches (source of truth, already clean)
-- =========================================================
CREATE TABLE dbo.DimBranches (
    BranchID    INT PRIMARY KEY,
    BranchName  NVARCHAR(200),
    City        NVARCHAR(100),
    Region      NVARCHAR(100),
    Address     NVARCHAR(300),
    Manager     NVARCHAR(100),
    Phone       NVARCHAR(20),
    OpenDate    DATE
);
GO

-- =========================================================
-- Mapping table: every messy raw branch text -> correct BranchID
-- This is the deliverable of Day 1 (built by YOU using SQL)
-- =========================================================
CREATE TABLE dbo.BranchNameMap (
    BranchName_Raw  NVARCHAR(200) PRIMARY KEY,
    BranchID        INT NOT NULL REFERENCES dbo.DimBranches(BranchID)
);
GO

-- =========================================================
-- DIM: Products
-- =========================================================
CREATE TABLE dbo.DimProducts (
    ProductID    INT PRIMARY KEY,
    ProductName  NVARCHAR(200),
    Category     NVARCHAR(100),
    SubCategory  NVARCHAR(100),
    Brand        NVARCHAR(100),
    UnitPrice    DECIMAL(10,2),
    CostPrice    DECIMAL(10,2)
);
GO

-- =========================================================
-- DIM: Calendar
-- =========================================================
CREATE TABLE dbo.DimCalendar (
    [Date]        DATE PRIMARY KEY,
    [Year]        INT,
    Quarter       NVARCHAR(5),
    QuarterNum    INT,
    [Month]       INT,
    MonthNameAr   NVARCHAR(20),
    MonthNameEn   NVARCHAR(20),
    [Day]         INT,
    DayOfWeek     INT,
    DayNameAr     NVARCHAR(20),
    WeekOfYear    INT,
    IsWeekend     NVARCHAR(5),
    IsHoliday     NVARCHAR(5),
    YearMonth     NVARCHAR(10),
    YearQuarter   NVARCHAR(10)
);
GO

-- =========================================================
-- FACT: clean sales table -- this is what you'll actually query
-- Filled by an ETL query in step 03 after cleaning + branch mapping
-- =========================================================
CREATE TABLE dbo.FactSales (
    OrderID         NVARCHAR(20) PRIMARY KEY,
    OrderDate       DATE,
    CustomerName    NVARCHAR(100)  NULL,
    ProductID       INT REFERENCES dbo.DimProducts(ProductID),
    BranchID        INT REFERENCES dbo.DimBranches(BranchID),
    Quantity        INT,
    UnitPrice       DECIMAL(10,2),
    TotalAmount     DECIMAL(12,2),
    Channel         NVARCHAR(50),
    PaymentMethod   NVARCHAR(50),
    Status          NVARCHAR(50)
);
GO

PRINT 'Schema created successfully.';
