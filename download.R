library(tidycensus)
library(tidyverse)
library(leaflet)
library(sf)

fl_education_data <- get_acs(
  geography = "tract",  # Use "block group" for block group level
  variables = "B15003_022",  # Example: Bachelor's degree or higher
  state = "FL",  # Florida
  year = 2021,  # Specify the year
  survey = "acs5",  # 5-year ACS data
  geometry = TRUE  # Set to TRUE if you want spatial data
)

write_rds(fl_education_data, file = "data.rds")
