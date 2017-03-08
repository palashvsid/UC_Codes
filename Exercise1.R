#credit.data <- read.csv("http://homepages.uc.edu/~maifg/7040/credit0.csv", header = T)

credit.data$X9 = NULL
credit.data$id = NULL
credit.data$Y = as.factor(credit.data$Y)

set.seed(10676557)

subset <- sample(nrow(credit.data), nrow(credit.data) * 0.9)
credit.train = credit.data[subset, ]
credit.test = credit.data[-subset, ]

creditcost <- function(observed, predicted) {
  weight1 = 10
  weight0 = 1
  c1 = (observed == 1) & (predicted == 0)  #logical vector - true if actual 1 but predict 0
  c0 = (observed == 0) & (predicted == 1)  #logical vecotr - true if actual 0 but predict 1
  return(mean(weight1 * c1 + weight0 * c0))
}


credit.glm0 <- glm(Y ~ ., family = binomial, credit.train)
summary(credit.glm0)
credit.glm.step <- step(credit.glm0, direction = c("both"))
credit.glm.step <- step(credit.glm0, k = log(nrow(credit.train)), direction = c("both"))

install.packages("glmnet")
library("glmnet")

lasso_fit = glmnet(x = as.matrix(credit.train[, 2:61]), y = credit.train[, 1], 
                   family = "binomial", alpha = 1)
coef(lasso_fit, s = 0.02)


##Outsample prediction
prob.glm0.outsample <- predict(credit.glm0, credit.test, type = "response")
predicted.glm0.outsample <- prob.glm0.outsample > 0.2
predicted.glm0.outsample <- as.numeric(predicted.glm0.outsample)
table(credit.test$Y, predicted.glm0.outsample, dnn = c("Truth", "Predicted"))


library("verification")
roc.plot(credit.test$Y == "1", prob.glm0.outsample)
roc.plot(credit.test$Y == "1", prob.glm0.outsample)$roc.vol

install.packages("mgcv")
library(mgcv)


## Create a formula for a model with a large number of variables:
gam_formula <- as.formula(paste("Y~s(X2)+s(X3)+s(X4)+s(X5)+", paste(colnames(credit.train)[6:61], 
                                                                    collapse = "+")))

credit.gam <- gam(formula = gam_formula, family = binomial, data = credit.train)
summary(credit.gam)

##Partial residual plot
plot(credit.gam, shade = TRUE, seWithMean = TRUE, scale = 0)

AIC(credit.gam)
## [1] 1758.983
BIC(credit.gam)
## [1] 2164.862
credit.gam$deviance
## [1] 1632.38

pcut.gam <- 0.08
prob.gam.in <- predict(credit.gam, credit.train, type = "response")
pred.gam.in <- (prob.gam.in >= pcut.gam) * 1
table(credit.train$Y, pred.gam.in, dnn = c("Observation", "Prediction"))

mean(ifelse(credit.train$Y != pred.gam.in, 1, 0))

AIC(credit.gam)
## [1] 1758.983
BIC(credit.gam)
## [1] 2164.862

##Optimal cut-off probability
# define the searc grid from 0.01 to 0.20
searchgrid = seq(0.01, 0.2, 0.01)
# result.gam is a 99x2 matrix, the 1st col stores the cut-off p, the 2nd
# column stores the cost
result.gam = cbind(searchgrid, NA)
# in the cost function, both r and pi are vectors, r=truth, pi=predicted
# probability
cost1 <- function(r, pi) {
  weight1 = 10
  weight0 = 1
  c1 = (r == 1) & (pi < pcut)  #logical vector - true if actual 1 but predict 0
  c0 = (r == 0) & (pi > pcut)  #logical vecotr - true if actual 0 but predict 1
  return(mean(weight1 * c1 + weight0 * c0))
}

for (i in 1:length(searchgrid)) {
  pcut <- result.gam[i, 1]
  # assign the cost to the 2nd col
  result.gam[i, 2] <- cost1(credit.train$Y, predict(credit.gam, type = "response"))
}
plot(result.gam, ylab = "Cost in Training Set")


index.min <- which.min(result.gam[, 2])  #find the index of minimum value
result.gam[index.min, 2]  #min cost
##        
## 0.3868889 
result.gam[index.min, 1]  #optimal cutoff probability
## 0.12

##Out of sample performance
pcut <- result.gam[index.min, 1]
prob.gam.out <- predict(credit.gam, credit.test, type = "response")
pred.gam.out <- (prob.gam.out >= pcut) * 1
table(credit.test$Y, pred.gam.out, dnn = c("Observation", "Prediction"))

mean(ifelse(credit.test$Y != pred.gam.out, 1, 0))

creditcost(credit.test$Y, pred.gam.out)


#LDA
credit.train$Y = as.factor(credit.train$Y)
credit.lda <- lda(Y ~ ., data = credit.train)
prob.lda.in <- predict(credit.lda, data = credit.train)
pcut.lda <- 0.15
pred.lda.in <- (prob.lda.in$posterior[, 2] >= pcut.lda) * 1
table(credit.train$Y, pred.lda.in, dnn = c("Obs", "Pred"))

mean(ifelse(credit.train$Y != pred.lda.in, 1, 0))

lda.out <- predict(credit.lda, newdata = credit.test)
cut.lda <- 0.12
pred.lda.out <- as.numeric((lda.out$posterior[, 2] >= cut.lda))
table(credit.test$Y, pred.lda.out, dnn = c("Obs", "Pred"))

mean(ifelse(credit.test$Y != pred.lda.out, 1, 0))
creditcost(credit.test$Y, pred.lda.out)


#Neural Networks
library(nnet)

credit.nnet <- nnet(Y ~ ., data = credit.train, size = 1, maxit = 500)

prob.nnet = predict(credit.nnet, credit.test)
pred.nnet = as.numeric(prob.nnet > 0.08)
table(credit.test$Y, pred.nnet, dnn = c("Observation", "Prediction"))
mean(ifelse(credit.test$Y != pred.nnet, 1, 0))
creditcost(credit.test$Y, pred.nnet)


####SVMs
#install.packages("e1071")
library(e1071)
credit.svm = svm(Y ~ ., data = credit.train, cost = 1, gamma = 1/length(credit.train), 
                 probability = TRUE)
prob.svm = predict(credit.svm, credit.test, probability = TRUE)
prob.svm = attr(prob.svm, "probabilities")[, 2]  #This is needed because prob.svm gives a 
pred.svm = as.numeric((prob.svm >= 0.08))
table(credit.test$Y, pred.svm, dnn = c("Obs", "Pred"))
