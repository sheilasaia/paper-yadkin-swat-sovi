# model_freq_calcs_all_rchs function

# purpose: generate log-Pearson type III model curve for high flow frequency analysis (all reaches)
# last updated: 20170912
# author: sheila saia
# contact: ssaia [at] ncsu [dot] edu

model_freq_calcs_all_rchs <- function(obs_freq_calcs_all_rchs_df, kn_table, model_p_list, general_cskew) {
  # obs_freq_calcs_all_rchs_df is formatted using obs_freq_calcs_all_rchs()
  # model_p_list is a list of desired probabilities of exceedance
  # tidyverse package is required to run this function
  
  # calculate number of subbasins for for loop
  num_rchs <- length(unique(obs_freq_calcs_all_rchs_df$RCH))
  
  # make dataframe for all outputs
  model_df_all_rchs <- data.frame(RCH = as.integer(),
                               model_return_period_yr = as.numeric(),
                               model_flow_cms = as.numeric(),
                               model_flow_log_cms = as.numeric(),
                               data_type = as.character())
  
  for (i in 1:num_rchs) {
    sel_rch_data <- obs_freq_calcs_all_rchs_df %>% 
      filter(RCH == i)
    
    # fill data frame
    model_df_all_temp <- model_hiflow_freq_calcs_one_rch(sel_rch_data, kn_table, model_p_list)
    
    # append temp data frame to final one
    model_df_all_rchs <- bind_rows(model_df_all_rchs, model_df_all_temp)
  }
  
  return(model_df_all_rchs)
}

