# Stats 506 Group 1 Project Proposal

Weijie Pan (Python),
Jingxian Chen (R),
Eric Hernandez-Montenegro (Stata)

## Question

**`Do people’s eating habits have the same effect on their diabetes status with or without health insurance?`**

Data : `2015-2016 Demographic Variables and Sample Weights` [\<Link\>](https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Component=Demographics&CycleBeginYear=2015)   

| Variables Name   |Variable Description     |
| ------------- |:-------------:|
| SEQN       | Respondent sequence number  |
| RIAGENDR     | Age (in years)     |
| INDFMIN2 | Annual Family Income      |
   
Data : `2015-2016 Health Insurance` [\<Link\>](https://wwwn.cdc.gov/nchs/nhanes/Search/DataPage.aspx?Component=Questionnaire&CycleBeginYear=2015)   

| Variables Name   |Variable Description     |
| ------------- |:-------------:|
| SEQN       | Respondent sequence number  |
| HIQ011    | Covered by health insurance     |

Data : `2015-2016 Diabetes` [\<Link\>](https://wwwn.cdc.gov/nchs/nhanes/Search/DataPage.aspx?Component=Questionnaire&CycleBeginYear=2015)

| Variables Name   |Variable Description     |
| ------------- |:-------------:|
| SEQN       | Respondent sequence number  |
| DIQ010    | Doctor told you have diabetes     |


Data:`2015-2016 Dietary Interview - Total Nutrient Intakes, First Day `    
     `2015-2016 Dietary Interview - Total Nutrient Intakes, Second Day` [\<Link\>](https://wwwn.cdc.gov/nchs/nhanes/Search/DataPage.aspx?Component=Dietary&CycleBeginYear=2015)
     
| Variables Name   |Variable Description     |
| ------------- |:-------------:|
| SEQN       | Respondent sequence number  |
| WTDRD1   | Dietary day one sample weight     |
|WTDR2D | Dietary two-day sample weight | 
|DR1TIRON | Iron  |
|DR1TCALC | Calcium  |
|DR1TZINC | Zinc | 
|DR1TSODI | Sodium | 
|DR1TATOC | Vitamin E  |
|DR1TVARA | Vitamin A  |
|DR1TALCO | Alcohol  |
|DR1TVC | Vitamin C | 
|DR1TTFAT | Total fat  |
|DR1TFIBE | Dietary fiber|  
|DR1TSUGR | Total sugars  |
|DR1TCARB | Carbohydrate | 
|DR1TKCAL | Energy  |
|DR1TPROT | Protein  |

## Analytic Modeling Techniques   

### Logistic Regression with Lasso Penalty

Diabete is a binary variable. For binary classification problems, linear logistic regression model is most often used. 
Although logistic regression often performs comparably to competing methods, such as support vector machine and linear 
discriminant analysis, it is chosen in this problem because of its several advantages. The notable advantages include 
that: it provides a direct estimate of class probability; it tends to be more robust in the case ![](http://latex.codecogs.com/gif.latex?k>>n)
since it makes no assumptions on the distribution of the predictors; and it doesn't need tuning parameters. The logistic regression model presents the class-conditional probabilities through a linear function of the predictors and is expressed as:

<p align="center">
<img src="https://latex.codecogs.com/gif.latex?log(\frac{p}{1-p})&space;=&space;\beta_0&space;&plus;&space;\sum_{i=1}^k{x_i\beta_i}" title="log(\frac{p}{1-p}) = \beta_0 + \sum_{i=1}^k{x_i\beta_i}" />
</p>


Logistic regression coefficients are typically estimated by maximizing the following binomial log-likelihood:
<p align="center">
<img src="https://latex.codecogs.com/gif.latex?\max_{\beta}&space;\sum_{i=1}^n{\{y_i(x_i^T\beta)-\log(1&plus;\exp(x_i^T\beta))\}}" title="\max_{\beta} \sum_{i=1}^n{\{y_i(x_i^T\beta)-\log(1+\exp(x_i^T\beta))\}}" />
</p>

In order to select the variables and avoid overfitting, here we try to use logistic regression with lasso penalty.
Now it becomes to be estimated by minimizing the following formula:
<p align="center">
<img src="https://latex.codecogs.com/gif.latex?\min_{\beta}\{&space;-\frac{1}{n}\sum_{i=1}^n{\{y_i(x_i^T\beta)-\log(1&plus;\exp(x_i^T\beta))\}}&space;&plus;&space;P_\lambda(\beta)\}&space;,&space;P_\lambda(\beta)=\lambda\sum_{j=1}^k|\beta_j|" title="\min_{\beta}\{ -\frac{1}{n}\sum_{i=1}^n{\{y_i(x_i^T\beta)-\log(1+\exp(x_i^T\beta))\}} + P_\lambda(\beta)\} , P_\lambda(\beta)=\lambda\sum_{j=1}^k|\beta_j|" />
</p>

### ROC curve and AUC

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

### Details 
* In order to consider the effect from the insurance, we build the logistic regression model adding interactive terms between insurance and variables in the total Intakes dataset.   
* Use Lasso penalty in the model to select variables from the Dietary Interview.    
* Use the cross-validation method to choose the best penalty parameter of our model.   
* Because we have samples without diabetes weight more than samples with one, we choose to use the AUC value as our model performance measurement. Then plot the ROC curve to display the performance of the model. Give a conclusion on whether the eating habits have the same effect on these two groups of people.    
* Model with insurance interaction term:   
Where insurance is 0 or 1. X are the variables that we choose in the total nutrient intake dataset.  
Consider formula like this: <img src="https://latex.codecogs.com/gif.latex?X\beta&space;&plus;&space;XI_{insurance}*\beta_{&space;interaction\_terms}" title="X\beta + XI_{insurance}*\beta_{ interaction\_terms}" />



Software/Programming to Be Use  
Python, R, and Stata  



### Outline of our project  
1.	Data preprocessing part:   
(1)	Select variables from each of the dataset mentioned above and combine all the dataset together.   
(2)	First to remove observations with missing values;    
a)	transform age variable into factor format with 5 levels;    
b)	transform income variable into factor format with 13 levels;    
c)	standardize all the continuous intakes variables;    
d)	add a variable called “survey day” denoting the observations from which dataset.   
e)	Add interaction variables (intakes variables multiplied by insurance) and remove insurance variable.   

2.	Data visualization part: (only analyze day1 intakes data):
Using plot or table to see the average values (using sample weights and give a 95%CI) of microelements (nutrients, vitamins) at each level of age gender and insurance status for those people who have diabetes problem;   
Using plot or table to see the same measurements for people who don’t have diabetes problem;   
Using plot or table to see the differences between the above two values.   
Here, Microelements are zinc, iron, sodium; Nutrients are fat sugar protein; Vitamins are VA, VC, VE   
After showing 9 tables or plots, we can give a general conclusion of the difference in eating habits of people with or without diabetes at each level.   

3.	Model establish part:   
We decide to split 20% of our data as test data, and then we use the other 80% for training and cross-validation procedure (10 folds).   
First to split our data; and then use cross validation method to choose the lambda which has the best AUC value in cross-validation dataset; then use this lambda to build our model with training set data; then predict the test set diabetes status and obtain AUC value from test set to see our model performance.   
We then do the above procedure serval times to avoid overfitting problems by randomly choose different test data.    
Assume we have done it N times, then we will get n different optimal lambda values and n AUC values for N models’ performances.    
Then we use the mean value of those lambdas to build our final model for whole data and use the mean value of those AUC value as our estimation of the final model performance.   

4.	Model interpretation part: 
We need to interpret our model for solving our main problem.

5.	Other things can be improved:  
*	Parallel coding: for the cross-validation part and the randomly choose test data N times part we can use parallel skills to improve the efficiency of our program.


