import pandas as pd

df = pd.read_csv("data/billboard_raw/hot-100-current.csv")

print("Total rows:", len(df))
print("Columns:", df.columns.tolist())

# Show date range
print("Earliest date:", df['chart_week'].min())
print("Latest date:", df['chart_week'].max())
head