// Group 1 Project - STATS 506
// Program: STATA 
// Author: Eric Hernandez-Montenegro
// Last Modified On: 12/10/2019

*-------------------------------------------------------------------------------
* This Do-File serves the purpose for cleaning the data and preparing it 
* for analysis.
*-------------------------------------------------------------------------------

// Load Demographic Data
fdause https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/DEMO_I.XPT, clear

// Keep relevant variables
keep seqn riagendr ridageyr indfmin2

// Rename variables
rename seqn id
rename riagendr gender
rename ridageyr age
rename indfmin2 income

// Drop Missing Observations
drop if id == .
drop if gender == .
drop if age == .
drop if income == .

// Recode gender
// Male - 1
// Female - 0
*replace gender = 0  if gender == 2

// Recode by Age
// 1 - Age 0-12
// 2 - 12-18 Teenager
// 3 - 18-40
// 4 - 40 - 59
// 5 - 59+

gen age1 = inrange(age,0,12)
gen age2 = inrange(age,13,18)
replace age2 = 2 if age2 == 1
gen age3 = inrange(age,19,40)
replace age3 = 3 if age3 == 1
gen age4 = inrange(age,41,59)
replace age4 = 4 if age4 == 1
gen age5 = inrange(age,60,1000)
replace age5 = 5 if age5 == 1

gen age_full = age1 + age2 + age3 + age4 + age5
replace age = age_full
drop age1 age2 age3 age4 age5 age_full

// Drop some of the income variables
drop if  income == 12
drop if income ==  13
drop if income == 77
drop if income == 99

// Recode income variables
replace income = 12 if income == 14
replace income = 13 if income == 15 

// Save demographic data
save demo_data, replace

* -----------------------------------------------------------------------------

// Load Health Insurance Data
fdause https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/HIQ_I.XPT, clear

// Keep relevant variables
keep seqn hiq011

// Rename variables
rename seqn id
rename hiq01 insurance1

// Recode insurance1 variable
// 0 - No Insurance
// 1 - Insurance
replace insurance1 = 0 if insurance1 == 2

// Drop refused, don't know, and missing data from insurance
keep if insurance1 == 0 | insurance1 == 1

// Generate second insurance variable
generate insurance2 = insurance1 - insurance1
replace insurance2 = 1 if insurance1 == 0

// Save Insurance Data
save ins_data, replace

// Merge Demographic and Health Insurance Data
merge 1:1 id using demo_data

// Keep only matching/merged observations
keep if _merge == 3
drop _merge

save main_data, replace

* -----------------------------------------------------------------------------

// Load Diabetes Data
fdause https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/DIQ_I.XPT, clear

// Keep relevant variables
keep seqn diq010

// Rename variables
rename seqn id
rename diq010 diabetes

// Re-Code diabetes variable
// 0 - No diabetes
// 1 - Diabetes
replace diabetes = 0 if diabetes == 2

// Drop observations other than yes and no
keep if diabetes == 0 | diabetes == 1

// Save diabetes data
save diabetes_data, replace

// Merge with main data set
merge 1:1 id using main_data

// Keep only matching/merged observations
keep if _merge == 3
drop _merge

save main_data, replace

* -----------------------------------------------------------------------------

// Load Total Foods Data Day 1
fdause https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/DR1TOT_I.XPT, clear

// Keep relevant variables
keep seqn wtdrd1 wtdr2d dr1tiron dr1tcalc dr1tzinc dr1tsodi dr1tatoc dr1tvara dr1talco dr1tvc dr1ttfat dr1tfibe dr1tsugr dr1tcarb dr1tkcal dr1tprot

// Rename variables
rename seqn id 
rename wtdrd1 weight1
rename wtdr2d weight2
rename dr1tiron iron
rename dr1tcalc calcium
rename dr1tzinc zinc
rename dr1tsodi sodium
rename dr1tatoc ve
rename dr1tvara va
rename dr1talco alcohol
rename dr1tvc   vc
rename dr1ttfat fat
rename dr1tfibe fiber
rename dr1tsugr sugars
rename dr1tcarb carbohydrate
rename dr1tkcal energy
rename dr1tprot protein

// Drop observations with missing data
drop if id == .
drop if energy == .
drop if protein == .
drop if carbohydrate == .
drop if sugars == .
drop if fiber == .
drop if fat == .
drop if ve == .
drop if va == .
drop if vc == .
drop if calcium == .
drop if iron == .
drop if zinc == .
drop if sodium == .
drop if alcohol == .

// Generate day of survey
generate survey_day = 1

// Standardize Food Data
egen std_energy = std(energy)
egen std_protein = std(protein)
egen std_carbohydrate = std(carbohydrate)
egen std_sugars = std(sugars)
egen std_fiber = std(fiber)
egen std_fat = std(fat)
egen std_ve = std(ve)
egen std_va = std(va)
egen std_vc = std(vc)
egen std_calcium = std(calcium)
egen std_iron = std(iron)
egen std_zinc = std(zinc)
egen std_sodium = std(sodium)
egen std_alcohol = std(alcohol)

// Replace Food variables with their standardized versions
replace energy = std_energy
replace protein = std_protein
replace carbohydrate = std_carbohydrate
replace sugars = std_sugars
replace fiber = std_fiber
replace fat = std_fat
replace ve = std_ve
replace va = std_va
replace vc = std_vc
replace calcium = std_calcium
replace iron = std_iron
replace zinc = std_zinc
replace sodium = std_sodium
replace alcohol = std_alcohol

drop std*

// Recreate weight variable
replace weight1 = weight2 if survey_day == 2
rename weight1 weight
drop weight2
drop if weight == .

// Arrange data
order id survey_day

// Save day 1 total data
save day1_total, replace

* -----------------------------------------------------------------------------

// Load Total Foods Data Day 2
fdause https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/DR2TOT_I.XPT, clear

// Keep relevant variables
keep seqn wtdrd1 wtdr2d dr2tiron dr2tcalc dr2tzinc dr2tsodi dr2tatoc dr2tvara dr2talco dr2tvc dr2ttfat dr2tfibe dr2tsugr dr2tcarb dr2tkcal dr2tprot

// Rename variables
rename seqn id 
rename wtdrd1 weight1
rename wtdr2d weight2
rename dr2tiron iron
rename dr2tcalc calcium
rename dr2tzinc zinc
rename dr2tsodi sodium
rename dr2tatoc ve
rename dr2tvara va
rename dr2talco alcohol
rename dr2tvc vc
rename dr2ttfat fat
rename dr2tfibe fiber
rename dr2tsugr sugars
rename dr2tcarb carbohydrate
rename dr2tkcal energy
rename dr2tprot protein

// Drop observations with missing data
drop if id == .
drop if energy == .
drop if protein == .
drop if carbohydrate == .
drop if sugars == .
drop if fiber == .
drop if fat == .
drop if ve == .
drop if va == .
drop if vc == .
drop if calcium == .
drop if iron == .
drop if zinc == .
drop if sodium == .
drop if alcohol == .

// Generate survey day 
generate survey_day = 2

// Standardize food variables
egen std_energy = std(energy)
egen std_protein = std(protein)
egen std_carbohydrate = std(carbohydrate)
egen std_sugars = std(sugars)
egen std_fiber = std(fiber)
egen std_fat = std(fat)
egen std_ve = std(ve)
egen std_va = std(va)
egen std_vc = std(vc)
egen std_calcium = std(calcium)
egen std_iron = std(iron)
egen std_zinc = std(zinc)
egen std_sodium = std(sodium)
egen std_alcohol = std(alcohol)

// Replace Food variables with their standardized versions
replace energy = std_energy
replace protein = std_protein
replace carbohydrate = std_carbohydrate
replace sugars = std_sugars
replace fiber = std_fiber
replace fat = std_fat
replace ve = std_ve
replace va = std_va
replace vc = std_vc
replace calcium = std_calcium
replace iron = std_iron
replace zinc = std_zinc
replace sodium = std_sodium
replace alcohol = std_alcohol

drop std*


// Recreate weight variable
replace weight1 = weight2 if survey_day == 2
rename weight1 weight
drop weight2

drop if weight == .

// Order data
order id survey_day

// Save day 2 data
save day2_total, replace

// Append day 1 and day 2 data
append using day1_total

// Sort data by id
sort id survey_day

// Save data
save day1_day2_data, replace

// Merge day 1 and day 2 data with main data
merge m:1 id using main_data

// Keep only matching/merged observations
keep if _merge == 3
drop _merge

// Order Data
order id survey_day weight diabetes insurance1 insurance2 gender age income

save main_data, replace

export delimited main_data_csv_eric_stata.csv, replace

