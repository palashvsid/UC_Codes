#load the data
bankruptcy <- read.csv("bankruptcy.csv", header = T)

#Check number of rows and columns
dim(bankruptcy)
##Check for repeating rows and remove any
bankruptcy=unique(bankruptcy)
##Check for rows with NULL values and remove any
bankruptcy=bankruptcy[complete.cases(bankruptcy),]
#Check number of rows and columns
dim(bankruptcy)
#Remove columns not needed
bankruptcy= bankruptcy[-3]

#create training and testing datasets
set.seed(2604)
sample <- sample(nrow(bankruptcy), nrow(bankruptcy) * 0.7)
train = bankruptcy[sample, ]
test = bankruptcy[-sample, ]
dim(train)
dim(test)
summary(train)

#part i
#data exploration of training dataset
# histogram of numeric varialbes 
par()
par(mfrow = c(3,4))
for (i in 1:12) {
  n <- names(train)
  hist(train[,i], prob = TRUE, xlab = paste("The range of", n[i]), main = paste("Histogram of", n[i])) 
  lines(density(train[,i], na.rm = T), col="blue") 
}

#boxplot 
par(mfrow = c(3,4))
for (i in 1:12) {
  n <- names(train)
  boxplot(train[,i], prob = TRUE, xlab = paste("The range of", n[i]), main = paste("Boxplot of", n[i])) 
}

#scatterplot matrix
col_vec=ifelse(train$DLRSN==1,"blue","orange")
pairs(~.,data=train)

##part ii
#logistic regression ##Logit
bankruptcy.glm.l=glm(DLRSN~.-FYEAR,family=binomial(link="logit"),data=train)
bankruptcy.summary=summary(bankruptcy.glm.l)
bankruptcy.glm.l.step1 <- step(bankruptcy.glm.l, direction="backward")
bankruptcy.glm.l.step2 <- step(bankruptcy.glm.l, direction="backward",k=log(nrow(train))) #use BIC
bankruptcy.glm.l1=glm(DLRSN~.-FYEAR-R5,family=binomial(link="logit"),data=train)
bankruptcy.glm.l2=glm(DLRSN~R2+R3+R6+R7+R9+R10,family=binomial(link="logit"),data=train)
bankruptcy.summary1=summary(bankruptcy.glm.l1)
bankruptcy.summary2=summary(bankruptcy.glm.l2)

#logistic regression ##Probit
bankruptcy.glm.p=glm(DLRSN~.-FYEAR,family=binomial(link="probit"),data=train)
bankruptcy.summary=summary(bankruptcy.glm.p)
bankruptcy.glm.p.step1 <- step(bankruptcy.glm.p, direction="backward")
bankruptcy.glm.p.step2 <- step(bankruptcy.glm.p, direction="backward",k=log(nrow(train))) #use BIC
bankruptcy.glm.p1=glm(DLRSN~.-FYEAR-R5,family=binomial(link="probit"),data=train)
bankruptcy.glm.p2=glm(DLRSN~R2+R3+R6+R7+R9+R10,family=binomial(link="probit"),data=train)
bankruptcy.summary1=summary(bankruptcy.glm.p1)
bankruptcy.summary2=summary(bankruptcy.glm.p2)

#logistic regression ##Complimentary log-log
bankruptcy.glm.c=glm(DLRSN~.-FYEAR,family=binomial(link="cloglog"),data=train)
bankruptcy.summary=summary(bankruptcy.glm.c)
bankruptcy.glm.c.step1 <- step(bankruptcy.glm.c, direction="backward")
bankruptcy.glm.c.step2 <- step(bankruptcy.glm.c, direction="backward",k=log(nrow(train))) #use BIC
bankruptcy.glm.c1=glm(DLRSN~.-FYEAR-R5,family=binomial(link="cloglog"),data=train)
bankruptcy.glm.c2=glm(DLRSN~.-FYEAR-R5,family=binomial(link="cloglog"),data=train)
bankruptcy.summary1=summary(bankruptcy.glm.c1)
bankruptcy.summary2=summary(bankruptcy.glm.c2)

library("verification")



analysis <- data.frame(model = c("logit", "logit- aic", "logit- bic", "probit", "probit-aic", "probit-bic", "cloglog", "cloglog-aic", "cloglog-bic"), AIC = c(AIC(bankruptcy.glm.l),
             AIC(bankruptcy.glm.l1),
             AIC(bankruptcy.glm.l2),
             AIC(bankruptcy.glm.p),
             AIC(bankruptcy.glm.p1),
             AIC(bankruptcy.glm.p2),
             AIC(bankruptcy.glm.c),
             AIC(bankruptcy.glm.c1),
             AIC(bankruptcy.glm.c2)
),BIC= c(BIC(bankruptcy.glm.l),
     BIC(bankruptcy.glm.l1),
     BIC(bankruptcy.glm.l2),
     BIC(bankruptcy.glm.p),
     BIC(bankruptcy.glm.p1),
     BIC(bankruptcy.glm.p2),
     BIC(bankruptcy.glm.c),
     BIC(bankruptcy.glm.c1),
     BIC(bankruptcy.glm.c2)), AUC = c(roc.plot(train$DLRSN == "1", predict(bankruptcy.glm.l, type = "response"))$roc.vol$Area,
                                      roc.plot(train$DLRSN == "1", predict(bankruptcy.glm.l1, type = "response"))$roc.vol$Area,
                                      roc.plot(train$DLRSN == "1", predict(bankruptcy.glm.l2, type = "response"))$roc.vol$Area,
                                      roc.plot(train$DLRSN == "1", predict(bankruptcy.glm.p, type = "response"))$roc.vol$Area,
                                      roc.plot(train$DLRSN == "1", predict(bankruptcy.glm.p1, type = "response"))$roc.vol$Area,
                                      roc.plot(train$DLRSN == "1", predict(bankruptcy.glm.p2, type = "response"))$roc.vol$Area,
                                      roc.plot(train$DLRSN == "1", predict(bankruptcy.glm.c, type = "response"))$roc.vol$Area,
                                      roc.plot(train$DLRSN == "1", predict(bankruptcy.glm.c1, type = "response"))$roc.vol$Area,
                                      roc.plot(train$DLRSN == "1", predict(bankruptcy.glm.c2, type = "response"))$roc.vol$Area))



#Final model DLRSN ~ R1 + R2 + R3 + R4 + R6 + R7 + R8 + R9 + R10

bankruptcy.glm <- glm(DLRSN~.-FYEAR-R5,family=binomial(link="logit"),data=train)
bankruptcy.glm.summary = summary(bankruptcy.glm)
AIC(bankruptcy.glm)
BIC(bankruptcy.glm)
roc.plot(train$DLRSN == "1", predict(bankruptcy.glm, type = "response"))
roc.plot(train$DLRSN == "1", predict(bankruptcy.glm, type = "response"))$roc.vol$Area
bankruptcy.glm.summary$deviance / bankruptcy.glm.summary$df.residual

#Misclassification table
pcut = 1/6
bankruptcy.glm.insample <- predict(bankruptcy.glm, train, type = "response")
bankruptcy.glm.insample <- bankruptcy.glm.insample > pcut
bankruptcy.glm.insample <- as.numeric(bankruptcy.glm.insample)
View(table(train$DLRSN, bankruptcy.glm.insample, dnn = c("Truth", "Predicted")))

#misclassification rate from test data
missclassifylist=ifelse(train$DLRSN != bankruptcy.glm.insample, 1,0)
mis_rate=mean(missclassifylist)
mis_rate


##iii
##Out of sample AUC and misclassification rate
#Assume pcut = 1/6
pcut = 1/6
bankruptcy.glm.outsample <- predict(bankruptcy.glm, test, type = "response")
bankruptcy.glm.outsample <- bankruptcy.glm.outsample > pcut
bankruptcy.glm.outsample <- as.numeric(bankruptcy.glm.outsample)
table(test$DLRSN, bankruptcy.glm.outsample, dnn = c("Truth", "Predicted"))

##ROC Curve and AUC rate
roc.plot(test$DLRSN == "1", predict(bankruptcy.glm, test, type = "response"))
roc.plot(test$DLRSN == "1", predict(bankruptcy.glm, test, type = "response"))$roc.vol$Area


#misclassification rate from test data
missclassifylist=ifelse(test$DLRSN != bankruptcy.glm.outsample, 1,0)
mis_rate=mean(missclassifylist)
mis_rate


##iv
##Cutoff probability
# define the searc grid from 0.01 to 0.99
searchgrid = seq(0.01, 0.99, 0.01)
# stores the cost
result = cbind(searchgrid, NA)
# in the cost function, both r and pi are vectors, r=truth, pi=predicted
# probability
cost <- function(r, pi) {
  weight1 = 15
  weight0 = 1
  c1 = (r == 1) & (pi < pcut)  #logical vector - true if actual 1 but predict 0
  c0 = (r == 0) & (pi > pcut)  #logical vecotr - true if actual 0 but predict 1
  return(mean(weight1 * c1 + weight0 * c0))
}
for (i in 1:length(searchgrid)) {
  pcut <- result[i, 1]
  # assign the cost to the 2nd col
  result[i, 2] <- cost(train$DLRSN, predict(bankruptcy.glm, type = "response"))
}
plot(result, ylab = "Cost in Training Set")
#Cutoff value = 0.07
pcut = result[which.min(result[,2])]

##Part v
#install.packages("boot")
library(boot)

bankruptcy.glm.cv <- glm(DLRSN~.-FYEAR-R5,family=binomial(link="logit"),data=bankruptcy)
cv.result = cv.glm(bankruptcy, bankruptcy.glm.cv, cost, 3)
cv.result$delta  

result.cv = cbind(searchgrid, NA)
for (i in 1:length(searchgrid)) {
  pcut <- result.cv[i, 1]
  result.cv[i, 2] <- cv.glm(bankruptcy, bankruptcy.glm.cv, cost, 3)$delta[2]
}
plot(result.cv, ylab = "CV Cost")
pcut.cv= result[which.min(result.cv[,2])]
pcut.cv

##ROC Curve and AUC rate
roc.plot(bankruptcy$DLRSN == "1", predict(bankruptcy.glm.cv, bankruptcy, type = "response"))
roc.plot(bankruptcy$DLRSN == "1", predict(bankruptcy.glm.cv, bankruptcy, type = "response"))$roc.vol$Area


#misclassification rate
pcut.cv
bankruptcy.glm.cv.outsample <- predict(bankruptcy.glm.cv, bankruptcy, type = "response")
bankruptcy.glm.cv.outsample <- bankruptcy.glm.cv.outsample > pcut.cv
bankruptcy.glm.cv.outsample <- as.numeric(bankruptcy.glm.cv.outsample)
table(bankruptcy$DLRSN, bankruptcy.glm.cv.outsample, dnn = c("Truth", "Predicted"))

missclassifylist.cv=ifelse(bankruptcy$DLRSN != bankruptcy.glm.cv.outsample, 1,0)
mis_rate.cv=mean(missclassifylist.cv)
mis_rate.cv
