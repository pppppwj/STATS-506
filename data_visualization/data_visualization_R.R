################################################################################
# Title: Data visualization for Group project 506
# Author: Jingxian Chen
# Version: 1.0
# Date: Dec 6th, 2019
################################################################################

#-------------------------------------------------------------------------------
# Description: This code is to visualize the data to get a better look on the data
# we have, and see some trends before we build the model, here we use the final
# data without dietary variables being standardized.
#-------------------------------------------------------------------------------

## load data
library(cowplot)
source("D:/Files/stats506/group_project/data_preprocessing.R")

### Exploratory Data Analysis

## Compare the average microelement intake amount at each age, gender and 
## insurance level between day1 and day2.
data_nodiab <- Data_final %>%
    filter(diabetes == 0 & survey_day == 1) %>%
    select(c("weight", "age_group", "gender", "insurance","zinc",
             "iron", "sodium")) %>%
    group_by(age_group, gender, insurance) %>%
    summarise(avg_iron = sum(iron * weight) / sum(weight),
              avg_zinc = sum(zinc * weight) / sum(weight),
              avg_sodium = sum(sodium * weight) / sum(weight))

data_diab <- Data_final %>%
    filter(diabetes == 1 & survey_day == 1) %>%
    select(c("weight", "age_group", "gender", "insurance","zinc",
             "iron", "sodium")) %>%
    group_by(age_group, gender, insurance) %>%
    summarise(avg_iron = sum(iron * weight) / sum(weight),
              avg_zinc = sum(zinc * weight) / sum(weight),
              avg_sodium = sum(sodium * weight) / sum(weight))

data_combined <- data_nodiab %>%
    inner_join(data_diab, by = c("age_group", "gender", "insurance"),
               suffix = c("_nodb", "_db")) %>%
    # mutate(iron_diff = avg_iron_nodb - avg_iron_db,
    #       zinc_diff = avg_zinc_nodb - avg_zinc_db,
    #      sodium_diff = avg_sodium_nodb - avg_sodium_db) %>%
    pivot_longer(cols = -c("age_group", "gender", "insurance"),
                 names_to = c(".value", "diabetes"), 
                 names_pattern = "(avg_.*[_$])(db|nodb)") %>%
    mutate(group_id = paste(paste(age_group, substr(gender,1,1),sep = "_"), 
                            insurance, sep = "_"))


fig_zinc <- ggplot(data_combined, aes(x = group_id, y = avg_zinc_, fill = diabetes, 
                                      shape = diabetes, color = diabetes)) +
    geom_bar(position = "dodge", stat = "identity") +
    geom_text(aes(label=round(avg_zinc_,1)), color = "black", 
              position = position_dodge(1), size=4) + coord_polar() +
    labs(y = "zinc amount(mg)", title = "Zinc(mg)", 
         subtitle = "Zinc intake amount(mg) among each group of people")

fig_iron <- ggplot(data_combined, aes(x = group_id, y = avg_iron_, fill = diabetes, 
                                      shape = diabetes, color = diabetes)) +
    geom_bar(position = "dodge", stat = "identity") +
    geom_text(aes(label=round(avg_iron_,1)), color = "black", 
              position = position_dodge(1), size=4) + coord_polar() +
    labs(y = "Iron(mg)", title = "Iron(mg)", 
         subtitle = "Iron intake amount(mg) among each group of people")

fig_sodium <- ggplot(data_combined, aes(x = group_id, y = avg_sodium_, fill = diabetes, 
                                        shape = diabetes, color = diabetes)) +
    geom_bar(position = "dodge", stat = "identity") +
    geom_text(aes(label=round(avg_sodium_)), color = "black", 
              position = position_dodge(1), size=3) + coord_polar() +
    labs(y = "Sodium(mg)", title = "Sodium(mg)", 
         subtitle = "Sodium intake amount(mg) among each group of people")

plot_grid(fig_zinc, fig_iron, fig_sodium, nrow = 1)
