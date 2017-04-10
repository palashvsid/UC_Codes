library(fpc)
#install.packages("arules")
library(arules)
library('arulesViz')
#install.packages('arulesViz')


##Question 1
data(iris)

set.seed(10676557)
sampler <- sample(nrow(iris), nrow(iris)*0.9)
iris <- iris[sampler,]
iris1 <- iris[,1:4]
iris1 <- scale(iris1)


# K-Means Cluster Analysis
fit2 <- kmeans(iris1, 2) #2 cluster solution
table(fit2$cluster)
fit3 <- kmeans(iris1, 3) #3 cluster solution
table(fit3$cluster)
fit4 <- kmeans(iris1, 4) #4 cluster solution
table(fit4$cluster)
fit5 <- kmeans(iris1, 5) #2 cluster solution
table(fit5$cluster)

##Plot clusters
library(fpc)
plotcluster(iris1, fit2$cluster)
plotcluster(iris1, fit3$cluster)
plotcluster(iris1, fit4$cluster)
plotcluster(iris1, fit5$cluster)

# Determine number of clusters

#Within Group SS
wss <- (nrow(iris1)-1)*sum(apply(iris1,2,var))
for (i in 2:12) wss[i] <- sum(kmeans(iris1,
                                     centers=i)$withinss)
plot(1:12, wss, type="b", xlab="Number of Clusters",ylab="Within groups sum of squares")

#Prediction strength
prediction.strength(iris1, Gmin=2, Gmax=7, M=100,cutoff=0.9)

##Select 2 as the number of clusters
fit2$centers


#Hierarchical clustering
#Calculate the distance matrix
iris1.dist=dist(iris1)
#Obtain clusters using the Wards method
iris1.hclust=hclust(iris1.dist, method="ward")
## The "ward" method has been renamed to "ward.D"; note new "ward.D2"
plot(iris1.hclust)

#Cut dendrogram at the 3 clusters level and obtain cluster membership
iris1.2clust = cutree(iris1.hclust,k=2)
#plotcluster(ZooFood, fit$cluster)
plotcluster(iris1, iris1.2clust)





##Question 2
###Clustering
Food_by_month <- read.csv('http://homepages.uc.edu/~maifg/DataMining/data/qry_Food_by_Month.csv')
Food_by_month <- Food_by_month[,2:7]
Food_by_month <- scale(Food_by_month)


# K-Means Cluster Analysis
fit2 <- kmeans(Food_by_month, 2) #2 cluster solution
table(fit2$cluster)
fit3 <- kmeans(Food_by_month, 3) #3 cluster solution
table(fit3$cluster)
fit4 <- kmeans(Food_by_month, 4) #4 cluster solution
table(fit4$cluster)
fit5 <- kmeans(Food_by_month, 5) #2 cluster solution
table(fit5$cluster)

##Plot clusters
library(fpc)
plotcluster(Food_by_month, fit2$cluster)
plotcluster(Food_by_month, fit3$cluster)
plotcluster(Food_by_month, fit4$cluster)
plotcluster(Food_by_month, fit5$cluster)

# Determine number of clusters

#Within Group SS
wss <- (nrow(Food_by_month)-1)*sum(apply(Food_by_month,2,var))
for (i in 2:12) wss[i] <- sum(kmeans(Food_by_month,
                                     centers=i)$withinss)
plot(1:12, wss, type="b", xlab="Number of Clusters",ylab="Within groups sum of squares")

#Prediction strength
prediction.strength(Food_by_month, Gmin=2, Gmax=15, M=100,cutoff=0.8)

##Select 2 as the number of clusters
fit2$centers


#Hierarchical clustering
#Calculate the distance matrix
Food_by_month.dist=dist(Food_by_month)
#Obtain clusters using the Wards method
Food_by_month.hclust=hclust(Food_by_month.dist, method="ward")
## The "ward" method has been renamed to "ward.D"; note new "ward.D2"
plot(Food_by_month.hclust)

#Cut dendrogram at the 3 clusters level and obtain cluster membership
Food_by_month.2clust = cutree(Food_by_month.hclust,k=2)
#plotcluster(ZooFood, fit$cluster)
plotcluster(Food_by_month, Food_by_month.2clust)



#Assoc Rules
TransFood <- read.csv('http://homepages.uc.edu/~maifg/DataMining/data/food_4_association.csv')
TransFood <- TransFood[, -1]
TransFood <- as(as.matrix(TransFood), "transactions")

x = TransFood[size(TransFood) > 13]
inspect(x)
itemFrequencyPlot(TransFood, support = 0.075, cex.names=0.8)
# Run the apriori algorithm
basket_rules <- apriori(TransFood, parameter = list(sup = 0.003, conf = 0.5,target="rules"))
summary(basket_rules)
plot(basket_rules)

plot(head(sort(basket_rules, by="lift"), 9), method = "graph")
plot(basket_rules, method="grouped")



