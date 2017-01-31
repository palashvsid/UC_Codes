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
df_beta <- data.frame(beta0=double(), beta1= double(), beta2= double()) 
vec_MSE = c()

for (i in 1:m)
{
  error <- rnorm(n, mean=0, sd= 1)
  data$y = data$y_no_error+error
  lm.out=lm(y~x1+x2, data=data)
  df_beta[i,]= lm.out$coefficients
  mysummary= summary(lm.out)
  vec_MSE[i]= mysummary$sigma^2
}

# Part iii
beta_mean = apply(df_beta, 2, mean)
beta_bias = beta_mean - c(beta0, beta1, beta2)
beta_var = apply(df_beta, 2, var)
mse = beta_bias*beta_bias + beta_var
vec_MSE[j]= mysummary$sigma^2

