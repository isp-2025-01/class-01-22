library(tidycensus)
library(tidyverse)
library(sf)

# Define the variables you want to extract
education_variables <- c(
  "B15003_022",  # Bachelor's degree
  "B15003_023",  # Master's degree
  "B15003_024",  # Professional school degree
  "B15003_025",  # Doctorate degree
  "B01003_001"   # Total population (for percentage calculations)
)

# Fetch the data
fl_education_data <- get_acs(
  geography = "tract",  # Use "block group" for block group level
  variables = education_variables,  # Include all variables
  state = "FL",  # Florida
  year = 2023,  # Specify the year
  survey = "acs5",  # 5-year ACS data
  geometry = TRUE  # Set to TRUE if you want spatial data
)

# Reshape the data to wide format for easier calculations
fl_education_wide <- fl_education_data %>%
  select(GEOID, NAME, variable, estimate) %>%
  tidyr::pivot_wider(names_from = variable, values_from = estimate)

# Calculate percentages for each education level
x <- fl_education_wide %>%
  mutate(
    pct_bachelors = (B15003_022 / B01003_001) * 100,
    pct_masters = (B15003_023 / B01003_001) * 100,
    pct_professional = (B15003_024 / B01003_001) * 100,
    pct_doctorate = (B15003_025 / B01003_001) * 100
  )

# Remove rows with empty geometries
x <- x[!st_is_empty(x$geometry), ]

# Transform to WGS84 (EPSG:4326) for mapping
x <- st_transform(x, crs = 4326)

# Calculate centroids for labeling (optional)
centroids <- st_centroid(x$geometry)
x$lon <- st_coordinates(centroids)[, 1]
x$lat <- st_coordinates(centroids)[, 2]


write_rds(x, file = "fl_data.rds")
