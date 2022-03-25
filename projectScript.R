#Import Libraries
library(tidyverse)
library(readxl)
library(ggcorrplot)
library(plm)
library(stargazer)
library(car)
library(naniar)
library(VIM)
library(FactoMineR)
library(factoextra)
library(knitr)
library(kableExtra)
library(sjPlot)


retail_monthly = read.csv("Data/monthlyRetailSales.csv")
weather_monthly = read.csv("Data/monthlyWeather.csv")

retail_monthly <- retail_monthly %>% group_by(date) %>% summarize(British.Columbia=sum(British.Columbia),
                                                                  Ontario=sum(Ontario),
                                                                  Quebec=sum(Quebec))
retail_monthly <- retail_monthly %>% pivot_longer(!date, names_to = "prov", values_to = "sales")
retail_monthly <- retail_monthly %>% mutate(prov = case_when(prov == "British.Columbia" ~ "BC",
                                                             prov == "Ontario" ~ "ON",
                                                             prov == "Quebec" ~ "QC"))
retail_monthly <- retail_monthly %>% arrange(prov, date)

data_monthly <- merge(retail_monthly, weather_monthly, by = c("date", "prov"))
data_monthly$month <- substr(data_monthly$date,6,8)


cpi <- read_excel("Data/controlVariablesMonthly.xlsx", sheet="cpiIndex")
disposable_income <- read_excel("Data/controlVariablesMonthly.xlsx", sheet="disposableIncome")
unemployment_rate <- read_excel("Data/controlVariablesMonthly.xlsx", sheet="unemploymentRate")
consumer_confidence <- read_excel("Data/controlVariablesMonthly.xlsx", sheet="consumerConfidence")

control_data <- merge(cpi, consumer_confidence, by=c("date","prov"))
control_data <- merge(control_data, unemployment_rate, by=c("date","prov"))
control_data$year <- substr(control_data$date,1,4)
control_data <- merge(control_data, disposable_income, by=c("year","prov"), all.x=TRUE)

data_monthly <- merge(data_monthly, control_data, by=c("date","prov")) %>%
  select(date, year, month, prov, sales, max_temp, mean_temp, min_temp, spd_max_gust, total_precip, total_rain, total_snow, cpi_index, disposable_income, unemployment_rate, consumer_confidence) %>% arrange(prov,date)

corr<- round(cor(data_monthly[5:16]), 3)

df <- data_monthly %>% mutate_at(c("max_temp", "mean_temp", "min_temp", "spd_max_gust", "total_precip", "total_rain", "total_snow", "cpi_index", "disposable_income", "unemployment_rate", "consumer_confidence"), ~(scale(.) %>% as.vector))

df$sales <- log(df$sales+1)

df[6:16] <- replace_with_na_all(df[6:16], ~.x >3) #Treat values more than 3 (Standard values) as outliers
df = kNN(df, k=6)[1:16] #kNN imputation

#remove min_temp, max_temp, total_precip because high correlation with mean_temp and total_rain
df <- df %>% select(!c(min_temp, max_temp, total_precip))

df <- df %>% mutate(winter = case_when(month == 1 | month == 2| month ==3 |month==12 ~ 1,
                                       TRUE ~ 0))
                                       

### 6. Modelling
#1. Linear Models
#a) Create a pooled OLS model using only control variables
#Model1: Pooled OLS model for the monthly data
model_1 = lm(sales ~ consumer_confidence + cpi_index + disposable_income + unemployment_rate, data=df)
summary(model_1)
vif(model_1)

#b) Add weather factors to base model
#The impact of our control variables in predicting retail sales is very big, it diminishes the effect of weather variables. Therefore we need to reduce the number of control variables in the predictive model to study the impact of weather on retail sales.

#Add each control variables seperately with predictor variables in models from lm1 to lm4
#lm0 - weather factors alone

model_2 = lm(sales ~ consumer_confidence + cpi_index + disposable_income + unemployment_rate + total_snow + total_rain + mean_temp +
               spd_max_gust, data = df)
summary(model_2)
vif(model_2)

#c)lm0
lm0 = lm(sales ~ total_snow + total_rain + mean_temp + spd_max_gust, data=df)
summary(lm0)
vif(lm0)

#d)lm1 - weather + consumer_confidence
lm1 = lm(sales ~ consumer_confidence + total_snow + total_rain + mean_temp + spd_max_gust +
           winter + winter*total_rain + winter*total_snow + winter*spd_max_gust + I(mean_temp^2), data=df)
summary(lm1)
vif(lm1)

#e)lm2 - weather + cpi_index
lm2 = lm(sales ~ cpi_index + total_snow + total_rain + mean_temp + spd_max_gust +
           winter + winter*total_rain + winter*total_snow + winter*spd_max_gust + I(mean_temp^2), data=df)
summary(lm2)
vif(lm2)

#f)lm3 - weather + disposable_income
lm3 = lm(sales ~ disposable_income + total_snow + total_rain + mean_temp + spd_max_gust +
           winter + winter*total_rain + winter*total_snow + winter*spd_max_gust + I(mean_temp^2), data=df)
summary(lm3)
vif(lm3)

#g)lm4 - weather + unemployment_rate
lm4 = lm(sales ~ unemployment_rate + total_snow + total_rain + mean_temp + spd_max_gust +
           winter + winter*total_rain + winter*total_snow + winter*spd_max_gust + I(mean_temp^2), data=df)
summary(lm4)
vif(lm4)

