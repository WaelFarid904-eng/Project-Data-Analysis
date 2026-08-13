# Bike Sales — Data Analysis

Exploratory data analysis of a global bike sales dataset (2011–2016), covering
Bikes, Accessories, and Clothing across multiple countries.

## Dataset

- **Source file:** `data/Bike_Sales_Raw.xlsx` (Sales sheet)
- **Rows:** ~113,036 orders
- **Columns:** Date, Day, Month, Year, Customer_Age, Age_Group, Customer_Gender,
  Country, State, Product_Category, Sub_Category, Product, Order_Quantity,
  Unit_Cost, Unit_Price, Profit, Cost, Revenue

> Note: the raw file also contains a pre-built Excel Dashboard (pivot tables,
> charts, slicers) on separate sheets — kept as-is for reference.

## Project Structure

```
data-analysis-bike-sales/
├── README.md
├── data/
│   └── Bike_Sales_Raw.xlsx           # raw dataset + original Excel dashboard
├── scripts/
│   └── analysis.py                   # exploratory analysis script
└── outputs/
    ├── kpi_summary.csv
    ├── revenue_by_category.csv
    ├── revenue_by_subcategory_top10.csv
    ├── revenue_by_country.csv
    ├── revenue_by_year.csv
    ├── revenue_by_age_gender.csv
    ├── chart_category_share.png
    ├── chart_revenue_by_country.png
    ├── chart_revenue_by_year.png
    ├── chart_top_subcategories.png
    └── chart_age_gender.png
```

## How to Run

```bash
pip install pandas matplotlib openpyxl
python scripts/analysis.py
```

## Key Findings

- **Total revenue:** ~85.27M | **Total profit:** ~32.22M | **Orders:** 113,036
- Revenue grew steadily from 2011 to a peak in 2015, then dipped slightly in 2016.
- Full breakdowns by category, country, sub-category, and customer
  age/gender are available in the `outputs/` folder.
