################################################################################
# Title: Model establishing for Group project 506
# Author: Jingxian Chen
# Version: 1.0
# Date: Dec 6th, 2019
################################################################################
## load data
source("C:/Users/95260/Desktop/data_preprocessing.R")

### Modeling part
library(glmnet)
library(ROCit)
library(doParallel)
N_test <- 100
times_insur <- function(x) x * Data_final$insurance
Data_final <- select(Data_final, -weight) %>%
    mutate_at(c("iron", "calcium", "zinc", "sodium", "VA", "VC", "VE",
                "alcohol", "fat", "fiber", "sugar", "carbonhydrate",
                "energy", "protein"), times_insur) %>%
    right_join(Data_final, by = c("id", "survey_day", "gender", 
                                  "age_group", "income", "diabetes",
                                  "insurance"), suffix = c("_ins", "_ogn")) %>%
    select(-c("id", "weight", "insurance"))
Nnum <- nrow(Data_final)
test_Num <- round(0.2 * Nnum)
train_Num <- Nnum - test_Num


lambda <- vector()
beta <- matrix(NA, ncol = N_test, nrow = 46)
AUC <- vector()
for(i in 1:N_test){
    set.seed(50*i)
    test_id <- sample(1:Nnum, test_Num)
    test_data <- Data_final[test_id,]
    train_cv_data <- Data_final[-test_id,]
    
    
    ### build model
    x_train <- model.matrix(diabetes ~ ., train_cv_data)[, -1]
    y_train <- train_cv_data$diabetes    
    
    ### choose lambda using cv
    cv.lasso <- cv.glmnet(x_train, y_train, alpha = 1, family = "binomial", type.measure = "auc")
    ## use the lambda which minimize the trainning error
    #   model_min <- glmnet(x_train, y_train, alpha = 1, famaily = "binomial", 
    #                   lambda = cv.lasso$lambda.min)
    #   beta_min <- coef(model_min)
    
    ## use the lambda which gives the best trade off on the model complex level and error
    model_small <- glmnet(x_train, y_train, alpha = 1, famaily = "binomial", 
                          lambda = cv.lasso$lambda.1se)
    lambda[i] <- cv.lasso$lambda.1se
    beta <- as.matrix(coef(model_small))
    
    ### make prediction
    x_test <- model.matrix(diabetes ~ ., test_data)[, -1]
    y_test <- test_data$diabetes
    y_hat_small <- predict.glmnet(model_small, newx = x_test, type = "response")
    #   y_hat_min <- predict.glmnet(model_min, newx = x_test, type = "response")            
    
    ### compute accuracy using ROC curve
    ROC_obj_small <- rocit(score = as.vector(y_hat_small), class = y_test)
    plot(ROC_obj_small)
    AUC[i] <- ROC_obj_small$AUC    
    
    #    ROC_obj_min <- rocit(score = as.vector(y_hat_min), class = y_test)
    #    plot(ROC_obj_min)
    #    AUC_min <- ROC_obj_min$AUC
    
    #    cat(AUC_small, AUC_min)
    cat(i," done!\n") 
}  



## final model for all data we have
x_all <- model.matrix(diabetes~., Data_final)[, -1]
y_all <- Data_final$diabetes
lambda_final <- mean(lambda)
model <- glmnet(x_all, y_all, family = "binomial", alpha = 1, lambda = lambda_final)
beta_all <- coef(model)

## estimate AUC for final model
AUC_final <- mean(AUC)


