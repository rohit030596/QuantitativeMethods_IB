install.packages("weathercan", repos = "https://ropensci.r-universe.dev", dependencies = TRUE)
install.packages("tidyverse", dependencies = TRUE)
library("weathercan")
library("tidyverse")

stations <- stations() %>%
  filter(end > 2019,
         prov %in% c("QC", "ON", "BC"),
         interval == "day")

data <- weather_dl(station_ids = as.vector(stations$station_id), start = "2009-01-01", end = "2019-12-31", interval = "day")


a <- stations %>% group_by(prov) %>% summarise(count = n())

