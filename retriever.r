# Load necessary libraries
library(httr)
library(readr)
library(dplyr)

# Function to fetch data from USGS API with latitude and longitude bounds
fetch_earthquake_data <- function(starttime, endtime, minlatitude, maxlatitude, minlongitude, maxlongitude, limit = 20000) {
  # Construct the URL with latitude/longitude bounds
  url <- paste0("https://earthquake.usgs.gov/fdsnws/event/1/query?",
                "format=csv&starttime=", starttime, 
                "&endtime=", endtime, 
                "&minlatitude=", minlatitude,
                "&maxlatitude=", maxlatitude,
                "&minlongitude=", minlongitude,
                "&maxlongitude=", maxlongitude,
                "&limit=", limit)
  
  # Fetch the data
  response <- GET(url)
  
  # Check if the request was successful
  if (status_code(response) == 200) {
    # Read the content as CSV
    data <- read_csv(content(response, "text"))
    
    # Return the data
    return(data)
  } else {
    # Handle any errors
    stop(paste("Failed to download data. Status code:", status_code(response)))
  }
}

# Function to loop and fetch data until start date is reached with lat/lon bounds
fetch_all_data <- function(start_date, end_date, minlatitude, maxlatitude, minlongitude, maxlongitude) {
  all_data <- tibble()  # Initialize an empty tibble to store all data
  current_end <- end_date  # Start with the initial end date
  
  repeat {
    # Fetch the data for the current date range
    data <- fetch_earthquake_data(starttime = start_date, 
                                  endtime = current_end, 
                                  minlatitude = minlatitude,
                                  maxlatitude = maxlatitude,
                                  minlongitude = minlongitude,
                                  maxlongitude = maxlongitude)
    
    # Append the fetched data to the existing data
    all_data <- bind_rows(all_data, data)
    
    # If we have less than 20,000 rows, it means we have all the data for this range
    if (nrow(data) < 20000) {
      break
    }
    
    # Find the earliest time from the returned data to use as the next end time
    earliest_time <- min(as.POSIXct(data$time, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC"))
    
    # Update the current_end to one second before the earliest time in the current batch
    current_end <- format(earliest_time - 1, "%Y-%m-%dT%H:%M:%S")
    
    # If the updated current_end is earlier than the start_date, stop the loop
    if (as.POSIXct(current_end) < as.POSIXct(start_date)) {
      break
    }
  }
  
  return(all_data)
}

# Parameters: start date, end date, and lat/lon bounds for the Conterminous US
start_date <- "2024-09-20"
end_date <- "2024-09-23"
minlatitude <- 24.6
maxlatitude <- 50
minlongitude <- -125
maxlongitude <- -65

# Fetch all earthquake data within the specified lat/lon bounds
all_earthquake_data <- fetch_all_data(start_date, end_date, minlatitude, maxlatitude, minlongitude, maxlongitude)

# View the data
head(all_earthquake_data)

# Optionally, save the data to a CSV file
write_csv(all_earthquake_data, "earthquake_data.csv")
