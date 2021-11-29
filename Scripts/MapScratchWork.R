library(dplyr)
library(ggplot2)
library(akima) 
library(raster)
library(RColorBrewer)

poverty <- read.csv("C:\\Users\\tyler\\OneDrive - University of Virginia\\Semesters\\FALL 2021\\STS 2500\\Living_Wage__2017_.csv")
povertyCleaned <- poverty%>%
  dplyr::select(PovRate, INTPTLAT, INTPTLON)%>%
  rename(LAT = INTPTLAT, LON = INTPTLON)

la <- map_data("county")%>%
  filter(subregion == "los angeles")

povertyCleaned$PovRate <- cut(povertyCleaned$PovRate, breaks=5)

ggplot() + geom_polygon(data=la, aes(x=long, y=lat, group=group), color="black", fill="lightgray") +
  geom_hex(data=povertyCleaned, aes(x=LON, y=LAT, fill=PovRate), alpha=.5)

ggplot() + geom_polygon(data=la, aes(x=long, y=lat, group=group), color="black", fill="lightgray") +
  geom_hex(data=povertyCleaned, aes(x=LON, y=LAT, fill=PovRate), alpha=.5) + 

bugetDataCleaned <- bugetData%>%rename()


#  stat_density2d(data=povertyCleaned, mapping=aes(x=LON, y=LAT, fill=..level..), alpha=0.3, geom="polygon")

#  inset_raster(r, extent(r)@xmin, extent(r)@xmax, extent(r)@ymin, extent(r)@ymax) +
#  geom_point(data=povertyCleaned, mapping=aes(LON, LAT), alpha=0.2) 

#  stat_contour(data=povertyCleaned,  aes(x= LON, y=LAT, z=PovRate, fill=..level.., alpha=..level..), geom="polygon") +
#  scale_fill_gradient(name = "Value", low = "green", high = "red") + 
#  guides(alpha = "none")

