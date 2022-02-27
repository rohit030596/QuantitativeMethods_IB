#install.packages("weathercan", repos = "https://ropensci.r-universe.dev", dependencies = TRUE)
#install.packages("tidyverse", dependencies = TRUE)
library("weathercan")
library("tidyverse")


geo_tags <- list(c( 45.581123, -73.54183), c( 45.486562, -73.55466), c( 45.536474, -73.660213), c( 45.493439, -73.654601), c( 43.757456, -79.488873), c( 43.715277, -79.377565), c( 43.707462, -79.345824), c( 43.669418, -79.339293), c( 43.71133, -79.308685), c( 43.709176, -79.473413), c( 43.667642, -79.487672), c( 43.715478, -79.554358), c( 49.258896, -123.026609), c( 49.26381, -123.115912), c( 49.278541, -123.110221), c( 49.289914, -123.132844), c( 49.26815, -123.156155))
s <- stations_search(coords = geo_tags[[1]], dist = 20, interval = "day") %>% filter(end > 2020)
#s_final <- s[order(s$distance),][1, ]
s$lat_long <- 1
s_final <- s[order(s$distance),]

i = 1
for (x in geo_tags[2:length(geo_tags)]){
  i = i+1
  s <- stations_search(coords = x, dist = 20, interval = "day") %>% filter(end > 2020)
  #s <- s[order(s$distance),][1, ]
  s$lat_long <- i
  s_final<- rbind(s_final, s[order(s$distance),])
}

stations <- distinct(s_final %>% select(station_name,station_id))

data <- weather_dl(station_ids = as.vector(stations$station_id), start = "2018-12-31", end = "2021-10-24", interval = "day")

data <- data %>% select(prov, station_name, station_id, date, mean_temp, max_temp, min_temp, min_temp,
                        total_precip,total_rain, total_snow, spd_max_gust)

lat_long <- s_final %>% select(station_name,station_id, distance, lat_long)

df <- merge(x = data, y = lat_long, by = "station_id", all.x = TRUE)

write.csv(df,"WeatherActual.csv",row.names = FALSE)
#write.csv(lat_long,"lat_long.csv",row.names = FALSE)

# stations <- stations() %>%
#   filter(end > 2019,
#          prov %in% c("QC", "ON", "BC"),
#          interval == "day")

#data <- weather_dl(station_ids = as.vector(stations$station_id), start = "2009-01-01", end = "2019-12-31", interval = "day")


#a <- stations %>% group_by(prov) %>% summarise(count = n())

# write.csv(data,"weatherData.csv",row.names = FALSE)
# data <- read.csv("weatherData.csv")

# data <- data %>% select(prov, year, month, mean_temp, max_temp, min_temp, min_temp,
#                         total_precip,total_rain, total_snow, spd_max_gust)



# keys <- c('prov', 'year', 'month')
# data_grouped <- data %>% group_by(across(all_of(keys))) %>% summarise(mean_temp = mean(!is.na(data$mean_temp)),
#                                                                       median_temp = median(!is.na(data$mean_temp)),
#                                                                       max_temp = max(!is.na(data$max_temp)),
#                                                                       min_temp = min(!is.na(data$min_temp)),
#                                                                       total_precip = sum(!is.na(data$total_precip)),
#                                                                       total_rain = sum(!is.na(data$total_rain)),
#                                                                       total_snow = sum(!is.na(data$total_snow)),
#                                                                       spd_max_gust = max(!is.na(spd_max_gust)), .groups = "keep")
