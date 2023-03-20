library(readxl)
library(ggplot2)
library(dplyr)
library(GGally)
library(rpart)
library(rpart.plot)
library(randomForest)
library(caret)

set.seed(1)

#IMPORT DATASET HERE

df <- data.frame(titanic3)

df$id <- 1:nrow(df)

#Graph counting the survivors vs casualties

ggplot(df, aes(x= survived))+
  geom_bar(width=0.5, fill = "red")+
  geom_text(stat='count', aes(label=stat(count)), vjust=-0.5)+
  theme_classic()


#Graph measuring survivors/casualties by sex

ggplot(df, aes(x= survived, fill=sex))+
  geom_bar(position = position_dodge())+
  geom_text(stat='count', aes(label=stat(count)), position = position_dodge(width=1), vjust=-0.5)+
  theme_classic()

#Train/Test function
train_test_split = function(data, fraction = 0.8, train = TRUE) {
  total_rows = nrow(data)
  train_rows = fraction * total_rows
  sample = 1:train_rows
  if (train == TRUE) {
    return (data[sample, ])
  } else {
    return (data[-sample, ])
  }
}

#Decision Tree
set.seed(1)
trainset <- train_test_split(df, 0.7, train = TRUE)
testset <- train_test_split(df, 0.3, train = FALSE)
fit <- rpart(survived ~ pclass + sex + age, data = trainset, method = 'class')
rpart.plot(fit, extra = 106)

#testing with testset

predict(fit, df, type = 'class')
predictunseen <-predict(fit, testset, type = 'class')

tablemat <- table(testset$survived, predictunseen)
tablemat
accuracy <- sum(diag(tablemat))/sum(tablemat)
accuracy
