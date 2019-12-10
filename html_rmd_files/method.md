

# Method   

## Logistic Regression with Lasso Penalty

Diabete is a binary variable. For binary classification problems, linear logistic regression model is most often used. 
Although logistic regression often performs comparably to competing methods, such as support vector machine and linear 
discriminant analysis, it is chosen in this problem because of its several advantages. The notable advantages include 
that: it provides a direct estimate of class probability; it tends to be more robust in the case ![](http://latex.codecogs.com/gif.latex?k>>n)
since it makes no assumptions on the distribution of the predictors; and it doesn't need tuning parameters. The logistic regression model presents the class-conditional probabilities through a linear function of the predictors and is expressed as:

<div align="center">
<img src="https://latex.codecogs.com/gif.latex?log(\frac{p}{1-p})&space;=&space;\beta_0&space;&plus;&space;\sum_{i=1}^k{x_i\beta_i}" title="log(\frac{p}{1-p}) = \beta_0 + \sum_{i=1}^k{x_i\beta_i}" />
</div>

Logistic regression coefficients are typically estimated by maximizing the following binomial log-likelihood:
<div align="center">
<img src="https://latex.codecogs.com/gif.latex?\max_{\beta}&space;\sum_{i=1}^n{\{y_i(x_i^T\beta)-\log(1&plus;\exp(x_i^T\beta))\}}" title="\max_{\beta} \sum_{i=1}^n{\{y_i(x_i^T\beta)-\log(1+\exp(x_i^T\beta))\}}" />
</div>

In order to select the variables and avoid overfitting, here we try to use logistic regression with lasso penalty.
Now it becomes to be estimated by minimizing the following formula:
<div align="center">
<img src="https://latex.codecogs.com/gif.latex?\min_{\beta}\{&space;-\frac{1}{n}\sum_{i=1}^n{\{y_i(x_i^T\beta)-\log(1&plus;\exp(x_i^T\beta))\}}&space;&plus;&space;P_\lambda(\beta)\}&space;,&space;P_\lambda(\beta)=\lambda\sum_{j=1}^k|\beta_j|" title="\min_{\beta}\{ -\frac{1}{n}\sum_{i=1}^n{\{y_i(x_i^T\beta)-\log(1+\exp(x_i^T\beta))\}} + P_\lambda(\beta)\} , P_\lambda(\beta)=\lambda\sum_{j=1}^k|\beta_j|" />
</div>

## ROC curve and AUC

Because the data is unbalance. So we use AUC to judge our model.

|  | P(true) |  N(true)|
| --------- | ---- | :-------: |
| P'(predicted) |TP|FP| 
| N'(predicted) |FN |TN | 

ROC curve: Y-axis is TPR=TP/(TP+FN) , X-axis is FPR=FP/(FP+TN).   
AUC is value of area under ROC curve.  
Several equivalent interpretations of AUC:
* The expectation that a uniformly drawn random positive is ranked before a uniformly drawn random negative.
* The expected proportion of positives ranked before a uniformly drawn random negative.
* The expected true positive rate if the ranking is split just before a uniformly drawn random negative.
* The expected proportion of negatives ranked after a uniformly drawn random positive.
* 1 – the expected false positive rate if the ranking is split just after a uniformly drawn random positive.

