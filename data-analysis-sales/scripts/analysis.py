"""
Sales of Electronics & Furniture - Exploratory Analysis
---------------------------------------------------------
Reads the raw orders data and produces summary tables and charts
into the ../outputs folder.
"""

import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
DATA_FILE = BASE / "data" / "Sales_Electronics_Furniture.xlsx"
OUT_DIR = BASE / "outputs"
OUT_DIR.mkdir(exist_ok=True)

# 1. Load data
df = pd.read_excel(DATA_FILE, sheet_name="Orders")
df["Date"] = pd.to_datetime(df["Date"])
df["Month"] = df["Date"].dt.to_period("M").astype(str)

# 2. Overall KPIs
total_sales = df["Total Price"].sum()
total_orders = len(df)
avg_order_value = df["Total Price"].mean()

kpi = pd.DataFrame({
    "Metric": ["Total Sales", "Total Orders", "Average Order Value"],
    "Value": [total_sales, total_orders, round(avg_order_value, 2)],
})
kpi.to_csv(OUT_DIR / "kpi_summary.csv", index=False)

# 3. Sales by Category
sales_by_category = df.groupby("Category")["Total Price"].sum().sort_values(ascending=False)
sales_by_category.to_csv(OUT_DIR / "sales_by_category.csv")

# 4. Sales by Sub Category
sales_by_subcategory = df.groupby("Sub Category")["Total Price"].sum().sort_values(ascending=False)
sales_by_subcategory.to_csv(OUT_DIR / "sales_by_subcategory.csv")

# 5. Sales by Branch
sales_by_branch = df.groupby("Branch")["Total Price"].sum().sort_values(ascending=False)
sales_by_branch.to_csv(OUT_DIR / "sales_by_branch.csv")

# 6. Sales by Request type (Inside/Outside/Online)
sales_by_request = df.groupby("Request")["Total Price"].sum().sort_values(ascending=False)
sales_by_request.to_csv(OUT_DIR / "sales_by_request_type.csv")

# 7. Monthly sales trend
monthly_sales = df.groupby("Month")["Total Price"].sum()
monthly_sales.to_csv(OUT_DIR / "monthly_sales_trend.csv")

# ---- Charts ----
plt.style.use("seaborn-v0_8-whitegrid")

# Category pie chart
plt.figure(figsize=(6, 6))
sales_by_category.plot.pie(autopct="%1.1f%%", ylabel="")
plt.title("Sales Share by Category")
plt.tight_layout()
plt.savefig(OUT_DIR / "chart_category_share.png", dpi=150)
plt.close()

# Branch bar chart
plt.figure(figsize=(7, 5))
sales_by_branch.plot.bar(color="#2E86AB")
plt.title("Total Sales by Branch")
plt.ylabel("Total Sales")
plt.xticks(rotation=0)
plt.tight_layout()
plt.savefig(OUT_DIR / "chart_sales_by_branch.png", dpi=150)
plt.close()

# Monthly trend line chart
plt.figure(figsize=(10, 5))
monthly_sales.plot.line(marker="o", color="#A23B72")
plt.title("Monthly Sales Trend")
plt.ylabel("Total Sales")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(OUT_DIR / "chart_monthly_trend.png", dpi=150)
plt.close()

# Subcategory bar chart
plt.figure(figsize=(8, 5))
sales_by_subcategory.plot.barh(color="#F18F01")
plt.title("Total Sales by Sub Category")
plt.xlabel("Total Sales")
plt.tight_layout()
plt.savefig(OUT_DIR / "chart_subcategory.png", dpi=150)
plt.close()

print("Analysis complete. Outputs saved to:", OUT_DIR)
print(kpi)
