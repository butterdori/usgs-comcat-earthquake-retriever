# usgs-comcat-earthquake-retriever
Automates bulk retrieval of earthquake data from USGS Earthquake Catalog in accordance with the API https://earthquake.usgs.gov/fdsnws/event/1/#parameters.  
  
Set parameters.  
```
# Parameters: start date, end date, and lat/lon bounds for the Conterminous US
start_date <- "2024-09-20"
end_date <- "2024-09-23"
minlatitude <- 24.6
maxlatitude <- 50
minlongitude <- -125
maxlongitude <- -65
```

Run command.
```
# Fetch all earthquake data within the specified lat/lon bounds
all_earthquake_data <- fetch_all_data(start_date, end_date, minlatitude, maxlatitude, minlongitude, maxlongitude)
```
