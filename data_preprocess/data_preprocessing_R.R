################################################################################
# Title: Data preprocessing for Group project 506
# Author: Jingxian Chen
# Version: 1.0
# Date: Nov 25th, 2019
################################################################################

#-------------------------------------------------------------------------------
# Description: This is the code to cleaning the data and extract the variables we
# want, then combine all the datasets together, and preprocessing the vaiables 
# like standardize the dietary data, grouping the age variables, removing missing 
# values.
#-------------------------------------------------------------------------------

library(SASxport)

Demographic_data <- read.xport("C:\\Users\\95260\\Desktop\\stats506\\group_project\\DEMO_I.XPT")
Diabetes_data <- read.xport("C:\\Users\\95260\\Desktop\\stats506\\group_project\\DIQ_I.XPT")
Day1_data <- read.xport("C:\\Users\\95260\\Desktop\\stats506\\group_project\\DR1TOT_I.XPT")
Day2_data <- read.xport("C:\\Users\\95260\\Desktop\\stats506\\group_project\\DR2TOT_I.XPT")
Insurance_data <- read.xport("C:\\Users\\95260\\Desktop\\stats506\\group_project\\HIQ_I.XPT")

################################################################################
### Data Pre-processing

## Selecting variables 
library(tidyverse)
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
                 #   mutate_at(vars(-c("id", "weight")), scale)  %>%
                    mutate(survey_day = factor(1))

## Day2 data

New_Day2_dat <- New_Day2_dat %>%
                    filter(weight != 0) %>%
                    filter_all(all_vars(!is.na(.))) %>%
                 #   mutate_at(vars(-c("id", "weight")), scale) %>%
                    mutate(survey_day = factor(2))

################################################################################

# Merge all dataset together

Data_final <- New_Day1_dat %>%
                rbind(New_Day2_dat) %>% 
                    inner_join(New_Demo_dat, by = "id") %>%
                        inner_join(New_Diabetes_dat, by = "id") %>%
                            inner_join(New_Insur_dat, by = "id")

################################################################################


