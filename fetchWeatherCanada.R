install.packages("weathercan", repos = "https://ropensci.r-universe.dev", dependencies = TRUE)
install.packages("tidyverse", dependencies = TRUE)
library("weathercan")
library("tidyverse")

stations <- stations() %>%
  filter(end > 2019,
         prov %in% c("QC", "ON", "BC"),
         interval == "day")

data <- weather_dl(station_ids = as.vector(stations$station_id), start = "2009-01-01", end = "2019-12-31", interval = "day")


#a <- stations %>% group_by(prov) %>% summarise(count = n())

write.csv(data,"weatherData.csv",row.names = FALSE)
#data <- read.csv("weatherData.csv")

data <- data %>% select(prov, year, month, mean_temp, max_temp, min_temp, min_temp,
                        total_precip,total_rain, total_snow, spd_max_gust)


keys <- c('prov', 'year', 'month')
data_grouped <- data %>% group_by(across(all_of(keys))) %>% summarise(mean_temp = mean(!is.na(data$mean_temp)),
                                                                   median_temp = median(!is.na(data$mean_temp)),
                                                                   max_temp = max(!is.na(data$max_temp)),
                                                                   min_temp = min(!is.na(data$min_temp)),
                                                                   total_precip = sum(!is.na(data$total_precip)),
                                                                   total_rain = sum(!is.na(data$total_rain)),
                                                                   total_snow = sum(!is.na(data$total_snow)),
                                                                   spd_max_gust = max(!is.na(spd_max_gust)), .groups = "keep")
                                                   