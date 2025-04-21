packages <- c(
  "pROC",
  "caret",
  "lattice",
  "ranger",
  "randomForest",
  "tree",
  "ggplot2",
  "leaps",
  "dplyr",
  "tidyr",
  "pdp",
  "tidyverse",
  "MASS",
  "gridExtra",
  "ISLR"
)


for (pkg in packages) {
  if (!(pkg %in% rownames(installed.packages()))) {
    install.packages(pkg)
  }
}
