library(dplyr)
library(ggplot2)
library(tidyverse)
library(viridis)

# Import datasets
crimeData <- read.csv("C:\\Users\\tyler\\OneDrive - University of Virginia\\Semesters\\FALL 2021\\STS 2500\\Crime_Data_from_2010_to_2019.csv")
povertyData <- read.csv("C:\\Users\\tyler\\OneDrive - University of Virginia\\Semesters\\FALL 2021\\STS 2500\\Living_Wage__2017_.csv")

### Cleaning Datasets ###

# Removing MISC Crime beacuase MISC is undefined
crimeData <- crimeData %>% filter(Crm.Cd != 946)

# Cleaning rows with random numbers
povertyData <- povertyData %>% filter(STATEFP == 6)

# Normalizes crime severity on a 0-1 scale
crimeDataCleaned <- crimeData%>%filter(grepl("2017", DATE.OCC))%>%dplyr::select(Crm.Cd, LAT, LON)%>%mutate(Severity = 1-Crm.Cd/956)

# Normalizes Poverty Rate on a 0-1 scale and removes unnecessary rows
povertyDataCleaned <- povertyData %>%dplyr::select(PovRate, INTPTLAT, INTPTLON) %>% 
  rename(LAT = INTPTLAT, LON = INTPTLON) %>%
  mutate(PovRate = PovRate/100)
  
# Rounding latitude and longitude coordinates
crimeDataCleaned$LAT <- trunc(crimeDataCleaned$LAT * 10^4)/10^4
povertyDataCleaned$LAT <- trunc(povertyDataCleaned$LAT * 10^4) / 10^4
crimeDataCleaned$LON <- trunc(crimeDataCleaned$LON * 10^4)/10^4
povertyDataCleaned$LON <- trunc(povertyDataCleaned$LON * 10^4) / 10^4

# Removing strange outliers for LAC
crimeDataCleaned <- crimeDataCleaned %>% filter(LAT > 33.6)
povertyDataCleaned <- povertyDataCleaned %>% filter(LAT > 33.6)

### GRAPHING ###

# Creates Map of LA county
la <- map_data("county")%>%
  filter(subregion == "los angeles")

# Plot of crime frequency in LA
ggplot(crimeDataCleaned, aes(LON, LAT)) +
  geom_polygon(data=la, aes(x=long, y=lat, group=group), color="black", fill="lightgray") +
  coord_map(xlim = c(-118.75, -118.00),ylim = c(33.600, 34.5)) +
  geom_bin2d(bins = 70) +
  scale_fill_viridis(option = "viridis") + theme_bw() +
  labs(fill = "Number of Crimes", title = "Amount of Crimes in Los Angeles by Location in 2017", x = "Longitude", y = "Latitude")

# Plot of Severity of Crimes in LA
ggplot() + geom_polygon(data=la, aes(x=long, y=lat, group=group), color="black", fill="lightgray") +
  coord_map(xlim = c(-118.75, -118.00),ylim = c(33.600, 34.5)) +
  stat_summary_2d(data = crimeDataCleaned, aes(LON, LAT, z = Severity), bins = 70) +
  scale_fill_viridis(option = "viridis") + theme_bw() +
  labs(title = "Severity of Crimes in Los Angeles by Location in 2017", x = "Longitude", y = "Latitude", fill = "Crime Severity")

# Plot of Poverty Rate of LA
ggplot() + geom_polygon(data=la, aes(x=long, y=lat, group=group), color="black", fill="lightgray") + 
  coord_map(xlim = c(-118.75, -118.00),ylim = c(33.600, 34.5)) +
  stat_summary_2d(data = povertyDataCleaned, aes(LON, LAT, z = PovRate), bins = 70) +
  scale_fill_viridis(option = "viridis") + theme_bw() +
  labs(title = "Poverty Rate in Los Angeles by Location in 2017", x = "Longitude", y = "Latitude", fill = "Poverty Rate")
