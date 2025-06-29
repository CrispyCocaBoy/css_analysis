library(pacman)
p_load(tidyverse, ggplot2, ggthemes, scales, psych)

df <- read_csv("results/aggregated/emotions/full_with_emotions_final.csv")

theme_set(theme_bw())

# Plot 1 week from event --------------------------------------------------

interval <- interval(as.Date("2018-02-14"), as.Date("2018-02-22"))

first_wk <- df %>% 
  filter(created_utc %within% interval)

aggregated_first_wk <- first_wk %>% 
  group_by(date(created_utc), source) %>% 
  summarize(across(joy:anticipation, ~ mean(.x, na.rm = TRUE))) %>% 
  pivot_longer(!c(`date(created_utc)`, source), names_to = 'emotion', values_to = 'value')

ggplot(aggregated_first_wk, aes(x = `date(created_utc)`, y = value, color = emotion)) +
  geom_line() +
  facet_grid(source ~ .) +
  labs(x = 'Date', y = 'Average Emotion Level', title = 'Emotion Level one Week from Event') +
  theme(plot.title = element_text(hjust = .5))

# 1 Month from Event ------------------------------------------------------

interval <- interval(as.Date("2018-02-14"), as.Date("2018-03-15"))

first_wk <- df %>% 
  filter(created_utc %within% interval)

aggregated_first_wk <- first_wk %>% 
  group_by(date(created_utc), source) %>% 
  summarize(across(joy:anticipation, ~ mean(.x, na.rm = TRUE))) %>% 
  pivot_longer(!c(`date(created_utc)`, source), names_to = 'emotion', values_to = 'value')

ggplot(aggregated_first_wk, aes(x = `date(created_utc)`, y = value, color = emotion)) +
  geom_line() +
  facet_grid(source ~ .) +
  labs(x = 'Date', y = 'Average Emotion Level', title = 'Emotion Level one Month from Event') +
  theme(plot.title = element_text(hjust = .5))

# 1 Year from Event -------------------------------------------------------

interval <- interval(as.Date("2018-02-14"), as.Date("2019-02-15"))

first_wk <- df %>% 
  filter(created_utc %within% interval)

aggregated_first_wk <- first_wk %>% 
  group_by(date(created_utc), source) %>% 
  summarize(across(joy:anticipation, ~ mean(.x, na.rm = TRUE))) %>% 
  pivot_longer(!c(`date(created_utc)`, source), names_to = 'emotion', values_to = 'value')

ggplot(aggregated_first_wk, aes(x = `date(created_utc)`, y = value, color = emotion)) +
  geom_line() +
  facet_grid(source ~ ., scales = 'free_y') +
  labs(x = 'Date', y = 'Average Emotion Level', title = 'Emotion Level one Year from Event') +
  theme(plot.title = element_text(hjust = .5))

# Overall Data ------------------------------------------------------------
aggregated_first_wk <- df %>% 
  group_by(date(created_utc), source) %>% 
  summarize(across(joy:anticipation, ~ mean(.x, na.rm = TRUE))) %>% 
  pivot_longer(!c(`date(created_utc)`, source), names_to = 'emotion', values_to = 'value')

ggplot(aggregated_first_wk, aes(x = `date(created_utc)`, y = value, color = emotion)) +
  geom_point(alpha = 0.5) +
  geom_line(alpha = 0.5) +
  facet_grid(source ~ .) +
  scale_x_date(date_labels = '%b-%y', date_breaks = "2 months", limits = c(as.Date("2018-02-01"), as.Date("2025-07-01"))) +
  labs(x = 'Month', y = 'Average Emotion Level', title = 'Emotion Level from Event to 2025') +
  theme(
    plot.title = element_text(hjust = .5),
    axis.text.x = element_text(angle = 90, hjust = 1),
    strip.text = element_text(size = 12)
  )


# Descriptive Analysis ----------------------------------------------------

describeBy(df, 'source')
# on reddit Surprise has the highest variability
# on YT that variability is almost matched by sadness

GGally::ggpairs(df[which(df$source == "Reddit"), 6:ncol(df)], title = 'Emotions from Reddit (Entire Sample)')
GGally::ggpairs(df[which(df$source == "YouTube"), 6:ncol(df)], title = 'Emotions from YouTube (Entire Sample)')

