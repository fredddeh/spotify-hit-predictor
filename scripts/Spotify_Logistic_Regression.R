# load relevant libraries
library(tidyverse)
library(ISLR)
library(dplyr)

# load the dataset
data <- read.csv("../data/spotify_billboard_merged.csv", header = TRUE)


# PREPROCESSING

# log-transforming variables
data$log_duration <- log(data$duration_ms)
data$log_sections <- log(data$sections + 1)
data$log_chorus_hit <- log(data$chorus_hit + 1)

# standardising relevant numeric predictors
standardise <- function(x) scale(x)[,1]
data$z_tempo <- standardise(data$tempo)
data$z_loudness <- standardise(data$loudness)
data$z_log_duration <- standardise(data$log_duration)
data$z_log_sections <- standardise(data$log_sections)
data$z_log_chorus_hit <- standardise(data$log_chorus_hit)

# standardising duration, sections, and chorus hit without log transformations for initial model
data$z_duration <- standardise(data$duration)
data$z_sections <- standardise(data$sections)
data$z_chorus_hit <- standardise(data$chorus_hit)

# converting categorical variables to factors
data$mode <- as.factor(data$mode)
data$key <- as.factor(data$key)
data$time_signature <- as.factor(data$time_signature)
data$on_billboard <- as.factor(data$on_billboard)


# BUILDING MODELS

# first model without log transformations
# subset variables
data_model1 <- data %>%
  dplyr::select(on_billboard, 
                danceability, energy, valence, instrumentalness, 
                speechiness,
                acousticness, liveness,
                z_tempo, z_loudness, 
                z_duration, z_sections, z_chorus_hit,
                mode, key, time_signature)

# fit logistic regression model
library(MASS)
logit_model1 <- glm(on_billboard ~ ., data = data_model1, family = binomial)

# summary statistics and coefficients
summary(logit_model1)
coef(logit_model1)
summary(logit_model1)$coef

# predicting probabilities
model1_probs = predict(logit_model1, type = "response")
model1_probs[1:10]
contrasts(data_model1$on_billboard)

# calculating accuracy
model1_pred = rep("0", nrow(data_model1))
model1_pred[model1_probs > .5] = "1"
table(model1_pred, data_model1$on_billboard)
model1_accuracy = mean(model1_pred == data_model1$on_billboard)
model1_accuracy

# train and test on initial model without log transformations
# set seed for reproducibility
set.seed(123)

# create train vector (TRUE for training data, FALSE for test data)
train1 <- sample(1:nrow(data_model1), size = 0.7 * nrow(data_model1))  # 70% train

# create training and test sets
data_train1 <- data_model1[train1, ]  # training set
data_test1 <- data_model1[-train1, ]  # test set

# ensure dimensions
dim(data_train1)  # should be ~70% of total rows
dim(data_test1)   # should be ~30% of total rows

# fit logistic regression model on training data
logit_model1_train <- glm(on_billboard ~ ., data = data_train1, family = binomial)

# predict probabilities for the test set
test_probs1 <- predict(logit_model1_train, newdata = data_test1, type = "response")

# initialize predictions as "Non-hit" (0)
test_pred1 <- rep("0", nrow(data_test1))

# update to "Hit" (1) for probabilities > 0.5
test_pred1[test_probs1 > 0.5]= "1"

# confusion matrix
table(test_pred1, data_test1$on_billboard)

# calculate accuracy
model1_train_accuracy = mean(test_pred1==data_test1$on_billboard)
model1_train_accuracy
mean(test_pred1!=data_test1$on_billboard)


# second model with log transformations
# subset variables for second model with log transformations
data_model2 <- data %>%
  dplyr::select(on_billboard, 
                danceability, energy, valence, instrumentalness, 
                speechiness,
                acousticness, liveness,
                z_tempo, z_loudness, 
                z_log_duration, z_log_sections, z_log_chorus_hit,
                mode, key, time_signature)

# build second model with log transformations
logit_model2 <- glm(on_billboard ~ ., data = data_model2, family = binomial)

# summary statistics and coefficients
summary(logit_model2)
coef(logit_model2)
summary(logit_model2)$coef

# predict probabilities
model2_probs = predict(logit_model2, type = "response")
model2_probs[1:10]
contrasts(data_model2$on_billboard)

# calculate accuracy
model2_pred = rep("0", nrow(data_model2))
model2_pred[model2_probs > .5] = "1"
table(model2_pred, data_model2$on_billboard)
(16120 + 13470) / 40560
model2_accuracy = mean(model2_pred == data_model2$on_billboard)
model2_accuracy

# train and test for second model
# set seed for reproducibility
set.seed(123)

# create train vector (TRUE for training data, FALSE for test data)
train <- sample(1:nrow(data_model2), size = 0.7 * nrow(data_model2))  # 70% train

# create training and test sets
data_train2 <- data_model2[train, ]  # training set
data_test2 <- data_model2[-train, ]  # test set

# ensure dimensions
dim(data_train2)  # should be ~70% of total rows
dim(data_test2)   # should be ~30% of total rows

# fit logistic regression model on training data
logit_model2_train <- glm(on_billboard ~ ., data = data_train2, family = binomial)

# predict probabilities for the test set
test_probs2 <- predict(logit_model2_train, newdata = data_test2, type = "response")

# initialize predictions as "Non-hit" (0)
test_pred2 <- rep("0", nrow(data_test2))

# update to "Hit" (1) for probabilities > 0.5
test_pred2[test_probs2 > 0.5]= "1"

# confusion matrix
table(test_pred2, data_test2$on_billboard)

# calculate training accuracy
model2_train_accuracy = mean(test_pred2==data_test2$on_billboard)
model2_train_accuracy
mean(test_pred2!=data_test2$on_billboard)


# third model excluding insignificant key levels and insignificant features
# count occurrences of each key level in dataset
table(data_model2$key)

# filter out rows where 'key' is not one of the significant levels (numeric values)
data_model2 <- data_model2 %>%
  dplyr::filter(key %in% c(1, 2, 3, 5, 6, 8, 10))

table(data_model2$key)  # verify counts for remaining key levels


# create new subset of data with significant variables
data_model3 <- data_model2 %>%
  dplyr::select(on_billboard, 
                danceability, energy, valence, instrumentalness, 
                speechiness, acousticness, liveness,
                z_tempo, z_loudness, mode, key)


# resplit data into training and testing sets
set.seed(123)
train3 <- sample(1:nrow(data_model3), size = 0.7 * nrow(data_model3))
data_train3 <- data_model3[train3, ]
data_test3 <- data_model3[-train3, ]

# drop unused levels in training set to avoid contrasts error
data_train3$key <- droplevels(data_train3$key)

# fit an adjusted logistic regression model (removing variables with p > 0.05)
logit_model3 <- glm(on_billboard ~ ., data = data_train3, family = binomial)
summary(logit_model3)

# predict probabilities for test set
test_probs3 = predict(logit_model3, newdata = data_test3, type = "response")

# initialize predictions as "Non-hit" (0)
test_pred3 <- rep(0, nrow(data_test3))

# update to "Hit" (1) for probabilities > 0.5
test_pred3[test_probs3 > 0.5] <- 1

# confusion matrix
table(test_pred3, data_test3$on_billboard)

# calculate training accuracy
model3_train_accuracy = mean(test_pred3 == data_test3$on_billboard)
model3_train_accuracy
(2480 + 1985) / 6041

# fourth model excluding key completely
# create final subset excluding key
data_model4 <- data_model2 %>%
  dplyr::select(on_billboard, 
                danceability, energy, valence, instrumentalness, 
                speechiness, acousticness, liveness,
                z_tempo, z_loudness, mode)

# resplit the data into training and testing sets
set.seed(123)
train4 <- sample(1:nrow(data_model4), size = 0.7 * nrow(data_model4))
data_train4 <- data_model4[train4, ]
data_test4 <- data_model4[-train4, ]

# fit the final logistic regression model
logit_model4 <- glm(on_billboard ~ ., data = data_train4, family = binomial)

# display the summary
summary(logit_model4)

# predict probabilities for test set
test_probs4 = predict(logit_model4, newdata = data_test4, type = "response")

# initialize predictions as "Non-hit" (0)
test_pred4 <- rep(0, nrow(data_test4))

# update to "Hit" (1) for probabilities > 0.5
test_pred4[test_probs4 > 0.5] <- 1

# confusion matrix
table(test_pred4, data_test4$on_billboard)

# calculate training accuracy
model4_train_accuracy = mean(test_pred4 == data_test4$on_billboard)
model4_train_accuracy

# create a new subset with predictors (including interaction term)
data_model5 <- data_model4 %>%
  dplyr::mutate(valence_energy_interaction = valence * energy)  # add interaction term

# resplit the data into training and testing sets
set.seed(123)
train5 <- sample(1:nrow(data_model5), size = 0.7 * nrow(data_model5))
data_train5 <- data_model5[train5, ]
data_test5 <- data_model5[-train5, ]

# fit the logistic regression model with the interaction term
logit_model5 <- glm(on_billboard ~ danceability + energy + valence + instrumentalness +
                      speechiness + acousticness + liveness +
                      z_tempo + z_loudness + mode + valence_energy_interaction, 
                    data = data_train5, family = binomial)

summary(logit_model5)

# predict probabilities for test set
test_probs5 = predict(logit_model5, newdata = data_test5, type = "response")

# initialize predictions as "Non-hit" (0)
test_pred5 <- rep(0, nrow(data_test5))

# update to "Hit" (1) for probabilities > 0.5
test_pred5[test_probs5 > 0.5] <- 1

# confusion matrix
table(test_pred5, data_test5$on_billboard)

# calculate training accuracy
model5_train_accuracy = mean(test_pred5 == data_test5$on_billboard)
model5_train_accuracy


# model 6 including only standardised versions of previously insignificant numeric variables
data_model_standard <- data %>%
  dplyr::select(on_billboard, 
                danceability, energy, valence, instrumentalness, 
                speechiness,
                acousticness, liveness,
                z_tempo, z_loudness, 
                z_duration, z_sections, z_chorus_hit,
                mode)

# create a new subset with predictors (including interaction term)
data_model6 <- data_model_standard %>%
  dplyr::mutate(valence_energy_interaction = valence * energy)  # add interaction term

# resplit the data into training and testing sets
set.seed(123)
train6 <- sample(1:nrow(data_model6), size = 0.7 * nrow(data_model6))
data_train6 <- data_model6[train6, ]
data_test6 <- data_model6[-train6, ]

# fit the logistic regression model with the interaction term
logit_model6 <- glm(on_billboard ~ danceability + energy + valence + instrumentalness +
                      speechiness + acousticness + liveness +
                      z_tempo + z_loudness + mode + z_duration + z_sections +
                      z_chorus_hit + valence_energy_interaction, 
                    data = data_train6, family = binomial)

summary(logit_model6)

# predict probabilities for test set
test_probs6 = predict(logit_model6, newdata = data_test6, type = "response")

# initialize predictions as "Non-hit" (0)
test_pred6 <- rep(0, nrow(data_test6))

# update to "Hit" (1) for probabilities > 0.5
test_pred6[test_probs6 > 0.5] <- 1

# confusion matrix
table(test_pred6, data_test6$on_billboard)

# calculate training accuracy
model6_train_accuracy = mean(test_pred6 == data_test6$on_billboard)
model6_train_accuracy


# PRECISION

# model 1
precision1 <- sum(test_pred1 == 1 & data_test1$on_billboard == 1) / sum(test_pred1 == 1)
recall1 <- sum(test_pred1 == 1 & data_test1$on_billboard == 1) / sum(data_test1$on_billboard == 1)

# model 2
precision2 <- sum(test_pred2 == 1 & data_test2$on_billboard == 1) / sum(test_pred2 == 1)
recall2 <- sum(test_pred2 == 1 & data_test2$on_billboard == 1) / sum(data_test2$on_billboard == 1)

# model 3
precision3 <- sum(test_pred3 == 1 & data_test3$on_billboard == 1) / sum(test_pred3 == 1)
recall3 <- sum(test_pred3 == 1 & data_test3$on_billboard == 1) / sum(data_test3$on_billboard == 1)

# model 4
precision4 <- sum(test_pred4 == 1 & data_test4$on_billboard == 1) / sum(test_pred4 == 1)
recall4 <- sum(test_pred4 == 1 & data_test4$on_billboard == 1) / sum(data_test4$on_billboard == 1)

# model 5
precision5 <- sum(test_pred5 == 1 & data_test5$on_billboard == 1) / sum(test_pred5 == 1)
recall5 <- sum(test_pred5 == 1 & data_test5$on_billboard == 1) / sum(data_test5$on_billboard == 1)

# model 6
precision6 <- sum(test_pred6 == 1 & data_test6$on_billboard == 1) / sum(test_pred6 == 1)
recall6 <- sum(test_pred6 == 1 & data_test6$on_billboard == 1) / sum(data_test6$on_billboard == 1)

# print precision and recall for each model
print(paste("Model 1 - Precision:", round(precision1, 2), "Recall:", round(recall1, 2)))
print(paste("Model 2 - Precision:", round(precision2, 2), "Recall:", round(recall2, 2)))
print(paste("Model 3 - Precision:", round(precision3, 2), "Recall:", round(recall3, 2)))
print(paste("Model 4 - Precision:", round(precision4, 2), "Recall:", round(recall4, 2)))
print(paste("Model 5 - Precision:", round(precision5, 2), "Recall:", round(recall5, 2)))
print(paste("Model 6 - Precision:", round(precision6, 2), "Recall:", round(recall6, 2)))

# F1-SCORES
# compute F1-Score
model1_f1 <- 2 * (precision1 * recall1) / (precision1 + recall1)
model2_f1 <- 2 * (precision2 * recall2) / (precision2 + recall2)
model3_f1 <- 2 * (precision3 * recall3) / (precision3 + recall3)
model4_f1 <- 2 * (precision4 * recall4) / (precision4 + recall4)
model5_f1 <- 2 * (precision5 * recall5) / (precision5 + recall5)
model6_f1 <- 2 * (precision6 * recall6) / (precision6 + recall6)

# print F1-Scores for each model
print(paste("Model 1 F1-Score:", round(model1_f1, 2)))
print(paste("Model 2 F1-Score:", round(model2_f1, 2)))
print(paste("Model 3 F1-Score:", round(model3_f1, 2)))
print(paste("Model 4 F1-Score:", round(model4_f1, 2)))
print(paste("Model 5 F1-Score:", round(model5_f1, 2)))
print(paste("Model 6 F1-Score:", round(model6_f1, 2)))


# load library for plotting ROC curve plots
library(pROC)
library(gridExtra)
library(ggplot2)

# function to create a ggplot ROC curve
plot_roc_ggplot <- function(roc_object, title) {
  auc_val <- auc(roc_object)
  data.frame(
    FPR = 1 - roc_object$specificities,
    TPR = roc_object$sensitivities
  ) %>%
    ggplot(aes(x = FPR, y = TPR)) +
    geom_line(color = "blue", linewidth = 1) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray") +
    labs(title = paste(title, "\nAUC =", round(auc_val, 3)),
         x = "False Positive Rate (1 - Specificity)",
         y = "True Positive Rate (Sensitivity)") +
    theme_bw()
}

# ROC Curve for Model 1
roc_1 <- roc(data_test1$on_billboard, test_probs1)
p1 <- plot_roc_ggplot(roc_1, "Model 1")

# ROC Curve for Model 2
roc_2 <- roc(data_test2$on_billboard, test_probs2)
p2 <- plot_roc_ggplot(roc_2, "Model 2")

# ROC Curve for Model 3
roc_3 <- roc(data_test3$on_billboard, test_probs3)
p3 <- plot_roc_ggplot(roc_3, "Model 3")

# ROC Curve for Model 4
roc_4 <- roc(data_test4$on_billboard, test_probs4)
p4 <- plot_roc_ggplot(roc_4, "Model 4")

# ROC Curve for Model 5
roc_5 <- roc(data_test5$on_billboard, test_probs5)
p5 <- plot_roc_ggplot(roc_5, "Model 5")

# ROC Curve for Model 6
roc_6 <- roc(data_test6$on_billboard, test_probs6)
p6 <- plot_roc_ggplot(roc_6, "Model 6")

# arrange the plots in a grid (2 rows, 3 columns)
grid.arrange(p1, p2, p3, p4, p5, p6, nrow = 2, ncol = 3)

