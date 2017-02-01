# Loading the data
credit.data <- read.csv("http://homepages.uc.edu/~maifg/7040/credit0.csv", header = T)
head(credit.data)

# 1st is id- not needed
# 2nd is response
# 3rd to 63th are explanatory variables

# Create 90% data set

set.seed(260423)

# Test-Train sampling 90%
subset <- sample(nrow(credit.data), nrow(credit.data) * 0.9)
credit.train = credit.data[subset, ]
credit.test = credit.data[-subset, ]

# Logistic Regression
credit.glm <- glm(Y~.-id, family=binomial, data=credit.train)
credit.summary <- summary(credit.glm)

## Stepwise variable selection
credit.glm.step <- step(credit.glm)

## Stepwise variable selection with BIC
credit.glm.step_bic <- step(credit.glm, k = log(nrow(credit.train)))

# Testing base model with model with just a few variables
credit.glm1 <- glm(Y ~ X3 + X8 + X11_2, family = binomial, credit.train)
AIC(credit.glm)
AIC(credit.glm1)
BIC(credit.glm)
BIC(credit.glm1)


# Understanding Classification decision making
## Logistic regression

### in sample prediction with log odds of p
predict(credit.glm1)
hist(predict(credit.glm1))

### In sample prediction with probability p
predict(credit.glm1, type="response")
hist(predict(credit.glm1, type="response"))

### Prediction with binary classification via cut off probability
predict(credit.glm1, type="response")>0.5

table(predict(credit.glm1, type = "response") > 0.5)
table(predict(credit.glm1, type = "response") > 0.2)
table(predict(credit.glm1, type = "response") > 1e-04)


# In-sample and out-of-sample prediction

## In-sample prediction
prob.glm1.insample <- predict(credit.glm1, type = "response")
predicted.glm1.insample <- prob.glm1.insample > 0.2
predicted.glm1.insample <- as.numeric(predicted.glm1.insample)
### confusion matrix
table(credit.train$Y, predicted.glm1.insample, dnn = c("Truth", "Predicted"))
mean(ifelse(credit.train$Y != predicted.glm1.insample, 1, 0))


## Out of sample prediction
prob.glm1.outsample <- predict(credit.glm1, credit.test, type = "response")
predicted.glm1.outsample <- prob.glm1.outsample > 0.2
predicted.glm1.outsample <- as.numeric(predicted.glm1.outsample)
### Confustion matrix
table(credit.test$Y, predicted.glm1.outsample, dnn = c("Truth", "Predicted"))
mean(ifelse(credit.test$Y != predicted.glm1.outsample, 1, 0))

##Alternative method for out of sample prediction
glm1.outsample.logodds <- predict(credit.glm1, credit.test)
predicted.glm1.outsample <- exp(glm1.outsample.logodds)/(1 + exp(glm1.outsample.logodds)) > 0.2
predicted.glm1.outsample <- as.numeric(predicted.glm1.outsample)
table(credit.test$Y, predicted.glm1.outsample, dnn = c("Truth", "Predicted"))
mean(ifelse(credit.test$Y != predicted.glm1.outsample, 1, 0))

##ROC CURVE
##### install.packages("verification")
library(verification)

##Plot roc curve for out of sample predictions
roc.plot(credit.test$Y == "1", prob.glm1.outsample)

###Volume under the curve
roc.plot(credit.test$Y == "1", prob.glm1.outsample)$roc.vol

###Multiple ROC curves
prob.glm.outsample <- predict(credit.glm, credit.test, type = "response")
roc.plot(x = credit.test$Y == "1", pred = cbind(prob.glm.outsample, prob.glm1.outsample), 
         legend = TRUE, leg.text = c("Full Model", "X_3, X_8, and X_11_2"))$roc.vol

##Alternative package for ROC curves
##### install.packages("ROCR")
library(ROCR)
pred <- prediction(prob.glm1.outsample, credit.test$Y)
perf <- performance(pred, "tpr", "fpr")
plot(perf, colorize = TRUE)

#Cross validation and cost function

pcut = 0.2
## Symmetric cost
cost1 <- function(r, pi) {
  mean(((r == 0) & (pi > pcut)) | ((r == 1) & (pi < pcut)))
}
## Asymmetric cost
cost2 <- function(r, pi) {
  weight1 = 2
  weight0 = 1
  c1 = (r == 1) & (pi < pcut)  #logical vector - true if actual 1 but predict 0
  c0 = (r == 0) & (pi > pcut)  #logical vecotr - true if actual 0 but predict 1
  return(mean(weight1 * c1 + weight0 * c0))
}

### Cross-validation
library(boot)
credit.glm3 <- glm(Y ~ X3 + X8 + X11_2, family = binomial, credit.data)
cv.result = cv.glm(credit.data, credit.glm3, cost1, 10)
cv.result$delta

### Search for optimal cut-off probability
### define the searc grid from 0.01 to 0.99
searchgrid = seq(0.01, 0.99, 0.01)
### result is a 99x2 matrix, the 1st col stores the cut-off p, the 2nd column
### stores the cost
result = cbind(searchgrid, NA)
### in the cost function, both r and pi are vectors, r=truth, pi=predicted 
### probability
cost1 <- function(r, pi) {
  weight1 = 10
  weight0 = 1
  c1 = (r == 1) & (pi < pcut)  #logical vector - true if actual 1 but predict 0
  c0 = (r == 0) & (pi > pcut)  #logical vecotr - true if actual 0 but predict 1
  return(mean(weight1 * c1 + weight0 * c0))
}
credit.glm1 <- glm(Y ~ X3 + X8 + X11_2, family = binomial, credit.train)
for (i in 1:length(searchgrid)) {
  pcut <- result[i, 1]
  # assign the cost to the 2nd col
  result[i, 2] <- cost1(credit.train$Y, predict(credit.glm1, type = "response"))
}
plot(result, ylab = "Cost in Training Set")


##Cross-validation to choose the best model
searchgrid = seq(0.01, 0.6, 0.02)
result = cbind(searchgrid, NA)
cost1 <- function(r, pi) {
  weight1 = 10
  weight0 = 1
  c1 = (r == 1) & (pi < pcut)  #logical vector - true if actual 1 but predict 0
  c0 = (r == 0) & (pi > pcut)  #logical vecotr - true if actual 0 but predict 1
  return(mean(weight1 * c1 + weight0 * c0))
}
credit.glm1 <- glm(Y ~ X3 + X8 + X11_2, family = binomial, credit.train)
for (i in 1:length(searchgrid)) {
  pcut <- result[i, 1]
  result[i, 2] <- cv.glm(data = credit.train, glmfit = credit.glm1, cost = cost1, 
                         K = 3)$delta[2]
}
plot(result, ylab = "CV Cost")