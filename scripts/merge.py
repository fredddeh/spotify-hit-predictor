import pandas as pd
from glob import glob

# Step 1: Read CSV files into individual dataframes
csv_files = sorted(glob('data/enriched/spotify_*_billboard.csv'))
dfs = [pd.read_csv(file) for file in csv_files]

# Step 2: Concatenate all dataframes into one
all_songs = pd.concat(dfs, ignore_index=True)

# Ensure date columns are correctly parsed
all_songs['first_charted'] = pd.to_datetime(all_songs['first_charted'], errors='coerce')
all_songs['last_charted'] = pd.to_datetime(all_songs['last_charted'], errors='coerce')

# Step 3: Merge duplicates based on 'uri'
def merge_group(group):
    merged = group.iloc[0].copy()

    # Billboard columns merge logic
    merged['on_billboard'] = int(group['on_billboard'].any())  # Convert True/False to 1/0
    merged['weeks_on_chart'] = group['weeks_on_chart'].sum()
    merged['peak_position'] = group.loc[group['peak_position'] > 0, 'peak_position'].min()

    merged['first_charted'] = group['first_charted'].min()
    merged['last_charted'] = group['last_charted'].max()

    return merged

# Apply merging logic
merged_songs = (
    all_songs.groupby('uri', as_index=False, group_keys=False)
    .apply(merge_group)
    .reset_index(drop=True)
)

# Clean up data types
merged_songs['weeks_on_chart'] = merged_songs['weeks_on_chart'].astype(int)
merged_songs['peak_position'] = merged_songs['peak_position'].fillna(0).astype(int)

# Step 4: Save the merged dataset
merged_songs.to_csv('data/spotify_billboard_merged.csv', index=False)

print(f"Merged dataset created successfully! {len(merged_songs)} unique songs saved.")
