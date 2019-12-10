// Group 1 Project - STATS 506
// Program: STATA 
// Author: Eric Hernandez-Montenegro
// Last Modified On: 12/10/2019

*-------------------------------------------------------------------------------
* This Do-File contains code for running the model.
* We attempt to find 10 optimal lambdas.
* Cross-Validation is used on the training data to find the optimal lambda.
* Optimal lambda is chosen as the lambda that minimizes loss error.
* Prediction is then made on the test data and ROC is computed to
* judge the performance of the model.
* Lastly, we average the 10 lambdas to obtain a final lambda and use it 
* in our final model.
*-------------------------------------------------------------------------------

* Import Main Data Set
use "I:\stats506_group_project\main_data_modified.dta"

*-------------------------------------------------------------------------------
* Create 10 Training and 10 Test Data Sets
* Build Training Data - 80 % of Main Data Set
* Build Test Data - 20 % of Main Data Set
* Key:
* Training Data if "training" == 1
* Test Data if "training" == 0

forval v = 1/10 {
set seed 11`v'
gen random`v' = uniform()
sort random`v'
gen byte training`v' = _n <= 13245*.8
}
drop random*
save training_test_data, replace

*-------------------------------------------------------------------------------
* Use 10-Fold Cross-Validation with Logistic Regression on Training Data
* to obtain optimal lambda
* NOTE: Install "lassopack" "pdslasso" and "cvAUROC"

ssc install pdslasso
ssc install lassopack
ssc install cvAUROC

forval v = 1/10 {
cvlassologit diabetes gender-alcohol_alt if training`v' == 1, nfolds(10) seed(11`v') 
}

* Lambda Values (that minimize loss measure):
* 8.6141729 
* 15.424845
* 13.24682 
* 13.310124 
* 17.646587 
* 17.67645
* 18.184071 
* 11.675487 
* 27.217884 
* 15.427758 

*-------------------------------------------------------------------------------
* Predict on test data using each lambda and calculate ROC for each

lassologit diabetes gender age income energy_org-alcohol_alt if training1== 1, lambda(8.6141729)
predict pdiabetes1 if training1 == 0, pr
roctab diabetes pdiabetes1, graph summary
* ROC Area = 0.8482 

lassologit diabetes gender age income energy_org-alcohol_alt if training2== 1, lambda(15.424845)
predict pdiabetes2 if training2 == 0, pr
roctab diabetes pdiabetes2, graph summary
* ROC Area = 0.8396  

lassologit diabetes gender age income energy_org-alcohol_alt if training3 == 1, lambda(13.24682)
predict pdiabetes3 if training3 == 0, pr
roctab diabetes pdiabetes3, graph summary
* ROC Area = 0.8545 

lassologit diabetes gender age income energy_org-alcohol_alt if training4 == 1, lambda(13.310124)
predict pdiabetes4 if training4 == 0, pr
roctab diabetes pdiabetes4, graph summary
* ROC Area = 0.8495

lassologit diabetes gender age income energy_org-alcohol_alt if training5 == 1, lambda(17.646587)
predict pdiabetes5 if training5 == 0, pr
roctab diabetes pdiabetes5, graph summary
* ROC Area = 0.8546

lassologit diabetes gender age income energy_org-alcohol_alt if training6 == 1, lambda(17.67645)
predict pdiabetes6 if training6 == 0, pr
roctab diabetes pdiabetes6, graph summary
* ROC Area = 0.8551 

lassologit diabetes gender age income energy_org-alcohol_alt if training7 == 1, lambda(18.184071)
predict pdiabetes7 if training7 == 0, pr
roctab diabetes pdiabetes7, graph summary
* ROC Area = 0.8394 

lassologit diabetes gender age income energy_org-alcohol_alt if training8 == 1, lambda(11.675487)
predict pdiabetes8 if training8 == 0, pr
roctab diabetes pdiabetes8, graph summary
* ROC Area = 0.8462 

lassologit diabetes gender age income energy_org-alcohol_alt if training9 == 1, lambda(27.217884)
predict pdiabetes9 if training9 == 0, pr
roctab diabetes pdiabetes9, graph summary
* ROC Area = 0.8513 

lassologit diabetes gender age income energy_org-alcohol_alt if training10 == 1, lambda(15.427758)
predict pdiabetes10 if training10 == 0, pr
roctab diabetes pdiabetes10, graph summary
* ROC Area = 0.8534


* Average lambda:
mata
(8.6141729 + 15.424845 + 13.24682 + 13.310124 + 17.646587 + 17.67645 + 
18.184071 + 11.675487 + 27.217884 + 15.427758)/10
end

* Average ROC Area:
mata
(0.8482 + 0.8396 + 0.8545 + 0.8546 + 0.8551 + 0.8394 + 0.8462 + 0.8513 + 0.8534)/10
end


*-------------------------------------------------------------------------------
* Fit final model with average lambda
* And calculate ROC to judge performance of model
* Average lambda = 15.84241989
* Average ROC Area = .76423
lassologit diabetes gender age income energy_org-alcohol_alt, lambda(15.84241989)

predict pdiabetesfinal, pr
roctab diabetes pdiabetesfinal, graph summary

