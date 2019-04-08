# yadkin land use analysis script

# ---- 1. set up -----

# load libraries
library(tidyverse)
library(sf)
library(here)

# define paths
project_path <- here::here()
functions_path <- paste0(project_path, "/functions/")
gis_data_path <- paste0(project_path, "/data/spatial/")
tabular_data_path <- paste0(project_path, "/data/tabular/")
figure_path <- paste0(project_path, "/figures/")

# load home-made functions 
source(paste0(functions_path,"reformat_rch_file.R")) # reformat SWAT .rch file

# load watershed wide percent use
# baseline (1992)
baseline_lu <- read_csv(paste0(tabular_data_path, "yadkin_lu_baseline_reclass_1992.txt"), col_names = TRUE) %>% 
  select(VALUE:AREA_PERC) %>%
  arrange(VALUE) %>% 
  mutate(dataset = "baseline")
  
# miroc 8.5 (2060)
miroc8_5_lu <- read_csv(paste0(tabular_data_path, "yadkin_lu_miroc8_5_2060.txt"), col_names = TRUE) %>% 
  select(VALUE:AREA_PERC) %>%
  arrange(VALUE) %>% 
  mutate(dataset = "miroc8_5")

# csiro 8.5 (2060)
csiro8_5_lu <- read_csv(paste0(tabular_data_path, "yadkin_lu_csiro8_5_2060.txt"), col_names = TRUE) %>% 
  select(VALUE:AREA_PERC) %>%
  arrange(VALUE) %>% 
  mutate(dataset = "csiro8_5")

# csiro 4.5 (2060)
csiro4_5_lu <- read_csv(paste0(tabular_data_path, "yadkin_lu_csiro4_5_2060.txt"), col_names = TRUE) %>% 
  select(VALUE:AREA_PERC) %>%
  arrange(VALUE) %>% 
  mutate(dataset = "csiro4_5")

# hadley 4.5 (2060)
hadley4_5_lu <- read_csv(paste0(tabular_data_path, "yadkin_lu_hadley4_5_2060.txt"), col_names = TRUE) %>% 
  select(VALUE:AREA_PERC) %>%
  arrange(VALUE) %>% 
  mutate(dataset = "hadley4_5")

# load subbasin percent use
# baseline (1992)
baseline_lu_sub <- read_csv(paste0(tabular_data_path, "lu_baseline_1992_allsubs.csv"), col_names = TRUE) %>% 
  select(SUB:AREA_PERC) %>%
  arrange(SUB, VALUE) %>% 
  mutate(sub_id = paste0("subid_", SUB, "_", VALUE), dataset = "baseline")

# miroc 8.5 (2060)
miroc8_5_lu_raw <- read_csv(paste0(tabular_data_path, "lu_miroc8_5_2060_allsubs.csv"), col_names = TRUE) %>% 
  select(SUB:AREA_PERC) %>%
  arrange(SUB, VALUE) %>% 
  mutate(sub_id = paste0("subid_", SUB, "_", VALUE)) %>%
  select(sub_id, AREA_PERC)

# csiro 8.5 (2060)
csiro8_5_lu_raw <- read_csv(paste0(tabular_data_path, "lu_csiro8_5_2060_allsubs.csv"), col_names = TRUE) %>% 
  select(SUB:AREA_PERC) %>%
  arrange(SUB, VALUE) %>% 
  mutate(sub_id = paste0("subid_", SUB, "_", VALUE)) %>%
  select(sub_id, AREA_PERC)

# csiro 4.5 (2060)
csiro4_5_lu_raw <- read_csv(paste0(tabular_data_path, "lu_csiro4_5_2060_allsubs.csv"), col_names = TRUE) %>% 
  select(SUB:AREA_PERC) %>%
  arrange(SUB, VALUE) %>% 
  mutate(sub_id = paste0("subid_", SUB, "_", VALUE)) %>%
  select(sub_id, AREA_PERC)

# hadley 4.5 (2060)
hadley4_5_lu_raw <- read_csv(paste0(tabular_data_path, "lu_hadley4_5_2060_allsubs.csv"), col_names = TRUE) %>% 
  select(SUB:AREA_PERC) %>%
  arrange(SUB, VALUE) %>% 
  mutate(sub_id = paste0("subid_", SUB, "_", VALUE)) %>%
  select(sub_id, AREA_PERC)

# load baseline data
baseline_rch_data_raw <- read_table2(paste0(tabular_data_path, "true_baseline_output.rch"), col_names = FALSE, skip = 9) # true baseline .rch file from SWAT calibration

# load subbasin bounds (.shp file)
yadkin_subs_shp_raw <- read_sf(paste0(gis_data_path, "yadkin_subs_utm17N.shp"), quiet = TRUE)


# ---- 2. reformat data ----

# save indexing b/c need to pad empty category area values with zeros
baseline_lu_sub_for_index <- baseline_lu_sub %>% 
  select(sub_id,SUB,VALUE)

# calculate expected number of entries
num_cats <- length(unique(baseline_lu_sub$VALUE))
num_subs <- length(unique(baseline_lu_sub$SUB))
num_cats*num_subs
# 252

# reformat subbasin land use classes
# 2060 are missing some subbasin land use classes so need to pad with zeros
# miroc 8.5 (2060)
miroc8_5_lu_sub <- left_join(baseline_lu_sub_for_index, miroc8_5_lu_raw, by = "sub_id") %>%
  mutate_all(funs(replace(., which(is.na(.)), 0))) %>%
  mutate(dataset = "miroc8_5")

# csiro 8.5 (2060)
csiro8_5_lu_sub <- left_join(baseline_lu_sub_for_index, csiro8_5_lu_raw, by = "sub_id") %>%
  mutate_all(funs(replace(., which(is.na(.)), 0))) %>%
  mutate(dataset = "csiro8_5")

# csiro 4.5 (2060)
csiro4_5_lu_sub <- left_join(baseline_lu_sub_for_index, csiro4_5_lu_raw, by = "sub_id") %>%
  mutate_all(funs(replace(., which(is.na(.)), 0))) %>%
  mutate(dataset = "csiro4_5")

# hadley 4.5 (2060)
hadley4_5_lu_sub <- left_join(baseline_lu_sub_for_index, hadley4_5_lu_raw, by = "sub_id") %>%
  mutate_all(funs(replace(., which(is.na(.)), 0))) %>%
  mutate(dataset = "hadley4_5")

# combine all watershed wide data
yadkin_lu_data <- bind_rows(baseline_lu, miroc8_5_lu, csiro8_5_lu, csiro4_5_lu, hadley4_5_lu)

# value and description summary table
yadkin_lu_descriptions <- yadkin_lu_data[1:num_cats, ] %>% 
  select(VALUE, DESCRIPTION)

# combine all subbasin data
sub_lu_data <- bind_rows(baseline_lu_sub,
                         miroc8_5_lu_sub,
                         csiro8_5_lu_sub,
                         csiro4_5_lu_sub,
                         hadley4_5_lu_sub) %>%
  left_join(yadkin_lu_descriptions , by = "VALUE") # add description in

# baseline streamflow data (need to get contributing areas of each subbasin)
baseline_rch_data <- reformat_rch_file(baseline_rch_data_raw) %>% 
  filter(YR < 2003)

# make dataframe with contributing errors to can use to plot
contributing_areas <- baseline_rch_data %>% 
  select(RCH, AREAkm2) %>%
  distinct() %>% 
  mutate(SUB = RCH) %>%
  select(-RCH)

# shape file (.shp)
# add SUB column to .shp file
yadkin_subs_shp <- yadkin_subs_shp_raw %>% 
  mutate(SUB = Subbasin)


# ---- 3.1 condense categories and reset sub_id ----

# reclassify to simple categories
yadkin_lu_reclass_data <- yadkin_lu_data
yadkin_lu_reclass_data$DESCRIPTION[yadkin_lu_reclass_data$DESCRIPTION == "lowland hardwood"] <- "forested"
yadkin_lu_reclass_data$DESCRIPTION[yadkin_lu_reclass_data$DESCRIPTION == "upland hardwood"] <- "forested"
yadkin_lu_reclass_data$DESCRIPTION[yadkin_lu_reclass_data$DESCRIPTION == "mixed forest"] <- "forested"
yadkin_lu_reclass_data$DESCRIPTION[yadkin_lu_reclass_data$DESCRIPTION == "pine"] <- "forested"
yadkin_lu_reclass_data$DESCRIPTION[yadkin_lu_reclass_data$DESCRIPTION == "wetland"] <- "wetlands_and_water"
yadkin_lu_reclass_data$DESCRIPTION[yadkin_lu_reclass_data$DESCRIPTION == "water"] <- "wetlands_and_water"

sub_lu_reclass_data=sub_lu_data
sub_lu_reclass_data$DESCRIPTION[sub_lu_reclass_data$DESCRIPTION == "lowland hardwood"] <- "forested"
sub_lu_reclass_data$DESCRIPTION[sub_lu_reclass_data$DESCRIPTION == "upland hardwood"] <- "forested"
sub_lu_reclass_data$DESCRIPTION[sub_lu_reclass_data$DESCRIPTION == "mixed forest"] <- "forested"
sub_lu_reclass_data$DESCRIPTION[sub_lu_reclass_data$DESCRIPTION == "pine"] <- "forested"
sub_lu_reclass_data$DESCRIPTION[sub_lu_reclass_data$DESCRIPTION == "wetland"] <- "wetlands_and_water"
sub_lu_reclass_data$DESCRIPTION[sub_lu_reclass_data$DESCRIPTION == "water"] <- "wetlands_and_water"

# reset sub_id in sub_lu_reclass_data (for % diff calc)
sub_lu_reclass_data <- sub_lu_reclass_data %>% 
  select(SUB, AREA_PERC, DESCRIPTION, dataset) %>%
  mutate(sub_id = paste0("subid_", SUB, "_", DESCRIPTION)) %>%
  group_by(SUB, DESCRIPTION, dataset, sub_id) %>%
  summarize(AREA_PERC = sum(AREA_PERC))

# summarize baseline % landuse
yadkin_lu_reclass_baseline_summary <- yadkin_lu_reclass_data %>% 
  filter(dataset == "baseline") %>% 
  group_by(DESCRIPTION) %>%
  summarize(sum_area_perc = sum(AREA_PERC))

# summarize baseline % landuse for each subbasin
sub_lu_reclass_baseline_summary <- sub_lu_reclass_data %>% 
  filter(dataset == "baseline") %>%
  mutate(baseline_perc = AREA_PERC) %>%
  ungroup() %>%
  select(-AREA_PERC, -dataset)

# summarize projections % landuse for each subbasin
sub_lu_reclass_projection_summary <- sub_lu_reclass_data %>% 
  filter(dataset != "baseline") %>% 
  left_join(contributing_areas, by = "SUB") %>%
  group_by(DESCRIPTION, SUB, AREAkm2) %>%
  summarize(projection_perc = round(mean(AREA_PERC), 3)) %>%
  ungroup() %>%
  mutate(sub_id = paste0("subid_", SUB, "_", DESCRIPTION)) %>%
  select(-DESCRIPTION, -SUB)
  

# ---- 3.2 barplot subbasin data for major land uses (figure s12) ----

# join baseline and projection dataset for bar plot
sub_lu_reclass_data_all <- left_join(sub_lu_reclass_baseline_summary, sub_lu_reclass_projection_summary, by = "sub_id") %>%
  select(SUB, sub_id, AREAkm2, DESCRIPTION, baseline_perc, projection_perc) %>%
  gather(key = dataset, value = perc, baseline_perc:projection_perc) %>%
  filter(DESCRIPTION != "wetlands_and_water") %>% # some small changes but basically the same
  arrange(AREAkm2)

# reorder factors
sub_lu_reclass_data_all$SUB <- factor(sub_lu_reclass_data_all$SUB, levels = contributing_areas$SUB[order(contributing_areas$AREAkm2)])

# plot
cairo_pdf(paste0(figure_path, "figure_s12.pdf"),width=11,height=8.5, pointsize=20)
ggplot(sub_lu_reclass_data_all, aes(x = as.factor(SUB), y = perc, fill = dataset)) +
  geom_col(position = "dodge") +
  facet_wrap(~DESCRIPTION) +
  xlab("Subbasin ID") +
  ylab("Area (%)") +
  ylim(0, 100) +
  scale_fill_manual(values=c("grey75", "black")) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_blank(), text = element_text(size = 14),
        axis.text.x=element_text(angle=90, hjust=1,vjust=0.5))
dev.off()


# ---- 4.1 land use % calculations for paper ----

yadkin_lu_data_sel <- yadkin_lu_data %>% 
  filter(dataset == "baseline")

# forested categories
0.83 + 12.56 + 16.076 + 35.608 # = 65.07%

# 1992 lu for subbasin 15
baseline_lu_sub_15 <- baseline_lu_sub %>%
  filter(SUB == 15) %>%
  left_join(yadkin_lu_descriptions, by = "VALUE")

# forested
12.09 + 7.41 + 50.1669 + 0.273 # = 70%

# 1992 lu for subbasin 8
baseline_lu_sub_8 <- baseline_lu_sub %>%
  filter(SUB == 8) %>%
  left_join(yadkin_lu_descriptions, by = "VALUE")
# 34% urban

# 1992 lu for subbasin 24
baseline_lu_sub_24 <- baseline_lu_sub %>%
  filter(SUB == 24) %>%
  left_join(yadkin_lu_descriptions, by = "VALUE")

# forested sub 24
20.5 + 10.34 + 10.15 + 0.42 # = 41.4%


