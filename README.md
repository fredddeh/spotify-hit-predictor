# 🎵 Spotify Hit Predictor

This group data science project explores what makes a song a "hit" by analyzing Spotify audio features in relation to Billboard Hot 100 chart data. Our aim is to identify key predictors of chart success and evaluate different classification models for predicting a song’s likelihood of charting.

---

## 👥 Contributors

- Frederika Cook  
- Zhen Chen  
- Duru Demirbag  
- Hannah McAuley

---

## 🗂️ Project Structure

spotify-hit-predictor/ ├── archive/ # External raw datasets (e.g. full Billboard/Spotify collections) ├── data/ # Merged and cleaned data for analysis │ ├── billboard_raw/ │ ├── spotify_raw/ │ ├── spotify_billboard/ │ └── spotify_billboard_merged.csv ├── notebooks/ # Notebook outputs and summary visuals ├── results/ # Model outputs and evaluation metrics ├── rwd-billboard-data/ # Cloned source repo (not tracked in .git) ├── scripts/ # Main project scripts and modelling │ ├── Spotify_EDA.Rmd │ ├── Spotify_XGBoost.ipynb │ └── dataset/ + enrich, merge, and explore scripts ├── .gitignore ├── requirements.txt └── README.md


---

## 🚀 How to Run the Project

### R Markdown (EDA & Feature Analysis)
- Open `scripts/Spotify_EDA.Rmd` in **RStudio**
- Click **“Run Document”** or **Knit** to generate interactive HTML

### Jupyter Notebooks
- Open `scripts/Spotify_XGBoost.ipynb` in **VS Code** or **Jupyter Lab**
- Run all cells to train and evaluate the XGBoost model

> All file paths use **relative references** (e.g. `../data/...`) for reproducibility across systems

---

## 🧠 Models Included

| Model                | Language | File                                  |
|---------------------|----------|---------------------------------------|
| Logistic Regression | R        | `scripts/dataset/logistic_regression.R` *(external)* |
| Random Forest       | R        | `scripts/dataset/random_forest.R`     |
| XGBoost             | Python   | `scripts/Spotify_XGBoost.ipynb`       |
| SVM                 | Python   | `scripts/dataset/svm_model.ipynb`     |

---

## 📦 Required Packages

### R
Packages used in `Spotify_EDA.Rmd` include:

```r
tidyverse, plotly, caret, knitr, kableExtra, Hmisc, reshape2, igraph, visNetwork,
htmlwidgets, moments, gridExtra, car, shiny, glmnet, patchwork, stringr, qqplotr,
corrplot, ggcorrplot, scales, e1071
```

We recommend using renv to manage R dependencies.

Install via pip install -r requirements.txt
Key libraries include:

pandas, numpy, matplotlib, seaborn, xgboost, scikit-learn

Results
Model performance metrics and visualisations are saved to the /results/ folder (coming soon).

Future Improvements

- Use SHAP values for model explainability
- Perform probability calibration on classification outputs
- Package final model into a Streamlit or Shiny web app
- Add more granular audio segmentation or tempo analysis

License

For academic use only – University of Kent MSc Data Science (2025).

