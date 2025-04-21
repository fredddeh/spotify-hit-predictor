# Set the file path
file_path <- "../data/spotify_billboard_merged.csv"


library(tidyr)
library(dplyr)
library(leaps)
library(ggplot2)

library(tree)
library(randomForest)
library(ranger)
library(caret)
library(pROC)
data<- read.csv(file_path, stringsAsFactors = FALSE)
dim(data)
head(data)

# check whether duplicate rows, and here is no duplicate row
sum(duplicated(data))  
#no duplicate in uri, can delete it as it just id of song without any extra information
sum(duplicated(data$uri))  


#ckeck whether missing value in the dataset
colSums(is.na(data))


#use NA instead any " ", "na" and "null" in the data set
char_cols <- sapply(data, is.character)

data[, char_cols] <- lapply(data[, char_cols], function(col) {
  col[tolower(col) %in% c("", "na", "null")] <- NA
  return(col)
})
colSums(is.na(data))


sum(data$on_billboard == 1 & is.na(data$first_charted))
sum(data$on_billboard == 1 & is.na(data$last_charted))

sum(data$on_billboard == 0 & data$weeks_on_chart==0)

sum(data$on_billboard == 0 & data$peak_position==0)

#-------------------------------------removing columns part----------------------


#remove uri as it just id of the songs set by spotify
data <- data %>% select(-uri)
data <- data %>% mutate(duration_min = duration_ms / 60000)
data <- data %>% select(-duration_ms)


data <- data %>% select(-weeks_on_chart)
data <- data %>% select(-peak_position)
data <- data %>% select(-first_charted)
data <- data %>% select(-last_charted)

data<-data%>%select(-track)
data<-data%>%select(-track_norm)
data<-data%>%select(-artist)
data<-data%>%select(-artist_norm)
data<-data%>%select(-target)

#-------------------------------------categorical & binary variables--------------------------------------
data$key<-as.factor(data$key)
data$time_signature<-as.factor(data$time_signature)
data$mode<-as.factor(data$mode)
data$on_billboard <- factor(data$on_billboard, labels = c("no", "yes"))


#-------------------------------------random forest------------------------------


#train and test data
set.seed(123)
train_index<-sample(seq_len(nrow(data)),size = 0.8*nrow(data))
train_data<- data[train_index,]
test_data<- data[-train_index,]



# basic model with default parameter
set.seed(123)
base_rf <- randomForest(on_billboard ~ ., data = train_data, importance = TRUE)

print(base_rf)
plot(base_rf)


#prediction 
pred_rf <- predict(base_rf, newdata = test_data)
prob_rf <- predict(base_rf, newdata = test_data, type = "prob")[,2]

# confusion martrix
confusionMatrix(pred_rf, test_data$on_billboard)

# ROC & AUC
roc_obj <- roc(test_data$on_billboard, prob_rf)
plot(roc_obj, col = "blue", main = "ROC Curve (Baseline)")
auc(roc_obj)





# try different mtry
tune_grid <- expand.grid(mtry = c(3, 5, 6, 7, 9, 11))

# cv
ctrl <- trainControl(
  method = "cv",
  number = 10,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  seeds = c(
    rep(list(rep(123, 6)), 10),  
    123                          
  )
)


set.seed(123)
fm_tuned <- train(
  on_billboard ~ .,
  data = train_data,
  method = "rf",
  trControl = ctrl,
  tuneGrid = tune_grid,
  metric = "ROC",
  ntree = 200
)

# optimal parameter
print(fm_tuned)
plot(fm_tuned)

#the best model with mtry=5
#
rf_pred1 <- predict(fm_tuned, newdata = test_data)
rf_prob1 <- predict(fm_tuned, newdata = test_data, type = "prob")[, "yes"]

# confusion matrix when mtry=5, the ac =78.88%
confusionMatrix(rf_pred1, test_data$on_billboard)

# ROC & AUC
# the roc curve and auc of 0.8663 shows model after change parameter is better than the default one
roc_obj2 <- roc(test_data$on_billboard, rf_prob1)
plot(roc_obj2, col = "darkgreen", main = "ROC Curve (Tuned RF)")
auc(roc_obj2)



#the importance rank of variables
importance_df1 <- varImp(fm_tuned)$importance
importance_df1$Feature <- rownames(importance_df1)

ggplot(importance_df1, aes(x = reorder(Feature, Overall), y = Overall)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Feature Importance (Random Forest)", x = "Feature", y = "Importance")



# try model drop the variables that i think not important, which are key and time_signtaure here.
set.seed(123)
sd_rf <- randomForest(on_billboard ~danceability+energy+loudness+mode+speechiness+instrumentalness+liveness +valence+tempo +chorus_hit+sections+duration_min , data = train_data, importance = TRUE)

print(sd_rf)
plot(sd_rf)


#prediction 
pred_rf2 <- predict(sd_rf, newdata = test_data)
prob_rf2 <- predict(sd_rf, newdata = test_data, type = "prob")[,2]

# confusion martrix
confusionMatrix(pred_rf2, test_data$on_billboard)

# ROC & AUC
roc_obj <- roc(test_data$on_billboard, prob_rf2)
plot(roc_obj, col = "blue", main = "ROC Curve (Baseline)")
auc(roc_obj)

#different mrty
set.seed(123)
sd_tuned <- train(
  on_billboard ~ danceability+energy+loudness+mode+speechiness+instrumentalness+liveness +valence+tempo +chorus_hit+sections+duration_min,
  data = train_data,
  method = "rf",
  trControl = ctrl,
  tuneGrid = tune_grid,
  metric = "ROC",
  ntree = 200
)


# optimal parameter
print(sd_tuned)
plot(sd_tuned)

#the best model with mtry=3
rf_pred3 <- predict(sd_tuned, newdata = test_data)
rf_prob3 <- predict(sd_tuned, newdata = test_data, type = "prob")[, "yes"]

# confusion matrix when mtry=3, the ac =77.27%
confusionMatrix(rf_pred3, test_data$on_billboard)

# ROC & AUC
# the roc curve and auc of 0.8507 shows model after change parameter is better than the default one
roc_obj2 <- roc(test_data$on_billboard, rf_prob3)
plot(roc_obj2, col = "darkgreen", main = "ROC Curve (Tuned RF)")
auc(roc_obj2)



#the importance rank of variables
importance_df2 <- varImp(sd_tuned)$importance
importance_df2$Feature <- rownames(importance_df2)

ggplot(importance_df2, aes(x = reorder(Feature, Overall), y = Overall)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Feature Importance (Random Forest)", x = "Feature", y = "Importance")


# try model drop the variables that i think not important which is mode here
set.seed(123)
td_rf <- randomForest(on_billboard ~danceability+energy+loudness+mode+speechiness+instrumentalness+liveness +valence+tempo +chorus_hit+sections+duration_min , data = train_data, importance = TRUE)

print(td_rf)
plot(td_rf)


#prediction 
pred_rf4 <- predict(td_rf, newdata = test_data)
prob_rf4 <- predict(td_rf, newdata = test_data, type = "prob")[,2]

# confusion martrix
confusionMatrix(pred_rf4, test_data$on_billboard)

# ROC & AUC
roc_obj <- roc(test_data$on_billboard, prob_rf4)
plot(roc_obj, col = "blue", main = "ROC Curve (Baseline)")
auc(roc_obj)

#try different mtry
set.seed(123)
td_tuned <- train(
  on_billboard ~ danceability+energy+loudness+speechiness+instrumentalness+liveness +valence+tempo +chorus_hit+sections+duration_min,
  data = train_data,
  method = "rf",
  trControl = ctrl,
  tuneGrid = tune_grid,
  metric = "ROC",
  ntree = 200
)


# optimal parameter
print(td_tuned)
plot(td_tuned)

#the best model with mtry=3
rf_pred5 <- predict(td_tuned, newdata = test_data)
rf_prob5 <- predict(td_tuned, newdata = test_data, type = "prob")[, "yes"]

# confusion matrix when mtry=3, the ac =77.11%
confusionMatrix(rf_pred5, test_data$on_billboard)

# ROC & AUC
# the roc curve and auc of 0.8503 shows model after change parameter is better than the default one
roc_obj2 <- roc(test_data$on_billboard, rf_prob5)
plot(roc_obj2, col = "darkgreen", main = "ROC Curve (Tuned RF)")
auc(roc_obj2)



#the importance rank of variables
importance_df3 <- varImp(td_tuned)$importance
importance_df3$Feature <- rownames(importance_df3)

ggplot(importance_df3, aes(x = reorder(Feature, Overall), y = Overall)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Feature Importance (Random Forest)", x = "Feature", y = "Importance")

#then run model 1 with mtry=5, ntree =500 to get a more stable model
tune_grid <- expand.grid(mtry = 5)  

set.seed(123)
rf_500 <- train(
  on_billboard ~ .,
  data = train_data,
  method = "rf",
  trControl = ctrl,
  tuneGrid = tune_grid,
  metric = "ROC",
  ntree = 500
)

#prediction
rf_500_pred <- predict(rf_500, newdata = test_data)
rf_500_prob <- predict(rf_500, newdata = test_data, type = "prob")[, "yes"]

confusionMatrix(rf_500_pred, test_data$on_billboard)

# AUC
roc_500 <- roc(test_data$on_billboard, rf_500_prob)
plot(roc_500, col = "purple", main = "ROC (ntree = 500)")
auc(roc_500)

#---------------------------------------explain the model-------------------------

#plot the feature importance for model 1 with ntree=500
library(pdp)
var_names <- setdiff(names(train_data), "on_billboard")

par(mfrow = c(4, 4))

for (var in var_names) {
  pd <- partial(fm_tuned, pred.var = var, prob = TRUE, train = train_data)
  plot(pd, main = paste("PDP:", var), xlab = var, ylab = "Predicted Probability")
}
















#---------------------------------------just for try--------------------------------------------------------------
tune_grid <- expand.grid(mtry = c(3, 5, 6, 7, 9))


#drop the section
set.seed(42)
four_tuned <- train(
  on_billboard ~ danceability+energy+loudness+speechiness+instrumentalness+liveness +valence+tempo +chorus_hit+duration_min,
  data = train_data,
  method = "rf",
  trControl = ctrl,
  tuneGrid = tune_grid,
  metric = "ROC",
  ntree = 200
)


# optimal parameter
print(four_tuned)
plot(four_tuned)

#the best model with mtry=3
#
rf_pred <- predict(four_tuned, newdata = test_data)
rf_prob <- predict(four_tuned, newdata = test_data, type = "prob")[, "yes"]

# confusion matrix show the accuracy not improved
confusionMatrix(rf_pred, test_data$on_billboard)

# ROC & AUC
# the roc curve and auc not improved
roc_obj2 <- roc(test_data$on_billboard, rf_prob)
plot(roc_obj2, col = "darkgreen", main = "ROC Curve (Tuned RF)")
auc(roc_obj2)



#the importance rank of variables
importance_df <- varImp(four_tuned)$importance
importance_df$Feature <- rownames(importance_df)

ggplot(importance_df, aes(x = reorder(Feature, Overall), y = Overall)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Feature Importance (Random Forest)", x = "Feature", y = "Importance")




tune_grid <- expand.grid(mtry = c(3, 5, 6, 7, 9))


# drop the chorus_hit, accuarcy and AUC not improved 
set.seed(42)
five_tuned <- train(
  on_billboard ~ danceability+energy+loudness+speechiness+instrumentalness+liveness +valence+tempo+duration_min,
  data = train_data,
  method = "rf",
  trControl = ctrl,
  tuneGrid = tune_grid,
  metric = "ROC",
  ntree = 200
)


# optimal parameter
print(five_tuned)
plot(five_tuned)


rf_pred <- predict(five_tuned, newdata = test_data)
rf_prob <- predict(five_tuned, newdata = test_data, type = "prob")[, "yes"]

# confusion matrix 
confusionMatrix(rf_pred, test_data$on_billboard)

# ROC & AUC
roc_obj2 <- roc(test_data$on_billboard, rf_prob)
plot(roc_obj2, col = "darkgreen", main = "ROC Curve (Tuned RF)")
auc(roc_obj2)



#the importance rank of variables
importance_df <- varImp(five_tuned)$importance
importance_df$Feature <- rownames(importance_df)

ggplot(importance_df, aes(x = reorder(Feature, Overall), y = Overall)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Feature Importance (Random Forest)", x = "Feature", y = "Importance")



