# obs_freq_calcs_one_rch function

# purpose: select observations for high flow frequency analysis (one reach)
# last updated: 20170912
# author: sheila saia
# contact: ssaia [at] ncsu [dot] edu

# define function
obs_hiflow_freq_calcs_one_rch <- function(sel_rch_data, span_days) { 
  # sel_rch_data is data frame for one reach
  # (see obs_freq_calcs_all_rchs() function for more info on sel_rch_data)
  # span_days is equal to the desired number of days being averaged for frequency analysis (e.g., 7 for 7-day flow analysis)
  # tidyverse and smwrBase packages are required to run this function
  
  # calculate number of years
  num_yrs <- length(unique(sel_rch_data$YR))
  
  # find min, sort descending, and adjust
  obs_df_temp <- sel_rch_data %>% 
    mutate(FLOW_OUTcms_avg = smwrBase::movingAve(FLOW_OUTcms, span = span_days, pos = "end")) %>%
    na.omit() %>% # omit first few NA rows from movingAve()
    group_by(RCH, YR) %>% 
    summarise(obs_max_flow_cms = max(FLOW_OUTcms_avg)) %>%
    arrange(RCH, desc(obs_max_flow_cms)) %>%
    mutate(obs_max_flow_cms_adj = obs_max_flow_cms * 1.13, # adjust using standard window shift
           obs_max_flow_log_cms_adj = log(obs_max_flow_cms_adj))
  
  # rank data
  obs_df_temp$obs_rank_num <- seq(1, num_yrs, 1)
  
  # define return period
  obs_df_temp$obs_return_period_yr <- (num_yrs + 1) / obs_df_temp$obs_rank_num
  
  # select only necessary fields
  obs_df <- obs_df_temp %>% select(RCH,
                                   YR,
                                   obs_return_period_yr,
                                   obs_max_flow_cms_adj,
                                   obs_max_flow_log_cms_adj) %>%
    mutate(data_type = rep("obs", num_yrs))
  
  # return
  return(obs_df)
}