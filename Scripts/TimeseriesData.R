library(dplyr)
library(tidyverse)
library(scales)

### DATA CLEANING ###

budgetData <- read.csv("C:\\Users\\tyler\\OneDrive - University of Virginia\\Semesters\\FALL 2021\\STS 2500\\City_Budget_and_Expenditures.csv")
crimeData <- read.csv("C:\\Users\\tyler\\OneDrive - University of Virginia\\Semesters\\FALL 2021\\STS 2500\\Crime_Data_from_2010_to_2019.csv")

listOfDepartments <- levels(factor(budgetData$DEPARTMENT.NAME))

# clean budget
budgetDataGrouped <- budgetData %>%
  dplyr::select(-c(FUND.NAME,ACCOUNT.NAME)) %>%
  filter(DEPARTMENT.NAME=="ECONOMIC AND WORKFORCE DEVELOPMENT DEPARTMENT"|DEPARTMENT.NAME=="NEIGHBORHOOD EMPOWERMENT"|DEPARTMENT.NAME=="POLICE"|DEPARTMENT.NAME=="RECREATION AND PARKS"|DEPARTMENT.NAME=="TRANSPORTATION") %>%
  mutate(TOTAL.BUDGET = TOTAL.BUDGET/(10^9)) %>%
  filter(BUDGET.FISCAL.YEAR < 2022) %>%
  group_by(DEPARTMENT.NAME, BUDGET.FISCAL.YEAR) %>%
  summarize(BUDGET = sum(TOTAL.BUDGET))

# clean crime
crimeDataSummarized <- crimeData %>%
  mutate(year = as.integer(substring(DATE.OCC, 7, 10))) %>%
  filter(year>2011) %>%
  group_by(year) %>%
  summarize(crime_count = n()) %>%
  mutate(crime_count = crime_count/1000) %>%
  rename(BUDGET.FISCAL.YEAR = year)

# join data to run multiple linear regresion model on
model.data <- budgetDataGrouped%>%inner_join(crimeDataSummarized, by="BUDGET.FISCAL.YEAR")

# Manually fixed data in excel. Made each department a column with its budget as the values and combined with poverty data from 2012-2019.
write.csv(model.data, "C:\\Users\\tyler\\OneDrive - University of Virginia\\Semesters\\FALL 2021\\STS 2500\\BudgetData.csv")
model.data <- read.csv("C:\\Users\\tyler\\OneDrive - University of Virginia\\Semesters\\FALL 2021\\STS 2500\\BudgetData.csv")

### MODEL BUILDING ###

# Remove bad features
model.data <- model.data%>%dplyr::select(-BUDGET.FISCAL.YEAR)
model.data <- model.data%>%dplyr::select(-NEIGHBORHOOD.EMPOWERMENT)

library(MASS)

# build linear regression model
model <- lm(CRIME.AMOUNT~., model.data)

summary(model)

# run AIC optimization and train model
AICmodel <- stepAIC(model, direction="both",  trace=T)

summary(AICmodel)

### GRAPHS AND CORRELATION COEFFICIENTS ###

# graph budget by department
ggplot(data=budgetDataGrouped) +
  geom_line(mapping=aes(x=BUDGET.FISCAL.YEAR,y=BUDGET,color=DEPARTMENT.NAME), show.legend=FALSE) +
  ylab("Total Budget ($ in billions)") +
  xlab("Fiscal Year") +
  scale_x_continuous(breaks= pretty_breaks())

# graph crime
ggplot(data = crimeDataSummarized) +
  geom_line(mapping=aes(x=year,y=crime_count)) +
  ylab("Total Crimes (Thousands)") +
  xlab("Year")

# EWDD: -0.1020336
budget_for_corr_EWDD <- budgetDataGrouped %>%
  filter(DEPARTMENT.NAME == "ECONOMIC AND WORKFORCE DEVELOPMENT DEPARTMENT") %>%
  group_by(DEPARTMENT.NAME) %>%
  dplyr::select(BUDGET.FISCAL.YEAR,BUDGET)

corr_EWDD_crime <- full_join(budget_for_corr_EWDD,crimeDataSummarized,by = c("BUDGET.FISCAL.YEAR"="year")) %>%
  ungroup() %>%
  dplyr::select(BUDGET.FISCAL.YEAR,BUDGET,crime_count)

cor(corr_EWDD_crime$crime_count,corr_EWDD_crime$BUDGET)

# NE - Neighborhood empowerment: 0.3495834
budget_for_corr_NE <- budgetDataGrouped %>%
  filter(DEPARTMENT.NAME == "NEIGHBORHOOD EMPOWERMENT") %>%
  group_by(DEPARTMENT.NAME) %>%
  dplyr::select(BUDGET.FISCAL.YEAR,BUDGET)

corr_NE_crime <- full_join(budget_for_corr_NE,crimeDataSummarized,by = c("BUDGET.FISCAL.YEAR"="year")) %>%
  ungroup() %>%
  dplyr::select(BUDGET.FISCAL.YEAR,BUDGET,crime_count)

cor(corr_NE_crime$crime_count,corr_NE_crime$BUDGET)

# Police: -0.3743994
budget_for_corr_POLICE <- budgetDataGrouped %>%
  filter(DEPARTMENT.NAME == "POLICE") %>%
  group_by(DEPARTMENT.NAME) %>%
  dplyr::select(BUDGET.FISCAL.YEAR,BUDGET)

corr_Police_crime <- full_join(budget_for_corr_POLICE,crimeDataSummarized,by = c("BUDGET.FISCAL.YEAR"="year")) %>%
  ungroup() %>%
  dplyr::select(BUDGET.FISCAL.YEAR,BUDGET,crime_count)

cor(corr_Police_crime$crime_count,corr_Police_crime$BUDGET)

# RAP: -0.3982431
budget_for_corr_RAP <- budgetDataGrouped %>%
  filter(DEPARTMENT.NAME == "RECREATION AND PARKS") %>%
  group_by(DEPARTMENT.NAME) %>%
  dplyr::select(BUDGET.FISCAL.YEAR,BUDGET)

corr_RAP_crime <- full_join(budget_for_corr_RAP,crimeDataSummarized,by = c("BUDGET.FISCAL.YEAR"="year")) %>%
  ungroup() %>%
  dplyr::select(BUDGET.FISCAL.YEAR,BUDGET,crime_count)

cor(corr_RAP_crime$crime_count,corr_RAP_crime$BUDGET)

# Transportation: -0.5424196
budget_for_corr_TR <- budgetDataGrouped %>%
  filter(DEPARTMENT.NAME == "TRANSPORTATION") %>%
  group_by(DEPARTMENT.NAME) %>%
  dplyr::select(BUDGET.FISCAL.YEAR,BUDGET)

corr_tr_crime <- full_join(budget_for_corr_TR,crimeDataSummarized,by = c("BUDGET.FISCAL.YEAR"="year")) %>%
  ungroup() %>%
  dplyr::select(BUDGET.FISCAL.YEAR,BUDGET,crime_count)

cor(corr_tr_crime$crime_count,corr_tr_crime$BUDGET)



