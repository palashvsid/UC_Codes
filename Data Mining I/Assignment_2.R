## Question 3

n= 200
m= 100
beta0= 5
beta1= 1.2
beta2= 3

set.seed(260423)

# Part i
x1 = rnorm(n, mean=2,  sd=0.4)
x2 = rnorm(n, mean=-1, sd=0.1)

y_no_error = beta0 + beta1*x1 + beta2*x2

data <- data.frame(y_no_error=y_no_error, x1 =x1, x2=x2)

# Part ii
error <- rnorm(m, mean=0, sd= 1)
df_beta <- data.frame(beta0=c(), beta1= c(), beta2= c()) 
vec_MSE = c()

for (i in 1:m)
{
  data$y = data$y_no_error+error[i]
  lm.out=lm(y~x1+x2, data=data)
  df_beta[j,]= lm.out$coefficients
  mysummary= summary(lm.out)
  vec_MSE[j]= mysummary$sigma^2
}