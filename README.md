# Spotify Hit Predictor

This project was developed as part of a group assignment for our MSc Data Science postgraduate. Our objective was to explore the relationship between audio features and commercial music success by building a machine learning model capable of predicting whether a song is likely to chart on the Billboard Hot 100.

We combined datasets containing Spotify's audio features with historical Billboard chart data to investigate which musical traits—such as energy, valence, danceability, and instrumentalness—most strongly predict chart performance. 

The project includes:
- **Exploratory Data Analysis (EDA)** of audio features and class distributions.
- **Feature engineering** and preprocessing, including handling skewness, standardisation, and encoding.
- **Model comparison** using Logistic Regression, Random Forest, XGBoost, and Support Vector Machines (SVM).
- **Evaluation metrics** including accuracy, precision, recall, F1 score, ROC AUC, and interpretability tools (e.g. SHAP, PDPs).
- **Insights** into audio trends in hit songs and their emotional or structural patterns.

We also reflect on model limitations, particularly the influence of temporal trends and the challenge of sampling non-hits fairly.


---

## Data Sources

This project uses two main datasets:

**Billboard Hot 100 Chart Data**

Weekly chart positions from the 1950s to 2025 were sourced from sourced from the [UTData GitHub repository](https://github.com/utdata/rwd-billboard-data).

**Spotify Audio Features**

Audio analysis data for tracks released from the 1960s to 2010s was obtained from [Kaggle – The Spotify Hit Predictor Dataset](https://www.kaggle.com/datasets/theoverman/the-spotify-hit-predictor-dataset), which includes audio features (e.g., energy, valence, tempo) derived from the Spotify API.

Both datasets were used strictly for academic and non-commercial purposes as part of an MSc Data Science group project.

**Acknowledgements**

- This project makes use of the [Spotipy](https://pypi.org/project/spotipy/) and [billboard.py](https://pypi.org/project/billboard.py/) Python libraries for accessing Spotify and Billboard APIs.

- Special thanks to [Spotify](https://developer.spotify.com/) for providing detailed audio analysis through the [Spotify Web API – Audio Features Reference](https://developer.spotify.com/documentation/web-api/reference/get-audio-features/).

All data was used under the terms of public availability and for non-commercial academic purposes only.

**Note on Dataset Attributes**

The Spotify dataset includes features such as:

`danceability`, `energy`, `valence`, `speechiness`, `acousticness`, `instrumentalness`, `liveness`, `tempo`, `duration_ms`

Structural features like `chorus_hit` and `sections`

The original outcome variable in the dataset is `target`, where 1 indicates a Billboard hit and 0 represents a non-hit (based on absence from the chart and genre-based filtering). However, we engineered a refined target variable, `on_billboard`, to reflect matched records using our custom merging process with official Billboard chart data.

A full description of features and the methodology for defining non-hits is available on the [Kaggle dataset page](https://www.kaggle.com/datasets/theoverman/the-spotify-hit-predictor-dataset).


---

## Contributors

This group project was completed by MSc Data Science students at the University of Kent, 2025.

- Frederika Cook  
- Zhen Chen  
- Duru Demirbag  
- Hannah McAuley

---

## Project Structure

```
spotify-hit-predictor/
│
├── data/
│   ├── billboard_raw/
│   │   └── hot-100-current.csv
│   │
│   ├── spotify_raw/
│   │   ├── dataset-of-60s.csv
│   │   ├── dataset-of-70s.csv
│   │   ├── dataset-of-80s.csv
│   │   ├── dataset-of-90s.csv
│   │   ├── dataset-of-00s.csv
│   │   └── dataset-of-10s.csv
│   │
│   ├── spotify_billboard/
│   │   ├── spotify_60s_billboard.csv
│   │   ├── spotify_70s_billboard.csv
│   │   ├── spotify_80s_billboard.csv
│   │   ├── spotify_90s_billboard.csv
│   │   ├── spotify_00s_billboard.csv
│   │   └── spotify_10s_billboard.csv
│   │
│   └── spotify_billboard_merged.csv
│
├── scripts/
│   ├── Spotify_EDA.Rmd                     # Exploratory Data Analysis & Feature Prep
│   ├── Spotify_Logistic_Regression.R       # Model 1
│   ├── Spotify_Random_Forest.R             # Model 2
│   ├── Spotify_SVM.ipynb                   # Model 3
│   ├── Spotify_XGBoost.ipynb               # Model 4
│   └── dataset/                            # Supporting scripts for data enrichment and merging
│       ├── enrich_spotify_with_billboard.py
│       ├── explore_hot100_data.py
│       └── merge.py
│
├── report_presentation/
│   ├── Assessment 2 Report_Spotify Hit Predictor.docx
│   └── Assessment 2 Presentation_Spotify Hit Predictor.pptx
│
├── requirements.txt
├── .gitignore
└── README.md

```

---

## How to Run the Project

### R Scripts (EDA & Feature Analysis)
- Open `scripts/Spotify_EDA.Rmd`, `Spotify_Logistic_Regression.R`, or `Spotify_Random_Forest.R` in **RStudio** or your preferred R environment.
- Ensure that you have installed all required packages.
- To view the EDA file `scripts/Spotify_EDA.Rmd`, click **“Run Document”** to generate interactive HTML.

### Jupyter Notebooks
- Open `scripts/Spotify_XGBoost.ipynb` or `scripts/Spotify_SVM.ipynb` in **Jupyter Lab**, **VS Code** or your preferred Python environment.
- Run all cells to reproduce model results.

> All file paths use **relative references** (e.g. `../data/...`) for reproducibility across systems

---

## Models Included

| Model                | Language | File                                  |
|---------------------|----------|---------------------------------------|
| Logistic Regression | R        | `scripts/Spotify_Logistic_regression.R`       |
| Random Forest       | R        | `scripts/Spotify_Random_Forest.R`             |
| XGBoost             | Python   | `scripts/Spotify_XGBoost.ipynb`       |
| SVM                 | Python   | `scripts/Spotify_SVM.ipynb`     |

---

## Required Packages

This project uses both **Python** and **R** for analysis and modeling.


### Python 

Install all required Python packages using:

```
pip install -r requirements.txt
```


### R

All required R packages are listed in the `packages.R` file.  
To install them, run the following command in your R console or RStudio:

```r
source("packages.R")
```


---

## Results

## 📈 Results

Model results and evaluation outputs are included in the final written report and presentation:

`report_presentation/Assessment 2 Report_Spotify Hit Predictor.docx`  
`report_presentation/Assessment 2 Presentation_Spotify Hit Predictor.pptx`

These files contain:
- Confusion matrices and performance metrics (accuracy, precision, recall, F1).
- ROC and threshold curves for all classifiers.
- SHAP summary and interaction plots.
- Partial dependence plots (PDPs).
- Feature importance rankings (native and permutation-based).

All results can also be reproduced by running the code files provided in the `scripts/` folder.

**Summary:**  
XGBoost and Random Forest models performed best overall (Accuracy = 78%, AUC = 0.86), revealing strong non-linear relationships between audio features and chart success. Support Vector Machine (SVM) also showed strong performance (Accuracy = 76%, AUC = 0.84), capturing complex boundaries but with higher computational cost. Simpler models like Logistic Regression achieved respectable accuracy (>70%) and helped highlight interpretable trends.

---

## Future Improvements

- Incorporate temporal features or decade-specific models to reflect evolving music trends.
- Improve the sampling of non-hit tracks to reduce genre/popularity bias.
- Explore additional audio features (e.g. lyrical content, album metadata).
- Package the workflow into an interactive web app or API.
- Expand model calibration for real-world recommendation scenarios.


---

## Disclaimer

This project was developed for academic purposes only. It does not represent commercial forecasting tools, nor does it endorse or predict success in the music industry.


---

## License

For academic and educational use only.  
© University of Kent – MSc Data Science Group Project (2025)

