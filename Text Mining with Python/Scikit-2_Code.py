#Imports
import nltk
import csv
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.svm import LinearSVC
from sklearn.pipeline import Pipeline
from sklearn.model_selection import GridSearchCV
from sklearn.datasets import load_files
from sklearn.model_selection import train_test_split
from sklearn import metrics
import os
import pandas as pd
import seaborn
import numpy as np
from sklearn.linear_model import SGDClassifier
from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB


#Data
data = pd.read_csv("C:/Users/palas/Desktop/UC/BANA/Sem 2/8090- Python/datascikit2.csv")


#Visualizing splits of 0/1
seaborn.countplot("Flag", data=data)
seaborn.plt.show()


#Train/test split
np.random.seed(8)
review_train, review_test, flag_train, flag_test = train_test_split(
    data['Review'], data['Flag'], test_size=0.25, random_state=None)
  


#Train/Test visualizing splits of 0/1
seaborn.countplot("Flag", data=pd.Series.to_frame(flag_train))
seaborn.plt.show()
seaborn.countplot("Flag", data=pd.Series.to_frame(flag_test))
seaborn.plt.show()


#Plumbing
pipeline1 = Pipeline([('vect', CountVectorizer()),
                     ('tfidf', TfidfTransformer()),
                     ('clf', SGDClassifier(loss='log')),
])

pipeline2 = Pipeline([('vect', CountVectorizer()),
                      ('tfidf', TfidfTransformer()),
                      ('clf', MultinomialNB()),
])

pipeline3 = Pipeline([
    ('vect', TfidfVectorizer(min_df=3, max_df=0.95)),
    ('tfidf', TfidfTransformer()),
    ('clf', LinearSVC()),
])

##Logistic with SGD
#Grid Search
parameters = {'vect__ngram_range': [(1, 1), (1, 2), (1,3)],
              'tfidf__use_idf': (True, False),
              'clf__alpha': (1e-2, 1e-3),
}
gridsearch = GridSearchCV(pipeline1, parameters, n_jobs=-1)
gridsearch.fit(review_train, flag_train)

#Estimation
flag_predicted = gridsearch.predict(review_test)
print(metrics.classification_report(flag_test, flag_predicted))
cm = metrics.confusion_matrix(flag_test, flag_predicted)
print(cm)


##Naive Bayes
#Grid Search
parameters = {'vect__ngram_range': [(1, 1), (1, 2), (1,3)],
              'tfidf__use_idf': (True, False),
              'clf__alpha': (1e-2, 1e-3),
}
gridsearch = GridSearchCV(pipeline2, parameters, n_jobs=-1)
gridsearch.fit(review_train, flag_train)

#Estimation
flag_predicted = gridsearch.predict(review_test)
print(metrics.classification_report(flag_test, flag_predicted))
cm = metrics.confusion_matrix(flag_test, flag_predicted)
print(cm)


##SVM
#Grid Search
parameters = {'vect__ngram_range': [(1, 1), (1, 2), (1,3)]
}
gridsearch = GridSearchCV(pipeline3, parameters, n_jobs=-1)
gridsearch.fit(review_train, flag_train)

#Estimation
flag_predicted = gridsearch.predict(review_test)
print(metrics.classification_report(flag_test, flag_predicted))
cm = metrics.confusion_matrix(flag_test, flag_predicted)
print(cm)