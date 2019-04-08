# yadkin high flow analysis script

# ---- 1. set up -----

# load libraries
library(here)
library(tidyverse)
library(sf)
library(smwrBase)
library(ggridges)
library(grid)

# define paths
project_path <- here::here()
functions_path <- paste0(project_path, "/functions/")
gis_data_path <- paste0(project_path, "/data/spatial/")
tabular_data_path <- paste0(project_path, "/data/tabular/")
figure_path <- paste0(project_path, "/figures/")

# load home-made functions 
source(paste0(functions_path,"reformat_rch_file.R")) # reformat SWAT .rch file
source(paste0(functions_path,"obs_hiflow_freq_calcs_one_rch.R")) # select observations for one reach
source(paste0(functions_path,"obs_freq_calcs_all_rchs.R")) # selects observations for all reaches
source(paste0(functions_path,"model_hiflow_freq_calcs_one_rch.R")) # determines high flow model for one reach
source(paste0(functions_path,"model_freq_calcs_all_rchs.R")) # determines flow model for all reaches
source(paste0(functions_path,"logpearson3_factor_calc.R")) # calculate log-Pearson III frequency factors
source(paste0(functions_path,"remove_outliers.R")) # removes high flows deemed as statistical outliers
source(paste0(functions_path,"rp_n_flow_change.R")) # determines percent change in flows greater to or equal to a specied return period
source(paste0(functions_path,"count_hiflow_outliers.R")) # counts number of minor and major outliers for risk analysis
source(paste0(functions_path,"count_hiflow_outliers_using_baseline.R")) # counts number of minor and major outliers for risk analysis based on baseline cutoffs
source(paste0(functions_path,"outlier_change.R")) # determines % change in minor and major outliers
source(paste0(functions_path,"multiplot.R")) # for creating plots with multiple figures

# download kn_table for outlier analysis
kn_table <- read_csv(paste0(tabular_data_path, "kn_table_appendix4_usgsbulletin17b.csv"),col_names=TRUE)

# load data
# true baseline
baseline_rch_data_raw <- read_table2(paste0(tabular_data_path, "true_baseline_output.rch"), col_names = FALSE, skip = 9) # true baseline .rch file from SWAT calibration

# baseline climate+landuse change data (backcasted)
miroc_baseline_rch_data_raw <- read_table2(paste0(tabular_data_path, "miroc_backcast_baseline_output.rch"), col_names = FALSE, skip = 9) # baseline backcast .rch file from SWAT
csiro_baseline_rch_data_raw <- read_table2(paste0(tabular_data_path, "csiro_backcast_baseline_output.rch"), col_names = FALSE, skip = 9) # baseline backcast .rch file from SWAT
hadley_baseline_rch_data_raw <- read_table2(paste0(tabular_data_path, "hadley_backcast_baseline_output.rch"), col_names = FALSE, skip = 9) # baseline backcast .rch file from SWAT

# miroc rcp 8.5 climate+landuse change data
miroc8_5_rch_data_raw <- read_table2(paste0(tabular_data_path, "miroc_8.5_projected_output.rch"), col_names = FALSE, skip = 9)

# csiro rcp 8.5 climate+landuse change data
csiro8_5_rch_data_raw <- read_table2(paste0(tabular_data_path, "csiro_8.5_projected_output.rch"), col_names = FALSE, skip = 9)

# csiro rcp 4.5 climate+landuse change data
csiro4_5_rch_data_raw <- read_table2(paste0(tabular_data_path, "csiro_4.5_projected_output.rch"), col_names = FALSE, skip = 9)

# hadley rcp 4.5 climate+landuse change data
hadley4_5_rch_data_raw <- read_table2(paste0(tabular_data_path, "hadley_4.5_projected_output.rch"), col_names = FALSE, skip = 9)

# gis data
yadkin_subs_shp_raw <- read_sf(paste0(gis_data_path, "yadkin_subs_utm17N.shp"), quiet = TRUE)


# ---- 2. reformat data ----

# true baseline data
baseline_rch_data <- reformat_rch_file(baseline_rch_data_raw) %>% 
  filter(YR < 2003)
# take only most recent years (1982-2002) so there's same data record length as projection

# backcast baseline data
miroc_baseline_rch_data <- reformat_rch_file(miroc_baseline_rch_data_raw) # backcast
csiro_baseline_rch_data <- reformat_rch_file(csiro_baseline_rch_data_raw) # backcast
hadley_baseline_rch_data <- reformat_rch_file(hadley_baseline_rch_data_raw) # backcast
# all climate model baseline backcasts are from 1982-2002

# mirco 8.5 data
miroc8_5_rch_data <- reformat_rch_file(miroc8_5_rch_data_raw)

# csiro 8.5 data
csiro8_5_rch_data <- reformat_rch_file(csiro8_5_rch_data_raw)

# csiro 4.5 data
csiro4_5_rch_data <- reformat_rch_file(csiro4_5_rch_data_raw)

# hadley 4.5 data
hadley4_5_rch_data <- reformat_rch_file(hadley4_5_rch_data_raw)

# add SUB column to .shp file
yadkin_subs_shp <- yadkin_subs_shp_raw %>% 
  mutate(SUB = Subbasin)

# make dataframe with contributing areas to can use to plot
contributing_areas <- miroc_baseline_rch_data %>% # doesn't matter which baseline dataset is used here
  select(RCH, AREAkm2) %>%
  distinct() %>% 
  mutate(SUB = RCH) %>% 
  select(-RCH)


# ---- 3. calculate observed and modeled ouptuts for each subbasin ----

# probability list
my_model_p_list <- c(0.99, 0.95, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.2, 0.1, 0.08, 0.06, 0.04, 0.03, 0.02, 0.01)

# miroc baseline backcast
miroc_baseline_obs_calcs <- obs_freq_calcs_all_rchs(miroc_baseline_rch_data, 1)
miroc_baseline_model_calcs <- model_freq_calcs_all_rchs(miroc_baseline_obs_calcs, kn_table, my_model_p_list, 0.4)
# coersion warnings are ok here

# mirco 8.5 projection
miroc8_5_obs_calcs <- obs_freq_calcs_all_rchs(miroc8_5_rch_data, 1)
miroc8_5_model_calcs <- model_freq_calcs_all_rchs(miroc8_5_obs_calcs, kn_table, my_model_p_list, 0.4)
# coersion warnings are ok here

# csiro baseline backcast (for comparison with csiro 8.5 and 4.5 projections)
csiro_baseline_obs_calcs <- obs_freq_calcs_all_rchs(csiro_baseline_rch_data, 1)
csiro_baseline_model_calcs <- model_freq_calcs_all_rchs(csiro_baseline_obs_calcs, kn_table, my_model_p_list, 0.4)
# coersion warnings are ok here

# csiro 8.5 projection
csiro8_5_obs_calcs <- obs_freq_calcs_all_rchs(csiro8_5_rch_data, 1)
csiro8_5_model_calcs <- model_freq_calcs_all_rchs(csiro8_5_obs_calcs, kn_table, my_model_p_list, 0.4)
# coersion warnings are ok here

# cisro 4.5 projection
csiro4_5_obs_calcs <- obs_freq_calcs_all_rchs(csiro4_5_rch_data, 1)
csiro4_5_model_calcs <- model_freq_calcs_all_rchs(csiro4_5_obs_calcs, kn_table, my_model_p_list, 0.4)
# coersion warnings are ok here

# hadley baseline backcast
hadley_baseline_obs_calcs <- obs_freq_calcs_all_rchs(hadley_baseline_rch_data, 1)
hadley_baseline_model_calcs <- model_freq_calcs_all_rchs(hadley_baseline_obs_calcs, kn_table, my_model_p_list, 0.4)
# coersion warnings are ok here

# hadley 4.5 projection
hadley4_5_obs_calcs <- obs_freq_calcs_all_rchs(hadley4_5_rch_data, 1)
hadley4_5_model_calcs <- model_freq_calcs_all_rchs(hadley4_5_obs_calcs, kn_table, my_model_p_list, 0.4)
# coersion warnings are ok here


# ---- 4.1 calculate % change in NUMBER OF FLOWS at/above a given return period (backcast) ----

# 10-yr return period
miroc8_5_10yr_n_flow_change <- rp_n_flow_change(10, miroc_baseline_model_calcs, miroc_baseline_rch_data, miroc8_5_rch_data) %>%
  mutate(dataset = "miroc8_5")
csiro4_5_10yr_n_flow_change <- rp_n_flow_change(10, csiro_baseline_model_calcs, csiro_baseline_rch_data, csiro4_5_rch_data) %>%
  mutate(dataset = "csiro4_5")
csiro8_5_10yr_n_flow_change <- rp_n_flow_change(10, csiro_baseline_model_calcs, csiro_baseline_rch_data, csiro8_5_rch_data) %>%
  mutate(dataset = "csiro8_5")
hadley4_5_10yr_n_flow_change <- rp_n_flow_change(10, hadley_baseline_model_calcs, hadley_baseline_rch_data, hadley4_5_rch_data) %>%
  mutate(dataset = "hadley4_5")


# ---- 4.2 reformat calcs for plots ----

# combine data for plotting
n_flow_change_10yr <- rbind(miroc8_5_10yr_n_flow_change,
                            csiro4_5_10yr_n_flow_change,
                            csiro8_5_10yr_n_flow_change,
                            hadley4_5_10yr_n_flow_change) %>%
  mutate(SUB = RCH)

# select data for scatter plot
n_flow_change_10yr_sel <- n_flow_change_10yr %>%
  select(SUB, dataset, perc_change_per_yr) %>%
  left_join(contributing_areas, by = "SUB")

n_flow_change_10yr_sel_summary <- n_flow_change_10yr_sel %>%
  group_by(SUB, AREAkm2) %>%
  na.omit() %>%
  summarize(min_perc_change_per_yr = min(perc_change_per_yr),
            max_perc_change_per_yr = max(perc_change_per_yr),
            mean_perc_change_per_yr = mean(perc_change_per_yr))

# arrange for plotting
n_flow_change_10yr_sel$SUB <- factor(n_flow_change_10yr_sel$SUB, levels = contributing_areas$SUB[order(contributing_areas$AREAkm2)])
n_flow_change_10yr_sel_summary$SUB <- factor(n_flow_change_10yr_sel_summary$SUB, levels = contributing_areas$SUB[order(contributing_areas$AREAkm2)])
n_flow_change_10yr_sel$dataset <- factor(n_flow_change_10yr_sel$dataset, levels = c("miroc8_5", "csiro8_5", "csiro4_5", "hadley4_5"))


# ---- 4.3 plot % change as scatter plot (figure 3) ----

# make a list to hold scatter plots
figure_3 <- list()

# scatter plot
figure_3[[1]] <- ggplot() +
  geom_pointrange(data = n_flow_change_10yr_sel_summary,
                  aes(x = SUB,y = mean_perc_change_per_yr, ymin = min_perc_change_per_yr, ymax = max_perc_change_per_yr),
                  shape = 32) +
  geom_point(data = n_flow_change_10yr_sel, 
             aes(x = SUB, y = perc_change_per_yr, color = dataset),
             shape = 16, size = 5, alpha = 0.75, position = position_jitter(height = 0.075, width = 0)) +
  xlab("Subbasin ID") +
  ylab("PC10") +
  scale_color_manual(values=c("grey75", "grey50", "grey25", "black")) +
  ylim(-5, 140) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        text = element_text(size = 18),
        legend.position = c(0.8, 0.8))


# ---- 4.4 calculate variation in NUMBER OF FLOWS ----

# specify number of years of baseline & projection
# for this script to work baseline and projection have to be the same length
baseline_num_yrs <- length(unique(miroc_baseline_rch_data$YR))
projection_num_yrs <- length(unique(miroc8_5_rch_data$YR))

# 10yr flows
# join areas to baseline and projection data
n_flow_change_10yr_area <- n_flow_change_10yr %>%
  left_join(contributing_areas, by = 'SUB')

# separate out backcast baseline data
n_flow_change_10yr_baseline <- n_flow_change_10yr_area %>%
  select(SUB, AREAkm2, n_base_flows, dataset) %>%
  mutate(baseline_n_flows_per_yr = n_base_flows / baseline_num_yrs) %>%
  filter(dataset != "csiro4_5") # don't need both CSIRO datasets b/c backcast baselines are the same for both
n_flow_change_10yr_baseline$dataset <- recode_factor(n_flow_change_10yr_baseline$dataset, "miroc8_5" = "miroc", "csiro8_5" = "csiro", "hadley4_5" = "hadley")

# backcast baseline ordered by subbasin area
n_flow_change_10yr_baseline$SUB <- factor(n_flow_change_10yr_baseline$SUB, levels = contributing_areas$SUB[order(contributing_areas$AREAkm2)])
n_flow_change_10yr_baseline$dataset <- factor(n_flow_change_10yr_baseline$dataset, levels = c("miroc", "csiro", "hadley"))

# backcast baseline summary for pointrange plot
n_flow_change_10yr_baseline_summary <- n_flow_change_10yr_baseline %>%
  group_by(SUB, AREAkm2) %>%
  summarize(min_n_flows_per_yr = min(baseline_n_flows_per_yr),
            max_n_flows_per_yr = max(baseline_n_flows_per_yr),
            mean_n_flows_per_yr = mean(baseline_n_flows_per_yr))

# select only projection results (and recode them for plotting)
n_flow_change_10yr_projection <- n_flow_change_10yr_area %>%
  select(SUB, AREAkm2, n_proj_flows, dataset) %>%
  mutate(projection_n_flows_per_yr = n_proj_flows / projection_num_yrs)

# projection ordered by subbasin area
n_flow_change_10yr_projection$SUB <- factor(n_flow_change_10yr_projection$SUB, levels = contributing_areas$SUB[order(contributing_areas$AREAkm2)])
n_flow_change_10yr_projection$dataset <- factor(n_flow_change_10yr_projection$dataset, levels = c("miroc8_5", "csiro8_5", "csiro4_5", "hadley4_5"))

# projection summary for pointrange plot
n_flow_change_10yr_projection_summary <- n_flow_change_10yr_projection %>%
  group_by(SUB, AREAkm2) %>%
  summarize(min_n_flows_per_yr = min(projection_n_flows_per_yr),
            max_n_flows_per_yr = max(projection_n_flows_per_yr),
            mean_n_flows_per_yr = mean(projection_n_flows_per_yr)) # all are cumulative for length of projection


# ---- 4.5 plot NUMBER OF FLOWS at/above a given return period variation (figure s8) ----

# 10yr flow
# make a list to hold plots
figure_s8 = list()

# backcast baselines variation plot
figure_s8[[1]] = ggplot() +
  geom_pointrange(data = n_flow_change_10yr_baseline_summary,
                  aes(x = SUB, y = mean_n_flows_per_yr, ymin = min_n_flows_per_yr, ymax = max_n_flows_per_yr), shape = 32) +
  geom_point(data = n_flow_change_10yr_baseline, aes(x = SUB, y = baseline_n_flows_per_yr, color = dataset),
             shape = 17, size = 3, alpha = 0.75, position = position_jitter(height = 0.005, width = 0)) +
  xlab("Subbasin ID") +
  ylab("Number of Flows >= 10 yr Flow/Year") +
  scale_color_manual(values=c("grey75", "grey50", "black")) +
  ylim(-0.25, 3) +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        text = element_text(size = 16),
        legend.position = c(0.2, 0.8))

# projection variation plot
figure_s8[[3]] = ggplot() +
  geom_pointrange(data = n_flow_change_10yr_projection_summary,
                  aes(x = SUB, y = mean_n_flows_per_yr, ymin = min_n_flows_per_yr, ymax = max_n_flows_per_yr), shape = 32) +
  geom_point(data = n_flow_change_10yr_projection, aes(x = SUB, y = projection_n_flows_per_yr, color = dataset),
             shape = 16, size = 3, alpha = 0.75, position = position_jitter(height = 0.005, width = 0)) +
  xlab("Subbasin ID") +
  ylab("Number of Flows >= 10 yr Flow/Year") +
  scale_color_manual(values=c("grey75", "grey50", "grey25", "black")) +
  ylim(-0.25, 3) +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        text = element_text(size = 16),
        legend.position = c(0.2, 0.8))


# ---- 4.6 export results ----

# export results
write_csv(n_flow_change_10yr_area,paste0(tabular_data_path, "hiflow_10yr_change_calcs.csv"))


# ---- 5.1 check if flow data is normally distributed ----

# make new data frame without zero values (b/c just looking at actual flows)
# miroc baseline
miroc_baseline_rch_data_log_no_zeros <- miroc_baseline_rch_data %>%
  filter(FLOW_OUTcms != 0) %>%
  mutate(log_FLOW_OUTcms=log(FLOW_OUTcms))

# csiro baseline (backcast)
csiro_baseline_rch_data_log_no_zeros <- csiro_baseline_rch_data %>%
  filter(FLOW_OUTcms != 0) %>%
  mutate(log_FLOW_OUTcms = log(FLOW_OUTcms))

# hadley baseline (backcast)
hadley_baseline_rch_data_log_no_zeros <- hadley_baseline_rch_data %>%
  filter(FLOW_OUTcms != 0) %>%
  mutate(log_FLOW_OUTcms = log(FLOW_OUTcms))

# miroc 8.5
miroc8_5_rch_data_log_no_zeros <- miroc8_5_rch_data %>%
  filter(FLOW_OUTcms != 0) %>%
  mutate(log_FLOW_OUTcms = log(FLOW_OUTcms))

# csiro 8.5
csiro8_5_rch_data_log_no_zeros <- csiro8_5_rch_data %>%
  filter(FLOW_OUTcms != 0) %>%
  mutate(log_FLOW_OUTcms = log(FLOW_OUTcms))

# csiro 4.5
csiro4_5_rch_data_log_no_zeros <- csiro4_5_rch_data %>%
  filter(FLOW_OUTcms != 0) %>%
  mutate(log_FLOW_OUTcms = log(FLOW_OUTcms))

# hadley 4.5
hadley4_5_rch_data_log_no_zeros <- hadley4_5_rch_data %>%
  filter(FLOW_OUTcms != 0) %>%
  mutate(log_FLOW_OUTcms = log(FLOW_OUTcms))

# plot unlogged data
# miroc baseline
ggplot(miroc_baseline_rch_data_log_no_zeros, aes(sample = FLOW_OUTcms)) +
  geom_qq(size = 1) +
  geom_qq_line() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
ggplot(miroc_baseline_rch_data_log_no_zeros, aes(x = FLOW_OUTcms)) +
  geom_histogram() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
# qqplot tails are off line, hist is non-normal

# csiro baseline
ggplot(csiro_baseline_rch_data_log_no_zeros, aes(sample = FLOW_OUTcms)) +
  geom_qq(size = 1) +
  geom_qq_line() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
ggplot(csiro_baseline_rch_data_log_no_zeros, aes(x = FLOW_OUTcms)) +
  geom_histogram() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
# qqplot tails are off line, hist is non-normal

# hadley baseline
ggplot(hadley_baseline_rch_data_log_no_zeros, aes(sample = FLOW_OUTcms)) +
  geom_qq(size = 1) +
  geom_qq_line() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
ggplot(hadley_baseline_rch_data_log_no_zeros, aes(x = FLOW_OUTcms)) +
  geom_histogram() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
# qqplot tails are off line, hist is non-normal

# miroc 8.5
ggplot(miroc8_5_rch_data_log_no_zeros, aes(sample = FLOW_OUTcms)) +
  geom_qq(size = 1) +
  geom_qq_line() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
ggplot(miroc8_5_rch_data_log_no_zeros,aes(x = FLOW_OUTcms)) +
  geom_histogram() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
# qqplot tails are off line, hist is non-normal

# csiro 8.5
ggplot(csiro8_5_rch_data_log_no_zeros, aes(sample = FLOW_OUTcms)) +
  geom_qq(size = 1) +
  geom_qq_line() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
ggplot(csiro8_5_rch_data_log_no_zeros, aes(x = FLOW_OUTcms)) +
  geom_histogram() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
# qqplot tails are off line, hist is non-normal

# csiro 4.5
ggplot(csiro4_5_rch_data_log_no_zeros, aes(sample = FLOW_OUTcms)) +
  geom_qq(size = 1) +
  geom_qq_line() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
ggplot(csiro4_5_rch_data_log_no_zeros, aes(x = FLOW_OUTcms)) +
  geom_histogram() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
# qqplot tails are off line, hist is non-normal

# hadley 4.5
ggplot(hadley4_5_rch_data_log_no_zeros, aes(sample = FLOW_OUTcms)) +
  geom_qq(size = 1) +
  geom_qq_line() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
ggplot(hadley4_5_rch_data_log_no_zeros, aes(x = FLOW_OUTcms)) +
  geom_histogram() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
# qqplot tails are off line, hist is non-normal


# plot logged data
# miroc baseline (backcast)
ggplot(miroc_baseline_rch_data_log_no_zeros, aes(sample = log_FLOW_OUTcms)) +
  geom_qq(size = 1) +
  geom_qq_line() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
ggplot(miroc_baseline_rch_data_log_no_zeros, aes(x = log_FLOW_OUTcms)) +
  geom_histogram() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
# qqplot and hist are normal

# csiro baseline (backcast)
ggplot(csiro_baseline_rch_data_log_no_zeros, aes(sample = log_FLOW_OUTcms)) +
  geom_qq(size = 1) +
  geom_qq_line() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
ggplot(csiro_baseline_rch_data_log_no_zeros, aes(x = log_FLOW_OUTcms)) +
  geom_histogram() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
# qqplot and hist are normal

# hadley baseline (backcast)
ggplot(hadley_baseline_rch_data_log_no_zeros, aes(sample = log_FLOW_OUTcms)) +
  geom_qq(size = 1) +
  geom_qq_line() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
ggplot(hadley_baseline_rch_data_log_no_zeros, aes(x = log_FLOW_OUTcms)) +
  geom_histogram() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
# qqplot and hist are normal

# miroc 8.5
ggplot(miroc8_5_rch_data_log_no_zeros, aes(sample = log_FLOW_OUTcms)) +
  geom_qq(size = 1) +
  geom_qq_line() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
ggplot(miroc8_5_rch_data_log_no_zeros, aes(x = log_FLOW_OUTcms)) +
  geom_histogram() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
# qqplot and hist are normal

# csiro 8.5
ggplot(csiro8_5_rch_data_log_no_zeros, aes(sample = log_FLOW_OUTcms)) +
  geom_qq(size = 1) +
  geom_qq_line() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
ggplot(csiro8_5_rch_data_log_no_zeros, aes(x = log_FLOW_OUTcms)) +
  geom_histogram() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
# qqplot and hist are normal

# csiro 4.5
ggplot(csiro4_5_rch_data_log_no_zeros, aes(sample = log_FLOW_OUTcms)) +
  geom_qq(size = 1) +
  geom_qq_line() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
ggplot(csiro4_5_rch_data_log_no_zeros, aes(x = log_FLOW_OUTcms)) +
  geom_histogram() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
# qqplot and hist are normal

# hadley 4.5
ggplot(hadley4_5_rch_data_log_no_zeros, aes(sample = log_FLOW_OUTcms)) +
  geom_qq(size = 1) +
  geom_qq_line() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
ggplot(hadley4_5_rch_data_log_no_zeros,aes(x = log_FLOW_OUTcms)) +
  geom_histogram() +
  facet_wrap(~RCH, ncol = 7, nrow = 4)
# qqplot and hist are normal

# in conclusion, log transform FLOW_OUTcms data for outlier calcs


# ---- 5.2 calculate outlier cutoffs and number of outlier high flows (no backcast and backcast) ----

# miroc baseline
miroc_baseline_outlier_calcs <- count_hiflow_outliers(miroc_baseline_rch_data)
miroc_baseline_outlier_counts <- miroc_baseline_outlier_calcs[[1]]
miroc_baseline_outlier_cutoffs <- miroc_baseline_outlier_calcs[[2]]

# csiro baseline
csiro_baseline_outlier_calcs <- count_hiflow_outliers(csiro_baseline_rch_data)
csiro_baseline_outlier_counts <- csiro_baseline_outlier_calcs[[1]]
csiro_baseline_outlier_cutoffs <- csiro_baseline_outlier_calcs[[2]]

# hadley baseline
hadley_baseline_outlier_calcs <- count_hiflow_outliers(hadley_baseline_rch_data)
hadley_baseline_outlier_counts <- hadley_baseline_outlier_calcs[[1]]
hadley_baseline_outlier_cutoffs <- hadley_baseline_outlier_calcs[[2]]

# miroc 8.5
miroc8_5_outlier_calcs_using_baseline <- count_hiflow_outliers_using_baseline(miroc_baseline_outlier_cutoffs,miroc8_5_rch_data) # find outliers using backcast baseline cutoff
miroc8_5_outlier_counts_using_baseline <- miroc8_5_outlier_calcs_using_baseline[[1]]
miroc8_5_outlier_cutoffs_using_baseline <- miroc8_5_outlier_calcs_using_baseline[[2]]

# csiro 8.5
csiro8_5_outlier_calcs_using_baseline <- count_hiflow_outliers_using_baseline(csiro_baseline_outlier_cutoffs,csiro8_5_rch_data) # find outliers using backcast baseline cutoff
csiro8_5_outlier_counts_using_baseline <- csiro8_5_outlier_calcs_using_baseline[[1]]
csiro8_5_outlier_cutoffs_using_baseline <- csiro8_5_outlier_calcs_using_baseline[[2]]

# csiro 4.5
csiro4_5_outlier_calcs_using_baseline <- count_hiflow_outliers_using_baseline(csiro_baseline_outlier_cutoffs,csiro4_5_rch_data) # find outliers using backcast baseline cutoff
csiro4_5_outlier_counts_using_baseline <- csiro4_5_outlier_calcs_using_baseline[[1]]
csiro4_5_outlier_cutoffs_using_baseline <- csiro4_5_outlier_calcs_using_baseline[[2]]

# hadley 4.5
hadley4_5_outlier_calcs_using_baseline <- count_hiflow_outliers_using_baseline(hadley_baseline_outlier_cutoffs,hadley4_5_rch_data) # find outliers using backcast baseline cutoff
hadley4_5_outlier_counts_using_baseline <- hadley4_5_outlier_calcs_using_baseline[[1]]
hadley4_5_outlier_cutoffs_using_baseline <- hadley4_5_outlier_calcs_using_baseline[[2]]

# sum outlier counts data by subbasin
# baselines
miroc_baseline_outlier_counts_sum <- miroc_baseline_outlier_counts %>%
  group_by(RCH) %>% 
  summarize(sum_minor_hiflow = sum(n_minor_hiflow),
            sum_major_hiflow = sum(n_major_hiflow)) %>%
  mutate(dataset = "miroc_baseline", datatype = "baseline")
csiro_baseline_outlier_counts_sum <- csiro_baseline_outlier_counts %>%
  group_by(RCH) %>% 
  summarize(sum_minor_hiflow = sum(n_minor_hiflow),
            sum_major_hiflow = sum(n_major_hiflow)) %>%
  mutate(dataset = "csiro_baseline", datatype = "baseline")
hadley_baseline_outlier_counts_sum <- hadley_baseline_outlier_counts %>%
  group_by(RCH) %>% 
  summarize(sum_minor_hiflow = sum(n_minor_hiflow),
            sum_major_hiflow = sum(n_major_hiflow)) %>%
  mutate(dataset = "hadley_baseline", datatype = "baseline")

# projections
miroc8_5_outlier_counts_using_baseline_sum <- miroc8_5_outlier_counts_using_baseline %>%
  group_by(RCH) %>% 
  summarize(sum_minor_hiflow = sum(n_minor_hiflow),
            sum_major_hiflow = sum(n_major_hiflow)) %>%
  mutate(dataset = "miroc8_5", datatype = "projection")
csiro8_5_outlier_counts_using_baseline_sum <- csiro8_5_outlier_counts_using_baseline %>%
  group_by(RCH) %>% 
  summarize(sum_minor_hiflow = sum(n_minor_hiflow),
            sum_major_hiflow = sum(n_major_hiflow)) %>%
  mutate(dataset = "csiro8_5", datatype = "projection")
csiro4_5_outlier_counts_using_baseline_sum <- csiro4_5_outlier_counts_using_baseline %>%
  group_by(RCH) %>% 
  summarize(sum_minor_hiflow = sum(n_minor_hiflow),
            sum_major_hiflow = sum(n_major_hiflow)) %>%
  mutate(dataset = "csiro4_5", datatype = "projection")
hadley4_5_outlier_counts_using_baseline_sum <- hadley4_5_outlier_counts_using_baseline %>%
  group_by(RCH) %>% 
  summarize(sum_minor_hiflow = sum(n_minor_hiflow),
            sum_major_hiflow = sum(n_major_hiflow)) %>%
  mutate(dataset = "hadley4_5", datatype = "projection")

# combine data
all_models_hiflow_outlier_counts <- bind_rows(miroc_baseline_outlier_counts_sum,
                                              csiro_baseline_outlier_counts_sum,
                                              hadley_baseline_outlier_counts_sum,
                                              miroc8_5_outlier_counts_using_baseline_sum,
                                              csiro8_5_outlier_counts_using_baseline_sum,
                                              csiro4_5_outlier_counts_using_baseline_sum,
                                              hadley4_5_outlier_counts_using_baseline_sum)


# ---- 5.3 calculate % change in NUMBER OF MINOR OUTLIER high flows ----

# specify number of years of baseline & projection
# for this script to work baseline and projection have to be the same length
baseline_num_yrs <- length(unique(miroc_baseline_rch_data$YR))

# calculate % change 
miroc8_5_hiflow_outlier_change_using_baseline <- outlier_change(miroc_baseline_outlier_counts_sum, miroc8_5_outlier_counts_using_baseline_sum, baseline_num_yrs)
csiro8_5_hiflow_outlier_change_using_baseline <- outlier_change(csiro_baseline_outlier_counts_sum, csiro8_5_outlier_counts_using_baseline_sum, baseline_num_yrs)
csiro4_5_hiflow_outlier_change_using_baseline <- outlier_change(csiro_baseline_outlier_counts_sum, csiro4_5_outlier_counts_using_baseline_sum, baseline_num_yrs)
hadley4_5_hiflow_outlier_change_using_baseline <- outlier_change(hadley_baseline_outlier_counts_sum, hadley4_5_outlier_counts_using_baseline_sum, baseline_num_yrs)
# coersion warnings are ok to ignore

# bind rows
all_models_hiflow_outlier_change <- bind_rows(miroc8_5_hiflow_outlier_change_using_baseline,
                                              csiro8_5_hiflow_outlier_change_using_baseline,
                                              csiro4_5_hiflow_outlier_change_using_baseline,
                                              hadley4_5_hiflow_outlier_change_using_baseline) %>% 
  mutate(SUB = RCH) %>% 
  select(-RCH)

# add to shp file
yadkin_subs_shp_hiflow_outliers_using_baseline <- left_join(yadkin_subs_shp, all_models_hiflow_outlier_change, by = "SUB")

# adjust levels
yadkin_subs_shp_hiflow_outliers_using_baseline$dataset <- factor(yadkin_subs_shp_hiflow_outliers_using_baseline$dataset, levels = c("miroc8_5", "csiro8_5", "csiro4_5", "hadley4_5"))

# select data for scatter plot
all_models_hiflow_outlier_change_sel <- all_models_hiflow_outlier_change %>%
  select(SUB, dataset, minor_outlier_perc_change_per_yr) %>%
  left_join(contributing_areas, by = "SUB")

all_models_hiflow_outlier_change_sel_summary <- all_models_hiflow_outlier_change_sel %>%
  group_by(SUB, AREAkm2) %>%
  na.omit() %>%
  summarize(min_perc_change_per_yr = min(minor_outlier_perc_change_per_yr),
            max_perc_change_per_yr = max(minor_outlier_perc_change_per_yr),
            mean_perc_change_per_yr = mean(minor_outlier_perc_change_per_yr))

# arrange for plotting
all_models_hiflow_outlier_change_sel$SUB <- factor(all_models_hiflow_outlier_change_sel$SUB, levels = contributing_areas$SUB[order(contributing_areas$AREAkm2)])
all_models_hiflow_outlier_change_sel_summary$SUB <- factor(all_models_hiflow_outlier_change_sel_summary$SUB, levels = contributing_areas$SUB[order(contributing_areas$AREAkm2)])
all_models_hiflow_outlier_change_sel$dataset <- factor(all_models_hiflow_outlier_change_sel$dataset, levels = c("miroc8_5", "csiro8_5", "csiro4_5", "hadley4_5"))
  

# ---- 5.4 plot & change as scatter plot (figure 3) ----

# scatter plot
figure_3[[2]] <- ggplot() +
  geom_pointrange(data = all_models_hiflow_outlier_change_sel_summary,
                  aes(x = SUB, y = mean_perc_change_per_yr, ymin = min_perc_change_per_yr, ymax = max_perc_change_per_yr),
                  shape = 32) +
  geom_point(data = all_models_hiflow_outlier_change_sel, 
             aes(x = SUB, y = minor_outlier_perc_change_per_yr, color = dataset),
             shape = 16, size = 5, alpha = 0.75, position = position_jitter(height = 0.075, width = 0)) +
  xlab("Subbasin ID") +
  ylab("PCext") +
  scale_color_manual(values=c("grey75", "grey50", "grey25", "black")) +
  ylim(-5,140) +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        text = element_text(size = 18),
        legend.position = c(0.8, 0.8))

# save plots
cairo_pdf(paste0(figure_path, "figure_3.pdf"), width = 15, height = 8.5, pointsize = 18)
multiplot(plotlist = figure_3, cols = 2)
dev.off()


# ---- 5.5 calculate variation in NUMBER OF MINOR OUTLIER ----

# join contributing areas
all_models_hiflow_change_area <- all_models_hiflow_outlier_change %>%
  left_join(contributing_areas, by = 'SUB')

# backcast baselines (and recode them for plotting)
hiflow_change_baseline <- all_models_hiflow_change_area %>%
  select(SUB, AREAkm2, baseline_sum_n_minor_outliers, dataset) %>%
  mutate(baseline_sum_n_minor_outliers_per_yr = baseline_sum_n_minor_outliers / baseline_num_yrs) %>%
  filter(dataset != "csiro4_5") # don't need both CSIRO datasets b/c backcast baselines are the same for both
hiflow_change_baseline$dataset <- recode_factor(hiflow_change_baseline$dataset, "miroc8_5" = "MIROC", "csiro8_5" = "CSIRO", "hadley4_5" = "Hadley")

# backcast baseline ordered by subbasin area
hiflow_change_baseline$SUB <- factor(hiflow_change_baseline$SUB, levels = contributing_areas$SUB[order(contributing_areas$AREAkm2)])
hiflow_change_baseline$dataset <- factor(hiflow_change_baseline$dataset, levels = c("MIROC", "CSIRO", "Hadley"))

# backcast baseline summary for pointrange plot
hiflow_change_baseline_summary <- hiflow_change_baseline %>%
  group_by(SUB, AREAkm2) %>%
  summarize(min_n_minor_outliers_per_yr = min(baseline_sum_n_minor_outliers_per_yr),
            max_n_minor_outliers_per_yr = max(baseline_sum_n_minor_outliers_per_yr),
            mean_n_minor_outliers_per_yr = mean(baseline_sum_n_minor_outliers_per_yr))

# projections
miroc8_5_num_yrs <- length(unique(miroc8_5_rch_data$YR)) # all are equal to 21 but use miroc8_5_num_yrs for simplicity
hiflow_change_projection <- all_models_hiflow_change_area %>%
  select(SUB, AREAkm2, projection_sum_n_minor_outliers, dataset) %>%
  mutate(projection_sum_n_minor_outliers_per_yr = projection_sum_n_minor_outliers / miroc8_5_num_yrs) # all are equal to 21 but use miroc8_5_num_yrs for simplicity 

# projections ordered by subbasin area
hiflow_change_projection$SUB <- factor(hiflow_change_projection$SUB, levels = contributing_areas$SUB[order(contributing_areas$AREAkm2)])
hiflow_change_projection$dataset <- factor(hiflow_change_projection$dataset, levels = c("miroc8_5", "csiro8_5", "csiro4_5", "hadley4_5"))

# projections summary for pointrange plot
hiflow_change_projection_summary <- hiflow_change_projection %>%
  group_by(SUB, AREAkm2) %>%
  summarize(min_n_minor_outliers_per_yr = min(projection_sum_n_minor_outliers_per_yr),
            max_n_minor_outliers_per_yr = max(projection_sum_n_minor_outliers_per_yr),
            mean_n_minor_outliers_per_yr = mean(projection_sum_n_minor_outliers_per_yr))


# ---- 5.6 plot NUMBER OF MINOR OUTLIERS variation (figure s8) ----

# backcast baselines plot
figure_s8[[2]] <- ggplot() +
  geom_pointrange(data = hiflow_change_baseline_summary,
                  aes(x = SUB, y = mean_n_minor_outliers_per_yr, ymin = min_n_minor_outliers_per_yr, ymax = max_n_minor_outliers_per_yr), shape = 32) +
  geom_point(data = hiflow_change_baseline, aes(x = SUB, y = baseline_sum_n_minor_outliers_per_yr, color = dataset),
             shape = 17, size = 3, alpha = 0.75, position = position_jitter(height = 0.075, width = 0)) +
  xlab("Subbasin ID") +
  ylab("Number of Minor HOFs/yr") + # HOF = high outlier flows
  scale_color_manual(values=c("grey75", "grey50", "black")) +
  ylim(-1, 20) +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        text = element_text(size = 16),
        legend.position = c(0.8, 0.8))

# projections plot
figure_s8[[4]] = ggplot() +
  geom_pointrange(data = hiflow_change_projection_summary,
                  aes(x = SUB, y = mean_n_minor_outliers_per_yr, ymin = min_n_minor_outliers_per_yr, ymax = max_n_minor_outliers_per_yr),
                  shape = 32) +
  geom_point(data = hiflow_change_projection, aes(x = SUB, y = projection_sum_n_minor_outliers_per_yr, color=dataset),
             size = 3, alpha = 0.75, position = position_jitter(height = 0.1, width = 0)) +
  xlab("Subbasin ID") +
  ylab("Number of Minor HOFs/yr") + # HOF = high outlier flows
  scale_color_manual(values=c("grey80", "grey60", "grey40", "black")) +
  ylim(-1, 20) +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        text = element_text(size = 16),
        legend.position = c(0.8, 0.8))

# save plot
cairo_pdf(paste0(figure_path, "figure_s8.pdf"), width = 10, height = 8.5, pointsize = 16)
multiplot(plotlist = figure_s8, cols = 2)
dev.off()


# ---- 5.7 export results ----

# just export percent change
all_models_hiflow_outlier_change_sel <- all_models_hiflow_outlier_change %>%
  select(SUB, dataset, minor_outlier_perc_change, minor_outlier_perc_change_per_yr, major_outlier_perc_change, major_outlier_perc_change_per_yr)

# export to results
write_csv(all_models_hiflow_outlier_change_sel,paste0(tabular_data_path, "hiflow_outlier_change_calcs.csv"))


# ---- 6.1 baseline comparison density plot (figure s1) ----

# join backcast baseline and projection data for overlapping joyplots
baseline_rch_data_sel <- baseline_rch_data %>% 
  select(RCH, MO, YR, FLOW_OUTcms) %>%
  mutate(dataset = "true_baseline") %>% 
  mutate(datatype = "true_baseline")
miroc_baseline_rch_data_sel <- miroc_baseline_rch_data %>% 
  select(RCH, MO, YR, FLOW_OUTcms) %>%
  mutate(dataset = "miroc_baseline") %>% 
  mutate(datatype = "backcast_baseline")
csiro_baseline_rch_data_sel <- csiro_baseline_rch_data %>% 
  select(RCH, MO, YR, FLOW_OUTcms) %>%
  mutate(dataset = "csiro_baseline") %>% 
  mutate(datatype = "backcast_baseline")
hadley_baseline_rch_data_sel <- hadley_baseline_rch_data %>% 
  select(RCH, MO, YR, FLOW_OUTcms) %>%
  mutate(dataset = "hadley_baseline") %>% 
  mutate(datatype = "backcast_baseline")
miroc8_5_rch_data_sel <- miroc8_5_rch_data %>% 
  select(RCH, MO, YR, FLOW_OUTcms) %>%
  mutate(dataset = "miroc8_5") %>% 
  mutate(datatype = "projection")
csiro8_5_rch_data_sel <- csiro8_5_rch_data %>% 
  select(RCH, MO, YR, FLOW_OUTcms) %>%
  mutate(dataset = "csiro8_5") %>% 
  mutate(datatype = "projection")
csiro4_5_rch_data_sel <- csiro4_5_rch_data %>% 
  select(RCH,MO,YR,FLOW_OUTcms) %>%
  mutate(dataset = "csiro4_5") %>% 
  mutate(datatype = "projection")
hadley4_5_rch_data_sel <- hadley4_5_rch_data %>% 
  select(RCH, MO, YR, FLOW_OUTcms) %>%
  mutate(dataset = "hadley4_5") %>% 
  mutate(datatype = "projection")

# merge data
all_rch_data_sel <- bind_rows(baseline_rch_data_sel,
                              miroc_baseline_rch_data_sel,
                              csiro_baseline_rch_data_sel,
                              hadley_baseline_rch_data_sel,
                              miroc8_5_rch_data_sel,
                              csiro8_5_rch_data_sel,
                              csiro4_5_rch_data_sel,
                              hadley4_5_rch_data_sel)

# order factors
all_rch_data_sel$dataset <- factor(all_rch_data_sel$dataset, levels = rev(c("true_baseline", "miroc_baseline", "miroc8_5", "csiro_baseline", "csiro8_5", "csiro4_5", "hadley_baseline", "hadley4_5")))
all_rch_data_sel$datatype <- factor(all_rch_data_sel$datatype, levels = c("true_baseline", "backcast_baseline", "projection"))

# all baseline datasets for outlet
my_sub = 28 # the outlet subbasin
my_sub_true_baseline_to_bcbaseline <- all_rch_data_sel %>% 
  filter(RCH == my_sub) %>% 
  filter(datatype != "projection") %>%
  mutate(test = case_when(
    dataset == "true_baseline" ~ "Observed",
    dataset == "miroc_baseline" ~ "MIROC Baseline",
    dataset == "csiro_baseline" ~ "CSIRO Baseline",
    dataset == "hadley_baseline" ~ "Hadley Baseline")) #%>%

# calculate annual average of observed
my_sub_true_baseline_to_bcbaseline_obs_sum <- my_sub_true_baseline_to_bcbaseline %>%
  filter(test == "Observed")
mean(my_sub_true_baseline_to_bcbaseline_obs_sum$FLOW_OUTcms)
# 206 cms (checks with table 1.8 in Kelly's thesis)

# order factor
my_sub_true_baseline_to_bcbaseline$test <- factor(my_sub_true_baseline_to_bcbaseline$test, levels = c("Hadley Baseline", "CSIRO Baseline", "MIROC Baseline", "Observed"))

# plot
cairo_pdf(paste0(figure_path, "figure_s1.pdf"), width = 10, height = 10, pointsize = 18)
ggplot(my_sub_true_baseline_to_bcbaseline,
       aes(x = FLOW_OUTcms, y = test, fill = datatype)) +
  geom_density_ridges(alpha = 0.25, scale = 0.75) +
  geom_vline(xintercept = 206, color = "black", linetype = "longdash") +
  xlab("Daily Streamflow") + 
  ylab("Density") +
  xlim(0,600) +
  scale_fill_manual(values = c("#d95f02", "#7570b3")) +
  theme_bw() +
  theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank(),
        panel.background=element_blank(),
        text=element_text(size=18),
        legend.position="none")
dev.off()
