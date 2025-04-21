# Spotify Hit Predictor

This group data science project explores what makes a song a "hit" by analyzing Spotify audio features in relation to Billboard Hot 100 chart data. Our aim is to identify key predictors of chart success and evaluate different classification models for predicting a song’s likelihood of charting.

---

## Contributors

- Frederika Cook  
- Zhen Chen  
- Duru Demirbag  
- Hannah McAuley

---

## Project Structure

```
spotify-hit-predictor/
├── data/
│ ├── billboard_raw/
│ ├── spotify_raw/
│ ├── spotify_billboard/ # Combined
│ └── spotify_billboard_merged.csv # Merged and cleaned data for analysis
├── scripts/ # Main project scripts and modelling
│ ├── Spotify_EDA.Rmd
│ ├── Spotify_XGBoost.ipynb
│ └── dataset/ # Code to enrich, merge, and explore scripts
│   ├── enrich_spotify_with_billboard.py
│   ├── explore_hot100_data.py
│   └── merge.py
├── .gitignore
├── requirements.txt
└── README.md
```

---

## How to Run the Project

### R Markdown (EDA & Feature Analysis)
- Open `scripts/Spotify_EDA.Rmd` in **RStudio**
- Click **“Run Document”** or **Knit** to generate interactive HTML

### Jupyter Notebooks
- Open `scripts/Spotify_XGBoost.ipynb` in **VS Code** or **Jupyter Lab**
- Run all cells to train and evaluate the XGBoost model

> All file paths use **relative references** (e.g. `../data/...`) for reproducibility across systems

---

## Models Included

| Model                | Language | File                                  |
|---------------------|----------|---------------------------------------|
| Logistic Regression | R        | `scripts/logistic_regression.R`       |
| Random Forest       | R        | `scripts/random_forest.R`             |
| XGBoost             | Python   | `scripts/Spotify_XGBoost.ipynb`       |
| SVM                 | Python   | `scripts/Spotify_SVM.ipynb`           |

---

## Required Packages

### R
Packages used in `Spotify_EDA.Rmd` include:

```r
tidyverse, plotly, caret, knitr, kableExtra, Hmisc, reshape2, igraph, visNetwork,
htmlwidgets, moments, gridExtra, car, shiny, glmnet, patchwork, stringr, qqplotr,
corrplot, ggcorrplot, scales, e1071
```

We recommend using renv to manage R dependencies.

Install via:

```
pip install -r requirements.txt
```

Key libraries include:

```
pandas, numpy, matplotlib, seaborn, xgboost, scikit-learn
```

Results
Model performance metrics and visualisations are saved to the /results/ folder (coming soon).

Future Improvements

???????

License

For academic use only – University of Kent MSc Data Science (2025).

