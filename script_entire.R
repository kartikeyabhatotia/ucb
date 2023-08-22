#install and load all the packages needed
x <- c("ggmap", "rgdal", "rgeos", "maptools", "dplyr", "tidyr", "tmap", "maptools", "leaflet", "sf")
# install.packages(x) # warning: uncommenting this may take a number of minutes
lapply(x, library, character.only = TRUE) # load the required packages

#Sometimes, R will still find a lot of packages missing
#So install them separately!
#install.packages("rgeos")
#install.packages("maptools")
#install.packages("leaflet")
#library(maptools)
#library(rgeos)
#library(rgdal)
#library(sf)
#library(dplyr)
#library(leaflet)



#Exercise 1: let's plot the map of Bolivia first!
bol <- readOGR(dsn = "bol_admbnda_adm0_gov_itos_2020514.shp")
head(bol@data, n =10)
plot(bol)

#Exercise 2: plotting the map of Bolivian departments
bol_dept <- readOGR(dsn = "bol_admbnda_adm1_gov_2020514.shp")
head(bol_dept@data, n =10)
plot(bol_dept)

#Exercise 3: where are we? let's colour that!
plot(bol_dept, col = "lightgrey")
plot(bol_dept[bol_dept$ADM1_ES == "La Paz", ], col = "turquoise", add = TRUE)

#But La Paz is so big, what if we want to do mark the city of La Paz?
#let's try a different map - the province map!
bol_province <- readOGR(dsn = "bol_admbnda_adm2_gov_2020514.shp")
head(bol_province@data, n =10)
plot(bol_province)

#now let's mark La Paz within this map?
plot(bol_province, col = "lightgrey")
plot(bol_province[bol_province$ADM1_ES == "La Paz", ], col = "turquoise", add = TRUE)

#ah, so small! now let's do something fun. I have been in Bolivia the past three weeks
#in this time, I was able to visit Coroico, Uyuni, La Paz, Copacabana
#and my layover will be in Santa Cruz, let's mark all of these places


#But wait! I don't know how to spell all of these, so let's print the values

unique_provinces <- unique(bol_province$ADM2_ES)
print(unique_provinces)

#I had to do some googling, La Paz is in Pedro Domingo Murillo province
#Antonio Quijarro (where Uyuni is)
#Nor Yungas where Coroico is, Manco Kapac where Copacabana is
#Andrés Ibáñez where Santa Cruz is 

provinces_visited <- c("Pedro Domingo Murillo", "Antonio Quijarro", "Nor Yungas", "Manco Kapac", "Andrés Ibáñez")

plot(bol_province, col = "lightgrey")
plot(bol_province[bol_province$ADM2_ES %in% provinces_visited, ], col = "turquoise", add = TRUE)

#now let's add a title

title(main = "Places in Bolivia that I Visited", sub = "Highlighted Provinces")

#okay, we played enough with the shapefile that we had. What if I had 
#an external dataset? let's say altitude of each departments in Bolivia
#how do I map it?

altitude_data <- read.csv("altitude_data.csv")
head(altitude_data)


bol_dept_df <- as.data.frame(bol_dept)

# Merge the data
merged_data_df <- merge(bol_dept_df, altitude_data, by.x = "ADM1_ES", by.y = "ADM1_ES", all.x = TRUE)

merged_data <- SpatialPolygonsDataFrame(
  bol_dept,
  data = merged_data_df
)


library(leaflet)
color_palette <- colorNumeric(
  palette = "viridis",
  domain = merged_data$avg_elevation
)

m <- leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(
    data = merged_data,
    fillColor = ~color_palette(avg_elevation),
    fillOpacity = 0.7,
    color = "black",
    weight = 1,
    highlightOptions = highlightOptions(
      weight = 2,
      color = "white",
      bringToFront = TRUE
    ),
    label = ~paste(
      "Region: ", ADM1_ES,
      "<br>Avg Elevation: ", avg_elevation
    )
  ) %>%
  addLegend(
    pal = color_palette,
    values = merged_data$avg_elevation,
    title = "Average Elevation",
    position = "bottomright"
  )

# Print the map
m
