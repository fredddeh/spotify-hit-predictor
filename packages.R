required_packages <- list(
  "pROC" = "1.18.5",
  "caret" = "6.0-94",
  "lattice" = "0.22-6",
  "ranger" = "0.17.0",
  "randomForest" = "4.7-1.2",
  "tree" = "1.0-44",
  "ggplot2" = "3.5.1",
  "leaps" = "3.2",
  "dplyr" = "1.1.4",
  "tidyr" = "1.3.1",
  "pdp" = "0.8.2",
  "tidyverse" = "2.0.0",
  "MASS" = "7.3.61",
  "gridExtra" = "2.3",
  "ISLR" = "1.4",
  "plotly" = "4.10.4",
  "knitr" = "1.49",
  "kableExtra" = "1.4.0",
  "Hmisc" = "5.2.2",
  "reshape2" = "1.4.4",
  "igraph" = "2.1.4",
  "visNetwork" = "2.1.2",
  "htmlwidgets" = "1.6.4",
  "moments" = "0.14.1",
  "car" = "3.1.3",
  "shiny" = "1.10.0",
  "glmnet" = "4.1.8",
  "patchwork" = "1.3.0",
  "stringr" = "1.5.1",
  "qqplotr" = "0.0.6",
  "corrplot" = "0.95",
  "ggcorrplot" = "0.1.4.1",
  "scales" = "1.3.0",
  "e1071" = "1.7.16",
  "xfun" = "0.48"
)

if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
library(devtools)

for (pkg in names(required_packages)) {
  if (!(pkg %in% rownames(installed.packages()))) {
    devtools::install_version(pkg, version = required_packages[[pkg]], repos = "http://cran.us.r-project.org")
  }
}
