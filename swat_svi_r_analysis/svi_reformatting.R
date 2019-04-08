# reformat svi (from 2010-2014) data script

# ---- 1. set up ----

# load libraries
library(tidyverse)
library(here)

# define paths
project_path <- here::here()
tabular_data_path <- paste0(project_path, "/data/tabular/")

# load pdf
svi_data_raw <- read_csv(paste0(tabular_data_path, "us_svi_2014_albers.txt"), col_names = TRUE, na = c("-999"))
# svi data comes from the astdr website: https://svi.cdc.gov/

# ---- 2 reformat data ----

# select only columns you need
svi_data <- svi_data_raw %>%
  select(fips = FIPS, state_abbrev = ST_ABBR, county_name = COUNTY,
         svi_theme1 = SPL_THEME1, svi_theme1_percentile = RPL_THEME1,
         svi_theme2 = SPL_THEME2, svi_theme2_percentile = RPL_THEME2,
         svi_theme3 = SPL_THEME3, svi_theme3_percentile = RPL_THEME3,
         svi_theme4 = SPL_THEME4, svi_theme4_percentile = RPL_THEME4,
         svi_total = SPL_THEMES, svi_total_percentile = RPL_THEMES) %>%
  # remove -999 vaules (=NA)
  filter(svi_theme1 >= 0 & svi_theme1_percentile >= 0 &
           svi_theme2 >= 0 & svi_theme2_percentile >= 0 &
           svi_theme3 >= 0 & svi_theme3_percentile >= 0 &
           svi_theme4 >= 0 & svi_theme4_percentile >= 0 &
           svi_total >= 0 & svi_total_percentile >= 0)


# ---- 3 export data ----

# export reformatted data
write_csv(svi_data, paste0(tabular_data_path, "us_svi_2014_albers_reformatted.csv"))
