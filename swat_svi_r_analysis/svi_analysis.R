# yadkin svi risk analysis script

# ---- 1. set up -----

# load libraries
library(tidyverse)
library(ggridges)
library(sf)
library(here)
library(grid)

# define paths
project_path <- here::here()
functions_path <- paste0(project_path, "/functions/")
gis_data_path <- paste0(project_path, "/data/spatial/")
tabular_data_path <- paste0(project_path, "/data/tabular/")
figure_path <- paste0(project_path, "/figures/")

# load home-made functions 
source(paste0(functions_path, "multiplot.R")) # for creating plots with multiple figures

# svi (2010-2014) scaling factors (from python analysis)
svibd_scaling_raw <- read_csv(paste0(tabular_data_path, "svibd_2014_scaling_allsubs.csv"), col_names = TRUE)

# svi 2010-2014 data (from results)
us_svi_data <- read_csv(paste0(tabular_data_path, "us_svi_2014_albers_reformatted.csv"), col_names = TRUE)

# gis data
yadkin_sub_shp_raw <- read_sf(paste0(gis_data_path, "yadkin_subs_utm17N.shp"), quiet = TRUE)
yadkin_tract_shp_raw<- read_sf(paste0(gis_data_path, "yadkin_svi2014_utm17N.shp"), quiet = TRUE)
yadkin_unclip_tract_shp_raw <- read_sf(paste0(gis_data_path, "yadkin_counties_svi2014_utm17N.shp"), quiet = TRUE)
yadkin_river_shp <- read_sf(paste0(gis_data_path, "yadkin_majortribs_utm17N.shp"), quiet = TRUE)
# used Albers Equal Area projection for calcs in ArcGIS but UTM 17N here because
# sf() was not recognizing Albers


# ---- 2. reformat data -----

# remove X1 column in scaling data
svidb_scaling_data <- svibd_scaling_raw %>% 
  select(-X1)

# make sure fips columns are same name and are as.numeric()
yadkin_tract_shp <- yadkin_tract_shp_raw %>% 
  mutate(fips = as.numeric(FIPS)) %>% 
  select(-FIPS)

# census tracts in yadkin counties (not clipped to watershed bounds)
yadkin_unclip_tract_shp <- yadkin_unclip_tract_shp_raw %>%
  mutate(fips = as.numeric(FIPS)) %>% 
  select(-FIPS)

# copy census tract data to new variable
yadkin_census_tract_data<- yadkin_tract_shp %>% 
  select(fips, E_TOTPOP:E_DAYPOP)  %>% # select only columns you need 
  st_set_geometry(NULL) # set geometry as null to get df

# change subbasin id column to match other files
yadkin_sub_shp <- yadkin_sub_shp_raw %>% 
  mutate(SUB = Subbasin) %>% 
  select(-Subbasin)

# select atsdr data for yadkin
yadkin_svi_data <- left_join(svidb_scaling_data, us_svi_data, by = "fips")


# ---- 3.1 combine us, nc, and yadkin tract svi data for histogram ----

# find unique fips id's for yadkin
yadkin_unique_fips = svidb_scaling_data %>% 
  select(fips) %>% distinct()

# find unique fips id's for nc
nc_unique_fips = us_svi_data %>% 
  filter(state_abbrev == "NC") %>% 
  select(fips) %>% distinct()

# select svi data for yadkin using unique fips id's
yadkin_svi_hist = us_svi_data %>% 
  select(fips, svi_total) %>% 
  right_join(yadkin_unique_fips, by = "fips") %>% 
  mutate(dataset = "UYPD")

# select svi data for nc using unique fips id's
nc_svi_hist = us_svi_data %>% select(fips, svi_total) %>% 
  right_join(nc_unique_fips, by = "fips") %>% 
  mutate(dataset = "NC")

# select svi data for us using unique fips id's
us_svi_hist = us_svi_data %>% select(fips, svi_total) %>% 
  mutate(dataset = "US")

# calculate mean svi for us, nc, and yadkin
mean_us_svi <- mean(us_svi_hist$svi_total)
sd_us_svi<- sd(us_svi_hist$svi_total)
mean_nc_svi <- mean(nc_svi_hist$svi_total)
sd_nc_svi <- sd(nc_svi_hist$svi_total)
mean_yadkin_svi <- mean(yadkin_svi_hist$svi_total)
sd_yadkin_svi <- sd(yadkin_svi_hist$svi_total)

# number of census tracts in nc that are vulnerable (>= 2 standard deviations from the national mean svi)
length(unique(nc_svi_hist$fips[nc_svi_hist$svi_total >= mean_us_svi + 2 * sd_us_svi]))
# 36
 
# bind yadkin, nc, and us together
svi_hist = bind_rows(yadkin_svi_hist, nc_svi_hist, us_svi_hist)

# ---- 3.2 census tract svi calculations for paper ----

# mean + sd for us
mean_us_svi + sd_us_svi # 9.557 = 9.6

# mean + 2 * sd for us
mean_us_svi + 2 * sd_us_svi # 11.7839 = 11.8

# min, mean, max, sd of census tract svi for us
min(us_svi_data$svi_total) # 0.0874 = 0.09
mean_us_svi # 7.330 = 7.3
max(us_svi_data$svi_total) # 13.741 = 13.7
sd_us_svi # 2.2268 = 2.2

# min, mean, max, sd of census tract svi for yadkin
min(yadkin_svi_data$svi_total) # 2.1007 = 2.1
mean_yadkin_svi # 7.7611 = 7.8
max(yadkin_svi_data$svi_total) # 12.7003 = 12.7
sd_yadkin_svi # 2.1297 = 2.1


# ---- 3.3 plot plot us, nc, yadkin tract svi data as density plots (figure s10) ----

# set factors
svi_hist$dataset <- factor(svi_hist$dataset, levels = c("UYPD", "NC", "US"))

# plot
cairo_pdf(paste0(figure_path, "figure_s10.pdf"), width = 10, height = 10)
ggplot(svi_hist, aes(x = svi_total, y = dataset, fill = dataset)) +
  geom_density_ridges2(scale = 0.5, alpha=0.5) +
  geom_vline(xintercept = 7.33, linetype = "longdash") +
  geom_vline(xintercept = 9.6) +
  geom_vline(xintercept = 5.1) +
  xlab("Census Tract SVI") +
  ylab("Density") +
  xlim(0,15) +
  scale_fill_manual(values=c("white", "grey75", "grey30")) +
  theme_bw() +
  theme(axis.text = element_text(size = 16),
        axis.title = element_text(size = 16),
        text = element_text(size = 16),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        legend.position = "none")
dev.off()


# ---- 3.4 density plot KS tests ----

# KS tests (yadkin and us)
ks.test(us_svi_hist$svi_total, yadkin_svi_hist$svi_total, alternative = "two.sided") # p < 0.05
ks.test(us_svi_hist$svi_total, yadkin_svi_hist$svi_total, alternative = "less") # p = 0.9987
ks.test(us_svi_hist$svi_total, yadkin_svi_hist$svi_total, alternative = "greater") # p < 0.05
# shifted to the right

# KS tests (us and nc)
ks.test(us_svi_hist$svi_total, nc_svi_hist$svi_total, alternative = "two.sided") # p < 0.05
ks.test(us_svi_hist$svi_total, nc_svi_hist$svi_total, alternative = "less") # p = 0.9589
ks.test(us_svi_hist$svi_total, nc_svi_hist$svi_total, alternative = "greater") # p < 0.05
# shifted to the right

# KS test (yadkin and nc)
ks.test(yadkin_svi_hist$svi_total, nc_svi_hist$svi_total, alternative = "two.sided") # p = 0.58


# ---- 3.5 plot yadkin total svi by tract on map (figure s9) ----

# total svi by tract
cairo_pdf(paste0(figure_path, "figure_s9.pdf"), width = 10, height = 10, pointsize = 18)
ggplot(yadkin_tract_shp, aes(fill = SPL_THEMES)) +
  geom_sf(color = "black") +
  coord_sf(crs = st_crs(102003)) + # yadkin_tract_shp is base utm 17N so convert to Albers for CONUS
  scale_fill_gradient2("Total svi", high = "darkred", low = "white", limits = c(0, 15)) +
  theme_bw()
dev.off()


# ---- 4.1 scale svi data to subbasin ----

# scale to subbasin
# total svi
yadkin_svi_total_sub_data <- yadkin_svi_data %>%
  select(SUB, fips, tract_perc, sub_perc, svi_total) %>%
  mutate(wt_svi_total = round(svi_total * sub_perc, 3)) %>%
  group_by(SUB) %>% 
  summarize(area_wt_svi = sum(wt_svi_total),
            median_svi = median(svi_total),
            min_svi = min(svi_total),
            max_svi = max(svi_total),
            range_svi = max_svi - min_svi)

# join with gis data
yadkin_sub_shp_svi_total <- left_join(yadkin_sub_shp, yadkin_svi_total_sub_data, by ="SUB")


# ---- 4.2 subbasin svi calculations for paper ----

# min, mean, max, sd subbasin svi for yadkin
min(yadkin_svi_total_sub_data$area_wt_svi) # 6.528 = 6.5
mean(yadkin_svi_total_sub_data$area_wt_svi) # 7.944357 = 7.9
max(yadkin_svi_total_sub_data$area_wt_svi) # 9.87 = 9.9
sd(yadkin_svi_total_sub_data$area_wt_svi) # 0.8866 = 0.9


# ---- 4.2 plot subbasin scaled svi data (figure 5) ----

# make a list to hold plots
figure_5 = list()

# total svi by sub
figure_5[[1]] = ggplot(yadkin_sub_shp_svi_total, aes(fill = area_wt_svi)) +
  geom_sf(color = "black") +
  coord_sf(crs = st_crs(102003)) + # yadkin_sub_shp_svi_total is base utm 17N so convert to Albers for CONUS
  scale_fill_gradient2("Total SVI", high = "darkred", low = "white", midpoint = 6, limits = c(5, 10)) +
  theme_bw()

figure_5[[2]] = ggplot(yadkin_svi_data, aes(x = as.factor(SUB), y = svi_total)) +
  geom_boxplot() +
  geom_point(size = 1, alpha = 0.25) +
  ylim(0, 15) +
  xlab("Subbains ID") +
  ylab("Census Tract SVI") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(), 
        text = element_text(size = 18))

# plot tract and subbasin scaled together
cairo_pdf(paste0(figure_path, "figure_5.pdf"), width = 20, height = 10, pointsize = 18)
multiplot(plotlist = figure_5, cols = 2)
dev.off()


# ---- 5.1 import % change in NUMBER OF FLOWS at/above a given return period data ----

# set working directory and import data from hiflow_analysis.R script
hiflow_10yr_change_data = read_csv(paste0(tabular_data_path, "hiflow_10yr_change_calcs.csv"), col_names = TRUE)


# ---- 5.2 reclass data for plotting ----

# 10yr high flow data (hydrology aka hydro only = swat only)
hiflow_10yr_reclass_hydro <- hiflow_10yr_change_data %>%
  select(SUB, perc_change_per_yr, dataset) %>%
  left_join(yadkin_svi_total_sub_data, by = "SUB") %>% # join area weighted svi
  mutate(impact_class_hydro_num = ifelse(perc_change_per_yr <= 25, 1, 
                                         ifelse((perc_change_per_yr > 25) & (perc_change_per_yr <= 50), 2, 3))) %>%
  mutate(impact_class_hydro_char = case_when(impact_class_hydro_num == 1 ~ "low", 
                                             impact_class_hydro_num == 2 ~ "medium",
                                             impact_class_hydro_num == 3 ~ "high"))

# select high risk (hydro only)
hiflow_10yr_reclass_hydro_hi <- hiflow_10yr_reclass_hydro %>%
  filter(impact_class_hydro_char == "high")

# 10yr high flow data (demographics aka demo only = svi only)
hiflow_10yr_reclass_demo <- hiflow_10yr_change_data %>%
  select(SUB, perc_change_per_yr, dataset) %>%
  left_join(yadkin_svi_total_sub_data, by = "SUB") %>% # join area weighted svi
  mutate(impact_class_demo_sub = ifelse(area_wt_svi <= (mean_us_svi + sd_us_svi), 1, 
                                        ifelse((area_wt_svi > (mean_us_svi + sd_us_svi)) & (area_wt_svi <= (mean_us_svi + 2 * sd_us_svi)), 2, 3))) %>% # subbasin scale
  mutate(impact_class_demo_tract = ifelse(max_svi <= (mean_us_svi + sd_us_svi), 1, 
                                          ifelse((max_svi > (mean_us_svi + sd_us_svi)) & (max_svi <= (mean_us_svi + 2 * sd_us_svi)), 2, 3))) %>% # tract scale
  mutate(impact_class_demo_num_temp = impact_class_demo_sub + impact_class_demo_tract) %>%
  mutate(impact_class_demo_num = case_when(impact_class_demo_num_temp == 2 ~ 1,
                                           impact_class_demo_num_temp == 3 ~ 2, 
                                           impact_class_demo_num_temp == 4 ~ 3)) %>%# shift so range is from 1 to 3
  mutate(impact_class_demo_char = case_when(impact_class_demo_num == 1 ~ "low", 
                                            impact_class_demo_num == 2 ~ "medium",
                                            impact_class_demo_num == 3 ~ "high")) %>%
  select(SUB:range_svi, impact_class_demo_num, impact_class_demo_char)

# select high risk (demo only)
hiflow_10yr_reclass_demo_hi <- hiflow_10yr_reclass_demo %>%
  filter(impact_class_demo_char == "high")

# 10yr hiflow data (hydrology + demographics aka hydro + demo = swat + svi)
hiflow_10yr_reclass_hydrodemo <- hiflow_10yr_change_data %>%
  select(SUB, perc_change_per_yr, dataset) %>%
  left_join(yadkin_svi_total_sub_data, by = "SUB") %>% # join area weighted svi
  mutate(impact_class_hydro_num = ifelse(perc_change_per_yr <= 25, 1, 
                                         ifelse((perc_change_per_yr > 25) & (perc_change_per_yr <= 50), 2, 3))) %>%
  mutate(impact_class_demo_sub_num = ifelse(area_wt_svi <= (mean_us_svi + sd_us_svi), 1, 
                                            ifelse((area_wt_svi > (mean_us_svi + sd_us_svi)) & (area_wt_svi <= (mean_us_svi + 2 * sd_us_svi)), 2, 3))) %>%
  mutate(impact_class_demo_tract_num = ifelse(max_svi <= mean_us_svi + sd_us_svi, 1, 
                                              ifelse((max_svi > (mean_us_svi + sd_us_svi)) & (max_svi <= (mean_us_svi + 2 * sd_us_svi)), 2, 3))) %>%
  mutate(impact_class_demo_num_temp = impact_class_demo_sub_num + impact_class_demo_tract_num) %>%
  mutate(impact_class_demo_num = case_when(impact_class_demo_num_temp == 2 ~ 1,
                                           impact_class_demo_num_temp == 3 ~ 2, 
                                           impact_class_demo_num_temp == 4 ~ 3)) %>% # shift so range is from 1 to 3
  select(SUB:range_svi, impact_class_hydro_num, impact_class_demo_num) %>%
  mutate(impact_class_sum_temp = impact_class_hydro_num + impact_class_demo_num) %>%
  mutate(impact_class_sum_temp_fix_hydro_num = ifelse(perc_change_per_yr < 0, 3, impact_class_sum_temp)) %>% # for PC values below zero
  mutate(impact_class_sum_temp_fix_demo_num = ifelse(max_svi <= mean_us_svi, 3, impact_class_sum_temp_fix_hydro_num)) %>% # for svi values below mean
  mutate(impact_class_sum_num = case_when(impact_class_sum_temp_fix_demo_num == 2 ~ 1,
                                          impact_class_sum_temp_fix_demo_num == 3 ~ 2,
                                          impact_class_sum_temp_fix_demo_num == 4 ~ 2,
                                          impact_class_sum_temp_fix_demo_num == 5 ~ 3,
                                          impact_class_sum_temp_fix_demo_num == 6 ~ 3)) %>% # shift so range is from 1 to 3
  mutate(impact_class_sum_char = case_when(impact_class_sum_num == 1 ~ "low", 
                                           impact_class_sum_num == 2 ~ "medium",
                                           impact_class_sum_num == 3 ~ "high"))

# select high risk (hydro + demo)
hiflow_10yr_reclass_hydrodemo_hi <- hiflow_10yr_reclass_hydrodemo %>%
  filter(impact_class_sum_char == "high")

# define factor levels
hiflow_10yr_reclass_hydro$impact_class_hydro_char <- factor(hiflow_10yr_reclass_hydro$impact_class_hydro_char, levels = c("low", "medium", "high"))
hiflow_10yr_reclass_hydro$dataset <- factor(hiflow_10yr_reclass_hydro$dataset, levels = c("miroc8_5", "csiro8_5", "csiro4_5", "hadley4_5"))
hiflow_10yr_reclass_demo$impact_class_demo_char <- factor(hiflow_10yr_reclass_demo$impact_class_demo_char, levels = c("low", "medium", "high"))
hiflow_10yr_reclass_demo$dataset <- factor(hiflow_10yr_reclass_demo$dataset, levels = c("miroc8_5", "csiro8_5", "csiro4_5", "hadley4_5"))
hiflow_10yr_reclass_hydrodemo$impact_class_sum_char <- factor(hiflow_10yr_reclass_hydrodemo$impact_class_sum_char, levels = c("low", "medium", "high"))
hiflow_10yr_reclass_hydrodemo$dataset <- factor(hiflow_10yr_reclass_hydrodemo$dataset, levels = c("miroc8_5", "csiro8_5", "csiro4_5", "hadley4_5"))


# ---- 5.3 plot on risk matrix with error bars (figure s13) ----

# make a list to hold plots
figure_s13 <- list()

# plot 10yr flow data
figure_s13[[1]] <- ggplot(data = na.omit(hiflow_10yr_reclass_hydrodemo),
                         mapping = aes(x = perc_change_per_yr, y = area_wt_svi, color = impact_class_sum_char, shape = dataset)) +
  geom_errorbar(aes(ymax = max_svi, ymin = min_svi)) +
  geom_point(size = 5, alpha = 0.50) +
  geom_vline(xintercept = 0) +
  geom_vline(xintercept = 50, linetype = "dashed") +
  geom_vline(xintercept = 25, linetype = "dashed") +
  geom_hline(yintercept = mean_us_svi) +
  geom_hline(yintercept = mean_us_svi + sd_us_svi, linetype = "dashed") +
  geom_hline(yintercept = mean_us_svi + 2 * sd_us_svi, linetype = "dashed") +
  labs(x = "PC10", y = "Subbasin SVI",
       color = "Class", shape = "Dataset") +
  xlim(-5, 150) +
  ylim(0, 15) +
  theme_bw() +
  scale_shape_manual(values = c(15, 16, 17, 18)) +
  scale_color_manual(values = c("gold", "orange", "red")) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        text = element_text(size = 18))


# ---- 5.4 plot risk on map (figures s3, s5, and s6) ----

# add to shp file
yadkin_sub_shp_hiflow_10yr_hydro <- left_join(yadkin_sub_shp, hiflow_10yr_reclass_hydro, by = "SUB")
yadkin_sub_shp_hiflow_10yr_demo <- left_join(yadkin_sub_shp, hiflow_10yr_reclass_demo, by = "SUB")
yadkin_sub_shp_hiflow_10yr_hydrodemo <- left_join(yadkin_sub_shp, hiflow_10yr_reclass_hydrodemo, by = "SUB")

# define factor levels
yadkin_sub_shp_hiflow_10yr_hydro$impact_class_hydro_char <- factor(yadkin_sub_shp_hiflow_10yr_hydro$impact_class_hydro_char, levels = c("low", "medium", "high"))
yadkin_sub_shp_hiflow_10yr_hydro$dataset <- factor(yadkin_sub_shp_hiflow_10yr_hydro$dataset, levels = c("miroc8_5", "csiro8_5", "csiro4_5", "hadley4_5"))
yadkin_sub_shp_hiflow_10yr_demo$impact_class_demo_char <- factor(yadkin_sub_shp_hiflow_10yr_demo$impact_class_demo_char, levels = c("low", "medium", "high"))
yadkin_sub_shp_hiflow_10yr_demo$dataset <- factor(yadkin_sub_shp_hiflow_10yr_demo$dataset, levels = c("miroc8_5", "csiro8_5", "csiro4_5", "hadley4_5"))
yadkin_sub_shp_hiflow_10yr_hydrodemo$impact_class_sum_char <- factor(yadkin_sub_shp_hiflow_10yr_hydrodemo$impact_class_sum_char, levels = c("low", "medium", "high"))
yadkin_sub_shp_hiflow_10yr_hydrodemo$dataset <- factor(yadkin_sub_shp_hiflow_10yr_hydrodemo$dataset, levels = c("miroc8_5", "csiro8_5", "csiro4_5", "hadley4_5"))

# plot map of hydro risk results (swat only)
cairo_pdf(paste0(figure_path, "figure_s3.pdf"), width = 11, height = 8.5, pointsize = 18)
ggplot(yadkin_sub_shp_hiflow_10yr_hydro, aes(fill = impact_class_hydro_char)) +
  facet_wrap(~dataset) +
  geom_sf() +
  coord_sf(crs = st_crs(102003)) + # yadkin_sub_shp_hiflow_outlier_hydro is base utm 17N so convert to Albers for CONUS
  scale_fill_manual(values = c("gold", "orange", "red"), na.value = "grey75") +
  theme_bw()
dev.off()

# plot map of demo risk results (svi only)
cairo_pdf(paste0(figure_path, "figure_s5.pdf"), width = 11, height = 8.5, pointsize = 18)
ggplot(yadkin_sub_shp_hiflow_10yr_demo, aes(fill = impact_class_demo_char)) +
  geom_sf() +
  coord_sf(crs = st_crs(102003)) + # yadkin_sub_shp_hiflow_10yr_demo is base utm 17N so convert to Albers for CONUS
  scale_fill_manual(values = c("gold", "orange", "red"), na.value = "grey75") +
  theme_bw()
dev.off()

# plot map of hydro + demo risk results (swat + svi)
cairo_pdf(paste0(figure_path, "figure_s6.pdf"), width = 11, height = 8.5, pointsize = 18)
ggplot(yadkin_sub_shp_hiflow_10yr_hydrodemo, aes(fill = impact_class_sum_char)) +
  facet_wrap(~dataset) +
  geom_sf() +
  coord_sf(crs = st_crs(102003)) + # yadkin_sub_shp_hiflow_outlier_hydrodemo is base utm 17N so convert to Albers for CONUS
  scale_fill_manual(values = c("gold", "orange", "red"), na.value = "grey75") +
  theme_bw()
dev.off()


# ---- 5.5 select subbasins for tables s3 - s5 ----

# table s3 data from hydro results (swat only)
hiflow_10yr_reclass_hydro_hi_sel <- hiflow_10yr_reclass_hydro_hi %>%
  select(SUB, dataset, perc_change_per_yr, area_wt_svi, max_svi)
View(hiflow_10yr_reclass_hydro_hi_sel)

# table s4 data from demo results (svi only)
hiflow_10yr_reclass_demo_hi_sel <- hiflow_10yr_reclass_demo_hi %>%
  select(SUB, dataset, area_wt_svi, max_svi)
View(hiflow_10yr_reclass_demo_hi_sel)

# table s5 data from demo results (swat + svi)
hiflow_10yr_reclass_hydrodemo_hi_sel <- hiflow_10yr_reclass_hydrodemo_hi %>%
  select(SUB, dataset, perc_change_per_yr, area_wt_svi, max_svi)
View(hiflow_10yr_reclass_hydrodemo_hi_sel)


# ---- 6.1 import % change in NUMBER OF OUTLIER FLOWS (high flows) data ----

# set working directory and import data from hiflow_analysis.R script
hiflow_outlier_change_data <- read_csv(paste0(tabular_data_path, "hiflow_outlier_change_calcs.csv"), col_names = TRUE)


# ---- 6.2 reclass hydrology and svi data for plotting ----

# high outlier flow data (hydrology aka hydro only = swat only)
hiflow_outlier_reclass_hydro <- hiflow_outlier_change_data %>%
  select(SUB, minor_outlier_perc_change_per_yr, dataset) %>%
  left_join(yadkin_svi_total_sub_data, by = "SUB") %>% # join area weighted svi
  mutate(impact_class_hydro_num = ifelse(minor_outlier_perc_change_per_yr <= 25, 1, 
                                         ifelse((minor_outlier_perc_change_per_yr > 25) & (minor_outlier_perc_change_per_yr <= 50), 2, 3))) %>%
  mutate(impact_class_hydro_char = case_when(impact_class_hydro_num == 1 ~ "low",
                                             impact_class_hydro_num == 2 ~ "medium",
                                             impact_class_hydro_num == 3 ~ "high"))

# select high risk (hydro only)
hiflow_outlier_reclass_hydro_hi <- hiflow_outlier_reclass_hydro %>%
  filter(impact_class_hydro_char == "high")

# high outlier flow data (demographics only = svi only)
hiflow_outlier_reclass_demo <- hiflow_outlier_change_data %>%
  select(SUB, minor_outlier_perc_change_per_yr, dataset) %>%
  left_join(yadkin_svi_total_sub_data, by = "SUB") %>% # join area weighted svi
  mutate(impact_class_demo_sub = ifelse(area_wt_svi <= (mean_us_svi + sd_us_svi), 1, 
                                        ifelse((area_wt_svi > (mean_us_svi + sd_us_svi)) & (area_wt_svi <= (mean_us_svi + 2 * sd_us_svi)), 2, 3))) %>%
  mutate(impact_class_demo_tract = ifelse(max_svi <= (mean_us_svi + sd_us_svi), 1, 
                                          ifelse((max_svi > (mean_us_svi + sd_us_svi)) & (max_svi <= (mean_us_svi + 2 * sd_us_svi)), 2, 3))) %>%
  mutate(impact_class_demo_num_temp = impact_class_demo_sub + impact_class_demo_tract) %>%
  mutate(impact_class_demo_num = case_when(impact_class_demo_num_temp == 2 ~ 1,
                                           impact_class_demo_num_temp == 3 ~ 2,
                                           impact_class_demo_num_temp == 4 ~ 3)) %>% # shift so range is from 1 to 3
  mutate(impact_class_demo_char = case_when(impact_class_demo_num == 1 ~ "low",
                                            impact_class_demo_num == 2 ~ "medium",
                                            impact_class_demo_num == 3 ~ "high")) %>%
  select(SUB:range_svi, impact_class_demo_num, impact_class_demo_char)

# select high risk (demo only = svi only)
hiflow_outlier_reclass_demo_hi <- hiflow_outlier_reclass_demo %>%
  filter(impact_class_demo_char == "high")

# high outlier flow (hydrology + demographics)
hiflow_outlier_reclass_hydrodemo <- hiflow_outlier_change_data %>%
  select(SUB, minor_outlier_perc_change_per_yr, dataset) %>%
  left_join(yadkin_svi_total_sub_data, by = "SUB") %>% # join area weighted svi
  mutate(impact_class_hydro_num = ifelse(minor_outlier_perc_change_per_yr <= 25, 1, 
                                         ifelse((minor_outlier_perc_change_per_yr > 25) & (minor_outlier_perc_change_per_yr <= 50), 2, 3))) %>%
  mutate(impact_class_demo_sub_num = ifelse(area_wt_svi <= mean_us_svi + sd_us_svi, 1, 
                                            ifelse((area_wt_svi > (mean_us_svi + sd_us_svi)) & (area_wt_svi <= (mean_us_svi + 2 * sd_us_svi)), 2, 3))) %>%
  mutate(impact_class_demo_tract_num = ifelse(max_svi <= (mean_us_svi + sd_us_svi), 1, 
                                              ifelse((max_svi > (mean_us_svi + sd_us_svi)) & (max_svi <= (mean_us_svi + 2 * sd_us_svi)), 2, 3))) %>%
  mutate(impact_class_demo_num_temp = impact_class_demo_sub_num + impact_class_demo_tract_num) %>%
  mutate(impact_class_demo_num = case_when(impact_class_demo_num_temp == 2 ~ 1,
                                           impact_class_demo_num_temp == 3 ~ 2,
                                           impact_class_demo_num_temp == 4 ~ 3)) %>% # shift so range is from 1 to 3
  select(SUB:range_svi, impact_class_hydro_num, impact_class_demo_num) %>%
  mutate(impact_class_sum_temp = impact_class_hydro_num + impact_class_demo_num) %>%
  mutate(impact_class_sum_temp_fix_hydro_num = ifelse(minor_outlier_perc_change_per_yr < 0, 3, impact_class_sum_temp)) %>% # for PC values below zero
  mutate(impact_class_sum_temp_fix_demo_num = ifelse(max_svi <= mean_us_svi, 3, impact_class_sum_temp_fix_hydro_num)) %>% # for svi values below mean
  mutate(impact_class_sum_num = case_when(impact_class_sum_temp_fix_demo_num == 2 ~ 1,
                                          impact_class_sum_temp_fix_demo_num == 3 ~ 2,
                                          impact_class_sum_temp_fix_demo_num == 4 ~ 2,
                                          impact_class_sum_temp_fix_demo_num == 5 ~ 3,
                                          impact_class_sum_temp_fix_demo_num == 6 ~ 3)) %>% # shift so range is from 1 to 3
  mutate(impact_class_sum_char = case_when(impact_class_sum_num == 1 ~ "low",
                                           impact_class_sum_num == 2 ~ "medium",
                                           impact_class_sum_num == 3 ~ "high"))

# high outlier flow data for table (high risk, hydro + demo)
hiflow_outlier_reclass_hydrodemo_hi <- hiflow_outlier_reclass_hydrodemo %>%
  filter(impact_class_sum_char == "high")

# define factor levels
hiflow_outlier_reclass_hydro$impact_class_hydro_char=factor(hiflow_outlier_reclass_hydro$impact_class_hydro_char,levels=c("low","medium","high"))
hiflow_outlier_reclass_hydro$dataset=factor(hiflow_outlier_reclass_hydro$dataset,levels=c("miroc8_5","csiro8_5","csiro4_5","hadley4_5"))
hiflow_outlier_reclass_demo$impact_class_demo_char=factor(hiflow_outlier_reclass_demo$impact_class_demo_char,levels=c("low","medium","high"))
hiflow_outlier_reclass_demo$dataset=factor(hiflow_outlier_reclass_demo$dataset,levels=c("miroc8_5","csiro8_5","csiro4_5","hadley4_5"))
hiflow_outlier_reclass_hydrodemo$impact_class_sum_char=factor(hiflow_outlier_reclass_hydrodemo$impact_class_sum_char,levels=c("low","medium","high"))
hiflow_outlier_reclass_hydrodemo$dataset=factor(hiflow_outlier_reclass_hydrodemo$dataset,levels=c("miroc8_5","csiro8_5","csiro4_5","hadley4_5"))


# ---- 6.3 plot on risk matrix with error bars (figure s13) ----

# plot outlier flow data
figure_s13[[2]] <- ggplot(data = hiflow_outlier_reclass_hydrodemo %>% na.omit(),
                             mapping = aes(x = minor_outlier_perc_change_per_yr, y = area_wt_svi, color = impact_class_sum_char, shape = dataset)) +
  geom_errorbar(aes(ymax = max_svi, ymin = min_svi)) +
  geom_point(size = 5, alpha = 0.50) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  geom_vline(xintercept = 50, linetype = "dashed") +
  geom_vline(xintercept = 25, linetype = "dashed") +
  geom_hline(yintercept = mean_us_svi, linetype = "dashed") +
  geom_hline(yintercept = mean_us_svi + sd_us_svi, linetype = "dashed") +
  geom_hline(yintercept = mean_us_svi + 2 * sd_us_svi, linetype = "dashed") +
  labs(x = "PCext", y = "Subbasin SVI",
       color = "Class", shape = "Dataset") +
  xlim(-5, 65) +
  ylim(0, 15) +
  theme_bw() +
  scale_shape_manual(values = c(15, 16, 17, 18)) +
  scale_color_manual(values = c("gold", "orange", "red")) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        text = element_text(size = 18))

# save plot
cairo_pdf(paste0(figure_path, "figure_s13.pdf"), width = 15, height = 8.5, pointsize = 18)
multiplot(plotlist = figure_s13, cols = 2)
dev.off()


# ---- 6.4 plot risk on map (figures s4 and s7) ----

# add to shp file
yadkin_sub_shp_hiflow_outlier_hydro <- left_join(yadkin_sub_shp, hiflow_outlier_reclass_hydro, by = "SUB")
yadkin_sub_shp_hiflow_outlier_hydrodemo <- left_join(yadkin_sub_shp, hiflow_outlier_reclass_hydrodemo, by = "SUB")
# outlier demo is the same as 10yr demo map

# define factor levels
yadkin_sub_shp_hiflow_outlier_hydro$impact_class_hydro_char <- factor(yadkin_sub_shp_hiflow_outlier_hydro$impact_class_hydro_char, levels = c("low", "medium", "high"))
yadkin_sub_shp_hiflow_outlier_hydro$dataset <- factor(yadkin_sub_shp_hiflow_outlier_hydro$dataset, levels = c("miroc8_5", "csiro8_5", "csiro4_5", "hadley4_5"))
yadkin_sub_shp_hiflow_outlier_hydrodemo$impact_class_sum_char <- factor(yadkin_sub_shp_hiflow_outlier_hydrodemo$impact_class_sum_char, levels = c("low", "medium", "high"))
yadkin_sub_shp_hiflow_outlier_hydrodemo$dataset <- factor(yadkin_sub_shp_hiflow_outlier_hydrodemo$dataset, levels = c("miroc8_5", "csiro8_5", "csiro4_5", "hadley4_5"))
# outlier demo is the same as 10yr demo map

# plot map of hydro risk results (swat only)
cairo_pdf(paste0(figure_path, "figure_s4.pdf"), width = 11, height = 8.5, pointsize = 18)
ggplot(yadkin_sub_shp_hiflow_outlier_hydro, aes(fill = impact_class_hydro_char)) +
  facet_wrap(~dataset) +
  geom_sf() +
  coord_sf(crs = st_crs(102003)) + # yadkin_sub_shp_hiflow_outlier_hydro is base utm 17N so convert to Albers for CONUS
  scale_fill_manual(values = c("gold", "orange", "red"), na.value = "grey75") +
  theme_bw()
dev.off()

# plot map of hydro + demo risk results (swat + svi)
cairo_pdf(paste0(figure_path, "figure_s7.pdf"), width = 11, height = 8.5, pointsize = 18)
ggplot(yadkin_sub_shp_hiflow_outlier_hydrodemo, aes(fill = impact_class_sum_char)) +
  facet_wrap(~dataset) +
  geom_sf() +
  coord_sf(crs = st_crs(102003)) + # yadkin_sub_shp_hiflow_outlier_hydrodemo is base utm 17N so convert to Albers for CONUS
  scale_fill_manual(values = c("gold", "orange", "red"), na.value = "grey75") +
  theme_bw()
dev.off()


# ---- 6.5 select subbasins for tables s3 - s5 ----

# table s3 data from hydro results (swat only)
hiflow_outlier_reclass_hydro_hi_sel <- hiflow_outlier_reclass_hydro_hi %>%
  select(SUB, dataset, minor_outlier_perc_change_per_yr, area_wt_svi, max_svi)
View(hiflow_outlier_reclass_hydro_hi_sel)

# table s4 data from demo results (svi only)
hiflow_outlier_reclass_demo_hi_sel <- hiflow_outlier_reclass_demo_hi %>%
  select(SUB, dataset, area_wt_svi, max_svi)
View(hiflow_outlier_reclass_demo_hi_sel)

# table s5 data from demo results (swat + svi)
hiflow_outlier_reclass_hydrodemo_hi_sel <- hiflow_outlier_reclass_hydrodemo_hi %>%
  select(SUB, dataset, minor_outlier_perc_change_per_yr, area_wt_svi, max_svi)
View(hiflow_outlier_reclass_hydrodemo_hi_sel)


# ---- 7. zoom into select subbasins (figure 6) ----

# reformat unclipped data
yadkin_unclip_tract_shp_sel_total <- yadkin_unclip_tract_shp %>%
  select(fips, County = COUNTY, ST_ABBR, svi = SPL_THEMES, geometry)

# select subbasin 15
# select subbasin of interest
my_sub15 <- 15
yadkin_sub15_shp <- yadkin_sub_shp %>%
  filter(SUB == my_sub15)

# select tract svi theme data for subbasin of interest
my_glimpse_sub15 <- yadkin_sub15_shp %>%
  st_join(yadkin_unclip_tract_shp_sel_total)

# look at counties that are included
unique(my_glimpse_sub15$County)
min(my_glimpse_sub15$svi)
max(my_glimpse_sub15$svi)

# select river for area of interest
yadkin_river_sub15_shp <- yadkin_sub15_shp %>%
  select(geometry) %>%
  st_intersection(yadkin_river_shp)

yadkin_tract_sub15_svi_total <- yadkin_unclip_tract_shp_sel_total %>%
  filter(County == "Cabarrus" |
           County == "Davidson" |
           County == "Montgomery" |
           County == "Rowan" |
           County == "Stanly")

# make a list to hold plots
figure_6 <- list()

# subbasin 15 plot
figure_6[[1]] <- ggplot() + 
  geom_sf(data = yadkin_tract_sub15_svi_total, aes(fill = svi, color = County), size = 1) + 
  geom_sf(data = yadkin_river_sub15_shp, color = "blue", alpha = 0, size = 1.5) +
  geom_sf(data = yadkin_sub15_shp, color = "black", alpha = 0, size = 2) +
  coord_sf(crs = st_crs(102003)) + # yadkin_tract_sel_svi_total is base utm 17N so convert to Albers for CONUS
  scale_fill_gradient2("svi", high = "darkred", low = "white", limits = c(0, 15)) +
  scale_color_manual(values = c("Cabarrus" = "#fc8d62",
                                "Davidson" = "#8da0cb",
                                "Montgomery" = "#66c2a5",
                                "Rowan" = "#e78ac3",
                                "Stanly" = "#a6d854")) +
  theme_bw()


# select subbasin 8
my_sub8 <- 8
yadkin_sub8_shp <- yadkin_sub_shp %>%
  filter(SUB == my_sub8)

# select tract svi theme data for subbasin of interest
my_glimpse_sub8 <- yadkin_sub8_shp %>%
  st_join(yadkin_unclip_tract_shp_sel_total)

# select river for area of interest
yadkin_river_sub8_shp <- yadkin_sub8_shp %>%
  select(geometry) %>%
  st_intersection(yadkin_river_shp)

# look at counties that are included
unique(my_glimpse_sub8$County)
min(my_glimpse_sub8$svi)

yadkin_tract_sub8_svi_total <- yadkin_unclip_tract_shp_sel_total %>%
  filter(County == "Davidson" |
           County == "Forsyth" |
           County == "Stokes")

# subbasin 8 plot
figure_6[[2]] <- ggplot() + 
  geom_sf(data = yadkin_tract_sub8_svi_total, aes(fill = svi, color = County), size = 1) + 
  geom_sf(data = yadkin_river_sub8_shp, color = "blue", alpha = 0, size = 1.5) +
  geom_sf(data = yadkin_sub8_shp, color = "black", alpha = 0, size = 2) +
  coord_sf(crs = st_crs(102003)) + # yadkin_tract_sel_svi_total is base utm 17N so convert to Albers for CONUS
  scale_fill_gradient2("svi", high = "darkred", low = "white", limits = c(0, 15)) +
  scale_color_manual(values = c("Davidson" = "#8da0cb", 
                                "Forsyth" = "#fc8d62", 
                                "Stokes" = "#66c2a5")) +
  theme_bw()


# select 24
# select subbasin of interest
my_sub24 <- 24
yadkin_sub24_shp <- yadkin_sub_shp %>%
  filter(SUB == my_sub24)

# select tract svi theme data for subbasin of interest
my_glimpse_sub24 <- yadkin_sub24_shp %>%
  st_join(yadkin_unclip_tract_shp_sel_total)

# look at counties that are included
unique(my_glimpse_sub24$County)
min(my_glimpse_sub24$svi)

# select river for area of interest
yadkin_river_sub24_shp <- yadkin_sub24_shp %>%
  select(geometry) %>%
  st_intersection(yadkin_river_shp)

yadkin_tract_sub24_svi_total <- yadkin_unclip_tract_shp_sel_total %>%
  filter(County == "Anson" |
           County == "Union")

# subbasin 24 plot
figure_6[[3]] = ggplot() + 
  geom_sf(data = yadkin_tract_sub24_svi_total, aes(fill = svi, color = County), size = 1) + 
  geom_sf(data = yadkin_river_sub24_shp, color = "blue", alpha = 0, size = 1.5) +
  geom_sf(data = yadkin_sub24_shp, color = "black", alpha = 0, size = 2) +
  coord_sf(crs = st_crs(102003)) + # is base utm 17N so convert to Albers for CONUS
  scale_fill_gradient2("svi",high = "darkred", low = "white", limits = c(0, 15)) +
  scale_color_manual(values = c("Anson" = "#fc8d62",
                                "Union" = "#8da0cb")) +
  theme_bw()

# save plot of subbasins 15, 8, and 24 together
cairo_pdf(paste0(figure_path, "figure_6.pdf"), width = 18, height = 18, pointsize = 24)
multiplot(plotlist = figure_6, cols = 2)
dev.off()


# ---- 8. cdf calcs and plots (figure s11) ----

# all subs, total svi
cdf_calcs_total_svi <- yadkin_svi_data %>%
  select(SUB, fips, sub_perc, svi_total) %>%
  arrange(SUB, svi_total) %>%
  group_by(SUB) %>%
  mutate(svi_total_wtd = sub_perc * svi_total,
         cumul_sum_svi_total = cumsum(svi_total_wtd) / sum(svi_total_wtd))

cdf_calcs_total_svi_with_mean_svi <- yadkin_svi_total_sub_data %>%
  select(SUB, area_wt_svi) %>%
  mutate(mean_wt = 0.5)

# save plot
cairo_pdf(paste0(figure_path, "figure_s11.pdf"), width = 12, height = 12, pointsize = 18)
ggplot() +
  geom_point(data = cdf_calcs_total_svi, aes(x = svi_total, y = cumul_sum_svi_total)) +
  geom_point(data = cdf_calcs_total_svi_with_mean_svi, aes(x = area_wt_svi, y = mean_wt), color = "red", shape = 17, size = 3, alpha = 0.75) +
  facet_wrap(~SUB, ncol = 7) +
  xlab("SVI") +
  ylab("CDF (Weighted)") +
  geom_vline(xintercept = mean_us_svi, linetype = "dashed") +
  geom_vline(xintercept = mean_us_svi + sd_us_svi, linetype = "dashed") +
  geom_vline(xintercept = mean_us_svi + 2 * sd_us_svi, linetype = "dashed") +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        text = element_text(size = 10))
dev.off()


# ---- 9.1 summarize high risk subbasins for mapping ----

# summarize demographics only data (aka demo only = svi only)
svi_summary_risk_data <- hiflow_10yr_reclass_demo_hi_sel %>%
  select(SUB) %>%
  distinct(SUB) %>%
  mutate(high_risk = "yes")

# summarize 10yr hydrology only data (aka hydro only = swat only)
swat_10yr_summary_risk_data <- hiflow_10yr_reclass_hydro_hi_sel %>%
  select(SUB) %>%
  distinct(SUB) %>%
  mutate(high_risk = "yes")

# summarize 10yr hydrology + demographics data (aka hydro + demo = swat + svi)
svi_swat_10yr_summary_risk_data <- hiflow_10yr_reclass_hydrodemo_hi_sel %>%
  select(SUB) %>%
  distinct(SUB) %>%
  mutate(high_risk = "yes")

# summarize outlier hydrology only data (aka hydro only = swat only)
swat_outlier_summary_risk_data <- hiflow_outlier_reclass_hydro_hi_sel %>%
  select(SUB) %>%
  distinct(SUB) %>%
  mutate(high_risk = "yes")

# summarize outlier hydrology + demographics data (aka hydro + demo = swat + svi)
svi_swat_outlier_summary_risk_data <- hiflow_outlier_reclass_hydrodemo_hi_sel %>%
  select(SUB) %>%
  distinct(SUB) %>%
  mutate(high_risk = "yes")

# add to shp file
svi_summary_risk_map <- left_join(yadkin_sub_shp, svi_summary_risk_data, by = "SUB")
swat_10yr_summary_risk_map <- left_join(yadkin_sub_shp, swat_10yr_summary_risk_data, by = "SUB")
svi_swat_10yr_summary_risk_map <- left_join(yadkin_sub_shp, svi_swat_10yr_summary_risk_data, by = "SUB")
swat_outlier_summary_risk_map <- left_join(yadkin_sub_shp, swat_outlier_summary_risk_data, by = "SUB")
svi_swat_outlier_summary_risk_map <- left_join(yadkin_sub_shp, svi_swat_outlier_summary_risk_data, by = "SUB")


# ---- 9.2 plot summary map of high risk subbasins (figure 4) ----

# make a list to hold plots
figure_4 = list()

# svi only map
figure_4[[1]] <- ggplot(svi_summary_risk_map, aes(fill = high_risk)) +
  geom_sf() +
  coord_sf(crs = st_crs(102003)) + # svi_summary_risk_map is base utm 17N so convert to Albers for CONUS
  scale_fill_manual(values = c("red"), na.value = "white") +
  theme_bw()

# 10yr hydro only map
figure_4[[3]] <- ggplot(swat_10yr_summary_risk_map, aes(fill = high_risk)) +
  geom_sf() +
  coord_sf(crs = st_crs(102003)) + # swat_10yr_summary_risk_map is base utm 17N so convert to Albers for CONUS
  scale_fill_manual(values = c("red"), na.value = "white") +
  theme_bw()

# 10yr hydro + demo map
figure_4[[5]] <- ggplot(svi_swat_10yr_summary_risk_map, aes(fill = high_risk)) +
  geom_sf() +
  coord_sf(crs = st_crs(102003)) + # svi_swat_10yr_summary_risk_map is base utm 17N so convert to Albers for CONUS
  scale_fill_manual(values = c("red"), na.value = "white") +
  theme_bw()

# outlier hydro only map
figure_4[[4]] <- ggplot(swat_outlier_summary_risk_map, aes(fill = high_risk)) +
  geom_sf() +
  coord_sf(crs = st_crs(102003)) + # swat_outlier_summary_risk_map is base utm 17N so convert to Albers for CONUS
  scale_fill_manual(values = c("red"), na.value = "white") +
  theme_bw()

# outlier hydro + demo map
figure_4[[6]] <- ggplot(svi_swat_outlier_summary_risk_map, aes(fill = high_risk)) +
  geom_sf() +
  coord_sf(crs = st_crs(102003)) + # svi_swat_outlier_summary_risk_map is base utm 17N so convert to Albers for CONUS
  scale_fill_manual(values = c("red"), na.value = "white") +
  theme_bw()

# plot together
cairo_pdf(paste0(figure_path, "figure_4.pdf"), width = 11, height = 8.5, pointsize = 18)
multiplot(plotlist = figure_4, cols = 3)
dev.off()


# ---- 10. watershed population calcs ----

# calculate total percentage of each tract in the watershed
svidb_scaling_data_tract_sum <- svidb_scaling_data %>%
  group_by(fips) %>%
  summarize(tract_perc_fix = sum(tract_perc))

# use percentage of each tract to weight census estimates (and also need to recalculate moe)
yadkin_census_tract_wtd_data <- yadkin_census_tract_data %>%
  select(fips:M_GROUPQ) %>% # don't want per capita income
  group_by(fips) %>%
  gather(key = acs_variable, value = value, E_TOTPOP:M_GROUPQ) %>%
  mutate(data_type = ifelse(str_sub(acs_variable, 1, 1) == "E", "estimate", "moe"),
         acs_variable_short = str_sub(str_to_lower(acs_variable), 3)) %>%
  select(-acs_variable) %>%
  ungroup() %>%
  left_join(svidb_scaling_data_tract_sum, by = "fips") %>%
  na.omit() %>% # 2 census tracts with na's and they are both technically outside the YPD
  mutate(wtd_value = ifelse(data_type == "estimate", value * tract_perc_fix, (value * tract_perc_fix)^2)) # if not estimate then calculate moe

# calcalate number of unique census tracts in the yadkin-pee dee
length(unique(yadkin_census_tract_wtd_data$fips))
# 456 census tracts

# calculate number of unique counties in the yadkin-pee dee
length(unique(yadkin_tract_shp$COUNTY))
# 27 counties

# summarize for each census variable
yadkin_census_tract_wtd_summary_data <- yadkin_census_tract_wtd_data %>%
  group_by(acs_variable_short, data_type) %>%
  summarize(value_adj = sum(wtd_value)) %>%
  ungroup() %>%
  mutate(value_final = ifelse(data_type == "estimate", value_adj, sqrt(value_adj))) %>%
  mutate(value_final_round = signif(value_final, 3)) %>%
  select(-value_adj)

# histogram of all pci data
hist(yadkin_census_tract_wtd_data$value[yadkin_census_tract_wtd_data$acs_variable_short == "pci" & yadkin_census_tract_wtd_data$data_type == "estimate"])

# average pci for all (456) census tracts (need to calculate this separately from others b/c it's normalized by population)
num_tracts <- dim(yadkin_unique_fips)[1]
pci_est_to_fix <- yadkin_census_tract_wtd_summary_data$value_final[(yadkin_census_tract_wtd_summary_data$acs_variable_short == "pci")&(yadkin_census_tract_wtd_summary_data$data_type =="estimate")]
pci_moe_to_fix <- yadkin_census_tract_wtd_summary_data$value_final[(yadkin_census_tract_wtd_summary_data$acs_variable_short == "pci")&(yadkin_census_tract_wtd_summary_data$data_type =="moe")]

# update yadkin_census_tract_wtd_summary_data
yadkin_census_tract_wtd_summary_data$value_final[(yadkin_census_tract_wtd_summary_data$acs_variable_short == "pci")&(yadkin_census_tract_wtd_summary_data$data_type =="estimate")] <- pci_est_to_fix/num_tracts
yadkin_census_tract_wtd_summary_data$value_final[(yadkin_census_tract_wtd_summary_data$acs_variable_short == "pci")&(yadkin_census_tract_wtd_summary_data$data_type =="moe")] <- pci_moe_to_fix/num_tracts
yadkin_census_tract_wtd_summary_data$value_final_round[(yadkin_census_tract_wtd_summary_data$acs_variable_short == "pci")&(yadkin_census_tract_wtd_summary_data$data_type =="estimate")] <- signif(pci_est_to_fix/num_tracts, 3)
yadkin_census_tract_wtd_summary_data$value_final_round[(yadkin_census_tract_wtd_summary_data$acs_variable_short == "pci")&(yadkin_census_tract_wtd_summary_data$data_type =="moe")] <- signif(pci_moe_to_fix/num_tracts, 3)
View(yadkin_census_tract_wtd_summary_data)

# calculate number of unique tracts above mean + sd svi
num_tracts_above_first_sd <- yadkin_census_tract_data %>% 
  filter(SPL_THEMES > (mean_us_svi + sd_us_svi)) %>%
  select(fips)
# 107 tracts therefore 107/456 = 23% of tracts are above the first sd svi

# calculate the population of watershed with svi above mean + sd
pop_above_first_sd <- right_join(yadkin_census_tract_wtd_data, num_tracts_above_first_sd, by = "fips") %>%
  filter(acs_variable_short == "totpop") %>%
  group_by(data_type) %>%
  summarize(value_adj = sum(wtd_value)) %>%
  ungroup() %>%
  mutate(value_final = ifelse(data_type == "estimate", value_adj, sqrt(value_adj))) %>%
  mutate(value_final_round = signif(value_final, 3)) %>%
  select(-value_adj)
# 357,000 people therefore 357000/1660000 = 21 % of population

# calculate number of unique tracts above mean + 2 * sd svi
num_tracts_above_second_sd <- yadkin_census_tract_data %>%
  filter(SPL_THEMES > (mean_us_svi + 2 * sd_us_svi)) %>%
  select(fips)
# 10 tracts therefore 10/456 = 4.6% of tracts are above the second sd svi

# calculate the population of watershed with svi above mean + 2 * sd
pop_above_second_sd <- right_join(yadkin_census_tract_wtd_data, num_tracts_above_second_sd, by = "fips") %>%
  filter(acs_variable_short == "totpop") %>%
  group_by(data_type) %>%
  summarize(value_adj = sum(wtd_value)) %>%
  ungroup() %>%
  mutate(value_final = ifelse(data_type == "estimate", value_adj, sqrt(value_adj))) %>%
  mutate(value_final_round = signif(value_final, 3)) %>%
  select(-value_adj)
# 28,000 people therefore 28000/1660000 = 1.7 % of population

# find average and sd of population for tracts that are completely in the YPD
avg_census_tract_calcs <- yadkin_census_tract_wtd_data %>%
  filter(acs_variable_short == "totpop") %>%
  filter(data_type == "estimate") %>%
  filter(tract_perc_fix == 1)
  
# mean of population in each census tract
mean(avg_census_tract_calcs$value)
# 4340 people

# sd of population in each census tract
sd(avg_census_tract_calcs$value)
# +/- 1694 people

# number of people below poverty line
275000/1660000*100
# 16.6 %

