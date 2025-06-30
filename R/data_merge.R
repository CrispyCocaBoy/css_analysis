library(pacman)

p_load(tidyverse, ggplot2, lubridate, ggthemes)

theme_set(theme_bw())

youtube <- read_csv("data/comments_youtube_filtered.csv")

reddit <- read_csv("results/aggregated/reddit_cleaned.csv")

reddit_merge <- reddit %>% 
  mutate(source = 'Reddit') %>% 
  select(post_id, text, author, created_utc, source)

youtube_merge <- youtube %>% 
  mutate(source = 'YouTube') %>% 
  select(comment_id, text, author, published_at, source)

names(youtube_merge) <- c('post_id', 'text', 'author', 'created_utc', 'source')

merged_final <- rbind(reddit_merge, youtube_merge)

# write_csv(merged_final, 'data/final_dataset.csv')
