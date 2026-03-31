# Using R
# Option 1: tidytuesdayR R package 
install.packages("tidytuesdayR")

tuesdata <- tidytuesdayR::tt_load('2026-03-31')
## OR
tuesdata <- tidytuesdayR::tt_load(2026, week = 13)

ocean_temperature <- tuesdata$ocean_temperature
ocean_temperature_deployments <- tuesdata$ocean_temperature_deployments

# Option 2: Read directly from GitHub

ocean_temperature <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-03-31/ocean_temperature.csv')
ocean_temperature_deployments <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-03-31/ocean_temperature_deployments.csv')