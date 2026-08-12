# Sales of Electronics & Furniture — Data Analysis

Exploratory data analysis of a retail sales dataset covering **Electronics**
and **Furniture** orders across three branches (Olyya, Qussor, Hamraa) during 2020.

## Dataset

- **Source file:** `data/Sales_Electronics_Furniture.xlsx`
- **Rows:** ~4,265 orders
- **Columns:** Index, Date, Branch, Lat, Long, Request (Inside/Outside/Online),
  Item, Category, Sub Category, Quantity, Price, Total Price

## Project Structure

```
data-analysis-sales/
├── README.md
├── data/
│   └── Sales_Electronics_Furniture.xlsx   # raw dataset
├── scripts/
│   └── analysis.py                        # exploratory analysis script
└── outputs/
    ├── kpi_summary.csv
    ├── sales_by_category.csv
    ├── sales_by_subcategory.csv
    ├── sales_by_branch.csv
    ├── sales_by_request_type.csv
    ├── monthly_sales_trend.csv
    ├── chart_category_share.png
    ├── chart_sales_by_branch.png
    ├── chart_monthly_trend.png
    └── chart_subcategory.png
```

## How to Run

```bash
pip install pandas matplotlib openpyxl
python scripts/analysis.py
```

The script reads the raw Excel file, computes KPIs and breakdowns, and
saves CSV tables + PNG charts into `outputs/`.

## Key Findings

- **Total sales:** ~11.16M | **Total orders:** 4,265 | **Avg order value:** ~2,617
- Electronics generated more revenue than Furniture overall.
- Sales show noticeable peaks around July and November.
- Branch performance and order channel (Inside / Outside / Online) breakdowns
  are available in `outputs/sales_by_branch.csv` and
  `outputs/sales_by_request_type.csv`.

## Charts

| Chart | Description |
|---|---|
| `chart_category_share.png` | Revenue share: Electronics vs Furniture |
| `chart_sales_by_branch.png` | Total sales per branch |
| `chart_monthly_trend.png` | Monthly sales trend across 2020 |
| `chart_subcategory.png` | Revenue by sub-category (Mobiles, Laptops, TV, Salon, etc.) |
