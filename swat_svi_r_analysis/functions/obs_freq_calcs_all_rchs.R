# obs_freq_calcs_all_rchs function

# purpose: select observations for high flow frequency analysis (all reaches)
# last updated: 20170912
# author: sheila saia
# contact: ssaia [at] ncsu [dot] edu

# observation for all reaches in .rch file
obs_freq_calcs_all_rchs <- function(rch_data, span_days) {
  # rch_data is formatted using reformat_rch_file() function
  # also required to load obs_hiflow_freq_calcs_one_rch() function
  # span_days is equal to the desired number of days being averaged for frequency analysis (e.g., 7 for 7-day flow analysis)
  # tidyverse and smwrBase packages are required to run this function
  
  # calculate number of reaches for for loop
  num_rchs <- length(unique(rch_data$RCH))
  
  # make data frame for all outputs
  obs_df_all_rchs <- data.frame(RCH = as.integer(),
                                YR = as.integer(),
                                obs_return_period_yr = as.numeric(),
                                obs_max_flow_cms_adj = as.numeric(),
                                obs_max_flow_log_cms_adj = as.numeric(),
                                data_type = as.character())
  for (i in 1:num_rchs) {
    # select only one reach
    sel_rch_data <- rch_data %>% 
      filter(RCH == i)
    
    # fill data frame
    obs_df_all_temp <- obs_hiflow_freq_calcs_one_rch(sel_rch_data, span_days)
    
    # append to final output
    obs_df_all_rchs <- bind_rows(obs_df_all_rchs, obs_df_all_temp)
  }

  return(obs_df_all_rchs)
}