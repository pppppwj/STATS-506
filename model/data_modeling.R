################################################################################
# Title: Model establishing for Group project 506
# Author: Jingxian Chen
# Version: 2.0
# Date: Dec 7th, 2019
################################################################################

#-------------------------------------------------------------------------------
# Description: This code is for the modeling of the final data, I first use 
# doParallel package to register core using, and then split data into training 
# and testset, then use crossvalidation to choose optimal hyperparameter, finally 
# use AUC to estimate the model performance.
#-------------------------------------------------------------------------------

## load data
source("D:/Files/stats506/group_project/data_preprocessing.R")

### Modeling part
library(doParallel)
library(glmnet)

## setup parallel computing parameter
ncores = 2  

# set up a cluster called 'cl'
cl = makeCluster(ncores)

# register the cluster
registerDoParallel(cl)


# set the number of testset partition times
N_test <- 10

# delete the insurance variable and add interactive term with intake variables
times_insur <- function(x) x * Data_final$insurance
Data_final <- select(Data_final, -weight) %>%
    mutate_at(c("iron", "calcium", "zinc", "sodium", "VA", "VC", "VE",
                "alcohol", "fat", "fiber", "sugar", "carbonhydrate",
                "energy", "protein"), times_insur) %>%
    right_join(Data_final, by = c("id", "survey_day", "gender", 
                                  "age_group", "income", "diabetes",
                                  "insurance"), suffix = c("_ins", "_ogn")) %>%
    select(-c("id", "weight", "insurance"))

# get the number of obs
Nnum <- nrow(Data_final)

# the number of obs as test data
test_Num <- round(0.2 * Nnum)

# the number of obs as train and cv data
train_Num <- Nnum - test_Num

# create data structure to store the optimal lambda from cross validation and 
# the AUC value for evaluzting model performance
#result <- matrix(NA, nrow = N_test, ncol = 2)

# building the model for N_test time in order to avoid overfitting problem
#t1 = proc.time()
result = foreach(i = 1:N_test) %dopar% {
    library(glmnet)
    library(ROCit)
    # divide data into training set and test set
    set.seed(50*i)
    test_id <- sample(1:Nnum, test_Num)
    test_data <- Data_final[test_id,]
    train_cv_data <- Data_final[-test_id,]
    
    
    # divide the dependent variables and response in the training set
    x_train <- model.matrix(diabetes ~ ., train_cv_data)[, -1]
    y_train <- train_cv_data$diabetes    
    
    # use cross validation metthod to find the optimal lambda parameter
    cv.lasso <- cv.glmnet(x_train, y_train, alpha = 1, family = "binomial", 
                          type.measure = "auc", parallel = TRUE)
    
    # use the lambda which gives the best AUC value and avoid improving model 
    # complexity to build our model
    model_small <- glmnet(x_train, y_train, alpha = 1, famaily = "binomial", 
                          lambda = cv.lasso$lambda.min)
    
    # store the optimal lambda value
    lambda <- cv.lasso$lambda.min
    
    # make prediction using test data
    x_test <- model.matrix(diabetes ~ ., test_data)[, -1]
    y_test <- test_data$diabetes
    y_hat_small <- predict.glmnet(model_small, newx = x_test, type = "response")
    
    # evaluate model performance on test data using ROC curve and AUC value
    ROC_obj_small <- rocit(score = as.vector(y_hat_small), class = y_test)
    
    # store the AUC value and plot the ROC curve
    # plot(ROC_obj_small)
    AUC <- ROC_obj_small$AUC    
    c(lambda, AUC)
}  
#t2 = proc.time() - t1
#t2

# building final model for all of our data 
result <- matrix(unlist(result), ncol = N_test, nrow = 2)
x_all <- model.matrix(diabetes~., Data_final)[, -1]
y_all <- Data_final$diabetes

# choose the mean value of the optimal lambdas above as the final optimal lambda
# for our final model
lambda_final <- rowMeans(result)[1]
model <- glmnet(x_all, y_all, family = "binomial", alpha = 1, lambda = lambda_final)

# the coefficients of the final model
beta_all <- coef(model)

# estimation of the final model performance using the average AUC value above
AUC_final <- rowMeans(result)[2]


stopCluster(cl)




