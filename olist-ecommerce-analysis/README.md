# Olist E-Commerce — Full Analysis (SQL + Python + Power BI)

End-to-end analysis of the Brazilian e-commerce marketplace **Olist**,
covering customers, orders, payments, reviews, products, and sellers —
using SQL for business-question queries, Python for exploratory data
analysis, and Power BI for the final interactive dashboard.

## Project Structure

```
olist-ecommerce-analysis/
├── README.md
├── sql/
│   └── olist_business_queries.sql   # T-SQL business-question queries
├── python/
│   └── olist_analysis.ipynb         # Full EDA across all Olist datasets
└── dashboard/
    ├── Olist_Dashboard.pdf          # Exported Power BI dashboard (all pages)
    └── dashboard_page_*.jpg         # Individual dashboard page screenshots
```

## 1. SQL Analysis (`sql/olist_business_queries.sql`)

Business-question queries run against a SQL Server database
(`Olist_database`), covering:

- **Top revenue categories** — highest-earning product categories.
- **Average order value by payment type**.
- **Delivery delay hotspots** — customer states with the worst average delays.
- **Seller performance hubs** — seller states by average prep time.
- **Customer satisfaction (NPS-style)** — promoter percentage by category.
- **Review response time** — how fast bad vs. good reviews get answered.
- **Delay vs. review score** — impact of late delivery on customer ratings.

## 2. Python Analysis (`python/olist_analysis.ipynb`)

Exploratory data analysis across all 9 Olist datasets (Customers,
Geolocation, Order Items, Payments, Reviews, Orders, Products, Sellers,
Product Category Translation). Highlights from the notebook:

- **Customers:** most customers are concentrated in São Paulo, Rio de
  Janeiro, and Minas Gerais (SP, RJ, MG are the top 3 states).
- **Payments:** credit card is the most common payment type; up to 24
  unique installment options are used.
- **Reviews:** analysis of the share of 5-star ("happy") reviews and
  support response efficiency.
- **Orders:** operational performance — cancellation rate is ~0.63%,
  with delivery timing broken down further in the notebook.
- **Products & Sellers:** category-level and seller-level performance analysis.

## 3. Power BI Dashboard (`dashboard/`)

An 8-page interactive **Olist Store Analysis Dashboard**, filterable by
Year, Month, Customer City, Review Score, Order Status, Payment Type, and
Product Category. Pages include:

| Page | Focus |
|---|---|
| Overview | Total Revenue (15.84M), Avg Score (4.09), AOV (160.58), on-time delivery rate |
| Products | Revenue & average order value by product category |
| Delivery / SLA | Seller prep time, carrier transit time, on-time vs. late orders |
| Sellers | Revenue and order volume by seller |
| Reviews & NPS | Review score distribution, NPS trend, promoter/passive/detractor split |
| Product Details | Weight, volume, freight ratio by product category |
| Time Patterns | Orders by hour/day of week, cumulative revenue |
| Photos & Descriptions | Effect of listing quality (photos, description length) on score |

> The original `.pbix` isn't included (data model too large for this repo);
> the exported PDF and page screenshots capture the full dashboard.

## Key Findings

- **Total revenue:** 15.84M | **Avg order value:** 160.58 | **Avg review score:** 4.09/5
- Credit card dominates as the payment method; SP/RJ/MG drive most customer volume.
- Delivery delay has a measurable negative impact on review scores.
- Cancellation rate is low (~0.63%), but carrier transit time (~9.3 days avg)
  is a bigger factor in delivery delay than seller prep time (~2.7 days avg).
