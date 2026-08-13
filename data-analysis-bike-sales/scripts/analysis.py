"""
Bike Sales - Exploratory Analysis
-----------------------------------
Reads the raw sales data (Sales sheet) and produces summary tables and
charts into the ../outputs folder.
"""

import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
DATA_FILE = BASE / "data" / "Bike_Sales_Raw.xlsx"
OUT_DIR = BASE / "outputs"
OUT_DIR.mkdir(exist_ok=True)

# 1. Load data (read_only speeds up loading large workbooks with charts/pivots)
df = pd.read_excel(
    DATA_FILE, sheet_name="Sales", engine="openpyxl",
    engine_kwargs={"read_only": True},
)

# 2. Overall KPIs
kpi = pd.DataFrame({
    "Metric": ["Total Revenue", "Total Profit", "Total Orders", "Avg Order Revenue"],
    "Value": [
        df["Revenue"].sum(),
        df["Profit"].sum(),
        len(df),
        round(df["Revenue"].mean(), 2),
    ],
})
kpi.to_csv(OUT_DIR / "kpi_summary.csv", index=False)

# 3. Revenue by Product Category
rev_by_category = df.groupby("Product_Category")["Revenue"].sum().sort_values(ascending=False)
rev_by_category.to_csv(OUT_DIR / "revenue_by_category.csv")

# 4. Revenue by Sub Category (top 10)
rev_by_subcategory = df.groupby("Sub_Category")["Revenue"].sum().sort_values(ascending=False).head(10)
rev_by_subcategory.to_csv(OUT_DIR / "revenue_by_subcategory_top10.csv")

# 5. Revenue by Country
rev_by_country = df.groupby("Country")["Revenue"].sum().sort_values(ascending=False)
rev_by_country.to_csv(OUT_DIR / "revenue_by_country.csv")

# 6. Revenue by Year
rev_by_year = df.groupby("Year")["Revenue"].sum().sort_index()
rev_by_year.to_csv(OUT_DIR / "revenue_by_year.csv")

# 7. Revenue by Customer Age Group / Gender
rev_by_age_gender = df.groupby(["Age_Group", "Customer_Gender"])["Revenue"].sum().unstack()
rev_by_age_gender.to_csv(OUT_DIR / "revenue_by_age_gender.csv")

# ---- Charts ----
plt.style.use("seaborn-v0_8-whitegrid")

# Category pie chart
plt.figure(figsize=(6, 6))
rev_by_category.plot.pie(autopct="%1.1f%%", ylabel="")
plt.title("Revenue Share by Product Category")
plt.tight_layout()
plt.savefig(OUT_DIR / "chart_category_share.png", dpi=150)
plt.close()

# Country bar chart
plt.figure(figsize=(8, 5))
rev_by_country.plot.bar(color="#2E86AB")
plt.title("Total Revenue by Country")
plt.ylabel("Revenue")
plt.xticks(rotation=30)
plt.tight_layout()
plt.savefig(OUT_DIR / "chart_revenue_by_country.png", dpi=150)
plt.close()

# Yearly trend line chart
plt.figure(figsize=(8, 5))
rev_by_year.plot.line(marker="o", color="#A23B72")
plt.title("Revenue Trend by Year")
plt.ylabel("Revenue")
plt.tight_layout()
plt.savefig(OUT_DIR / "chart_revenue_by_year.png", dpi=150)
plt.close()

# Top 10 sub-categories bar chart
plt.figure(figsize=(8, 5))
rev_by_subcategory.plot.barh(color="#F18F01")
plt.title("Top 10 Sub Categories by Revenue")
plt.xlabel("Revenue")
plt.gca().invert_yaxis()
plt.tight_layout()
plt.savefig(OUT_DIR / "chart_top_subcategories.png", dpi=150)
plt.close()

# Age group / gender grouped bar chart
plt.figure(figsize=(8, 5))
rev_by_age_gender.plot.bar()
plt.title("Revenue by Age Group and Gender")
plt.ylabel("Revenue")
plt.xticks(rotation=20)
plt.tight_layout()
plt.savefig(OUT_DIR / "chart_age_gender.png", dpi=150)
plt.close()

print("Analysis complete. Outputs saved to:", OUT_DIR)
print(kpi)
