import pandas as pd
import os

# Load datasets
spotify_path = "data/spotify_raw/dataset-of-10s.csv"
billboard_path = "data/billboard_raw/hot-100-current.csv"

spotify_df = pd.read_csv(spotify_path)
billboard_df = pd.read_csv(billboard_path)

# Basic clean-up: drop NAs from Spotify columns
spotify_df = spotify_df.dropna(subset=["track", "artist"])

# Normalize for easier matching
def normalize(text):
    import re
    import unicodedata
    text = str(text).lower().strip()
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode("utf-8")
    text = re.sub(r"[\s&]+", " ", text)
    text = re.sub(r"[^a-z0-9 ]", "", text)
    text = re.sub(r"\b(feat|ft|featuring)\b", "", text)
    return re.sub(r"\s+", " ", text).strip()

spotify_df["track_norm"] = spotify_df["track"].apply(normalize)
spotify_df["artist_norm"] = spotify_df["artist"].apply(normalize)

billboard_df["title_norm"] = billboard_df["title"].apply(normalize)
billboard_df["performer_norm"] = billboard_df["performer"].apply(normalize)

# Group Billboard data for easier lookup
billboard_grouped = billboard_df.groupby(["title_norm", "performer_norm"])

# Prepare output rows
enriched_rows = []

for idx, row in spotify_df.iterrows():
    track = row["track_norm"]
    artist = row["artist_norm"]

    # Find matches in Billboard data
    matched_rows = billboard_grouped.get_group((track, artist)) if (track, artist) in billboard_grouped.groups else pd.DataFrame()

    if not matched_rows.empty:
        weeks_on_chart = matched_rows.shape[0]
        peak_pos = matched_rows["peak_pos"].min()
        first_week = matched_rows["chart_week"].min()
        last_week = matched_rows["chart_week"].max()

        enriched_rows.append({
            **row,
            "on_billboard": 1,
            "weeks_on_chart": weeks_on_chart,
            "peak_position": peak_pos,
            "first_charted": first_week,
            "last_charted": last_week
        })
    else:
        enriched_rows.append({
            **row,
            "on_billboard": 0,
            "weeks_on_chart": 0,
            "peak_position": None,
            "first_charted": None,
            "last_charted": None
        })

# Create DataFrame and save
enriched_df = pd.DataFrame(enriched_rows)
os.makedirs("data/enriched", exist_ok=True)
enriched_df.to_csv("data/spotify_billboard/spotify_10s_billboard.csv", index=False)

print("✅ Enrichment complete! Saved to data/spotify_billboard/spotify_10s_billboard.csv")
