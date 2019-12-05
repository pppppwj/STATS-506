################################################################################
# Title: Data preprocessing for Group project 506
# Author: Jingxian Chen
# Version: 1.0
# Date: Nov 25th, 2019
################################################################################
library(SASxport)

Demographic_data <- read.xport("C:\\Users\\95260\\Desktop\\stats506\\group_project\\DEMO_I.XPT")
Diabetes_data <- read.xport("C:\\Users\\95260\\Desktop\\stats506\\group_project\\DIQ_I.XPT")
Day1_data <- read.xport("C:\\Users\\95260\\Desktop\\stats506\\group_project\\DR1TOT_I.XPT")
Day2_data <- read.xport("C:\\Users\\95260\\Desktop\\stats506\\group_project\\DR2TOT_I.XPT")
Insurance_data <- read.xport("C:\\Users\\95260\\Desktop\\stats506\\group_project\\HIQ_I.XPT")

################################################################################
### Data Pre-processing

## Selecting variables 
library(dplyr)
## Demographic data
New_Demo_dat <- Demographic_data %>%
                    select("id" = SEQN, 
                           "gender" = RIAGENDR, 
                           "age" = RIDAGEYR,
                           "income" = INDFMIN2)

## Diabetes data
New_Diabetes_dat <- Diabetes_data %>%
                        select("id" = SEQN,
                               "diabetes" = DIQ010)

## Insurance data
New_Insur_dat <- Insurance_data %>%
                        select("id" = SEQN,
                               "insurance" = HIQ011)

## Day1 data
New_Day1_dat <- Day1_data %>%
                        select("id" = SEQN,
                               "weight" = WTDRD1,
                               "iron" = DR1TIRON,
                               "calcium" = DR1TCALC,
                               "zinc" = DR1TZINC,
                               "sodium" = DR1TSODI,
                               "VE" = DR1TATOC,
                               "VA" = DR1TVARA,
                               "VC" = DR1TVC,
                               "alcohol" = DR1TALCO,
                               "fat" = DR1TTFAT,
                               "fiber" = DR1TFIBE,
                               "sugar" = DR1TSUGR,
                               "carbonhydrate" = DR1TCARB,
                               "energy" = DR1TKCAL,
                               "protein" = DR1TPROT)

New_Day2_dat <- Day2_data %>%
                        select("id" = SEQN,
                               "weight" = WTDR2D,
                               "iron" = DR2TIRON,
                               "calcium" = DR2TCALC,
                               "zinc" = DR2TZINC,
                               "sodium" = DR2TSODI,
                               "VE" = DR2TATOC,
                               "VA" = DR2TVARA,
                               "VC" = DR2TVC,
                               "alcohol" = DR2TALCO,
                               "fat" = DR2TTFAT,
                               "fiber" = DR2TFIBE,
                               "sugar" = DR2TSUGR,
                               "carbonhydrate" = DR2TCARB,
                               "energy" = DR2TKCAL,
                               "protein" = DR2TPROT)

################################################################################

## Demographic data
New_Demo_dat <- New_Demo_dat %>%
                    filter(!is.na(income) & income != 12 & income  != 13 
                           & income != 77 & income != 99) %>%
                    transmute(id = id,
                              gender = factor(gender, labels =c("male","female")),
                              age_group = factor(ifelse(age < 13, 1,
                                                    ifelse(age < 19,2,
                                                        ifelse(age < 41, 3,
                                                            ifelse(age < 60, 4, 5)))),
                                                 labels = c("younger", "teenager",
                                                            "adult", "seniors", "elder")),
                              income = factor(ifelse(income == 14 | income ==15, income - 2,
                                              income))
                              )

################################################################################

## Insurance data

# remove values other than 1 or 2 and divide insurance variable into 2 columns
New_Insur_dat <- New_Insur_dat %>%
                      filter(insurance != 7 & insurance != 9) %>%
                           transmute(id = id,
                                      insurance = ifelse(insurance == 1, 1, 0))

################################################################################

## diabetes data

# remove values other than 1 or 2, and change 2 to 0

New_Diabetes_dat <- New_Diabetes_dat %>%
                        filter(!is.na(diabetes) & diabetes != 3 & diabetes != 9) %>%
                        transmute(id = id,
                                  diabetes = ifelse(diabetes == 2, 0, 1))

################################################################################

## Day1 data
 
New_Day1_dat <- New_Day1_dat %>%
                    filter(weight != 0) %>%
                    filter_at(vars(-c("id", "weight")), all_vars(!is.na(.))) %>%
                    mutate_at(vars(-c("id", "weight")), scale)  %>%
                    mutate(survey_day = factor(1))

## Day2 data

New_Day2_dat <- New_Day2_dat %>%
                    filter(weight != 0) %>%
                    filter_all(all_vars(!is.na(.))) %>%
                    mutate_at(vars(-c("id", "weight")), scale) %>%
                    mutate(survey_day = factor(2))

################################################################################

# Merge all dataset together

Data_final <- New_Day1_dat %>%
                rbind(New_Day2_dat) %>% 
                    inner_join(New_Demo_dat, by = "id") %>%
                        inner_join(New_Diabetes_dat, by = "id") %>%
                            inner_join(New_Insur_dat, by = "id")

################################################################################

### Exploratory Data Analysis

## Compare the average microelement intake amount at each age, gender and 
## insurance level between day1 and day2.

##############################################################################

library(glmnet)
library(ROCit)
N_test <- 1
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


lambda_final <- mean(lambda)
AUC_final <- mean(AUC)

## final model for all data we have
x_all <- model.matrix(diabetes~., Data_final)[, -1]
y_all <- Data_final$diabetes
model <- glmnet(x_all, y_all, family = "binomial", alpha = 1, lambda = lambda_final)
beta_all <- coef(model)
