library(pacman)

p_load(tidyverse, ggplot2)

reddit_results <- read_csv("results/aggregated/reddit_results.csv")

# Ensure everything has been read as the correct data format, everything looks OK
str(reddit_results)

min(reddit_results$created_utc) # oldest date is before the event of interest, comments before 2018-02-14 will be dropped
max(reddit_results$created_utc)

cleaned_df <- reddit_results %>% 
  filter(created_utc >= "2018-02-14") %>% 
  select(-c(permalink, reference))

# write_csv(cleaned_df, file = 'results/aggregated/reddit_cleaned.csv')
