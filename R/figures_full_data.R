library(pacman)
p_load(tidyverse, ggplot2, ggthemes, scales, psych, lubridate, waffle, ggsci, Hmisc)

df <- read_csv("results/aggregated/emotions/full_with_emotions_final.csv")

theme_set(theme_bw())

# Plot 1 week from event --------------------------------------------------

interval <- lubridate::interval(as.Date("2018-02-14"), as.Date("2018-02-22"))

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
  theme(plot.title = element_text(hjust = .5)) +
  scale_color_nejm()  


# 1 Month from Event ------------------------------------------------------

interval <- lubridate::interval(as.Date("2018-02-14"), as.Date("2018-03-15"))

first_wk <- df %>% 
  filter(created_utc %within% interval)

aggregated_first_wk <- first_wk %>% 
  group_by(date(created_utc), source) %>% 
  summarize(across(joy:anticipation, ~ mean(.x, na.rm = TRUE))) %>% 
  pivot_longer(!c(`date(created_utc)`, source), names_to = 'emotion', values_to = 'value')

ggplot(aggregated_first_wk, aes(x = `date(created_utc)`, y = value, color = emotion)) +
  geom_line(linewidth = 1) +
  facet_grid(source ~ .) +
  labs(x = 'Date', y = 'Average Emotion Level', title = 'Emotion Level one Month from Event') +
  scale_x_date(date_labels = "%b-%d", date_breaks = "5 days") +
  theme(plot.title = element_text(hjust = .5)) +
  scale_color_nejm()  


# 1 Year from Event -------------------------------------------------------

interval <- lubridate::interval(as.Date("2018-02-14"), as.Date("2019-02-15"))

first_wk <- df %>% 
  filter(created_utc %within% interval)

aggregated_first_wk <- first_wk %>% 
  group_by(date(created_utc), source) %>% 
  summarize(across(joy:anticipation, ~ mean(.x, na.rm = TRUE))) %>% 
  pivot_longer(!c(`date(created_utc)`, source), names_to = 'emotion', values_to = 'value')

ggplot(aggregated_first_wk, aes(x = `date(created_utc)`, y = value, color = emotion)) +
  geom_line(linewidth = 0.8, alpha = 0.7) +
  facet_grid(source ~ ., scale = 'free_y') +
  labs(x = 'Date', y = 'Average Emotion Level', title = 'Emotion Level one Year from Event') +
  scale_x_date(date_labels = "%b-%y", date_breaks = "1 month") +
  theme(plot.title = element_text(hjust = .5)) +
  scale_color_nejm()  

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
  ) +
  scale_color_nejm()  


# Aggregate to get mean emotion per platform
emotion_summary <- df %>%
  group_by(source) %>%
  dplyr::summarize(
    dplyr::across(joy:anticipation, ~ mean(.x, na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  pivot_longer(-source, names_to = "emotion", values_to = "mean_value")

# Barplot
ggplot(emotion_summary, aes(x = reorder(emotion, -mean_value), y = mean_value, fill = emotion)) +
  geom_col() +
  facet_wrap(~ source) +
  scale_fill_nejm() +
  labs(
    x = "Emotion",
    y = "Average Level",
    title = "Average Emotion Levels by Platform"
  ) +
  theme(
    legend.position = "none",
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  scale_color_nejm()  

ggplot(emotion_summary, aes(x = emotion, y = source, size = mean_value, color = emotion)) +
  geom_point(alpha = 0.7) +
  scale_size_area(max_size = 15) +
  scale_color_nejm() +
  labs(title = "Emotions Bubble Plot", x = "Emotion", y = "Platform") +
  theme(legend.position = "right")

# Descriptive Analysis ----------------------------------------------------

describeBy(df, 'source')
# on reddit Surprise has the highest variability
# on YT that variability is almost matched by sadness

GGally::ggpairs(df[which(df$source == "Reddit"), 6:ncol(df)], title = 'Emotions from Reddit (Entire Sample)')
print(GGally::ggpairs(df[which(df$source == "YouTube"), 6:ncol(df)], title = 'Emotions from YouTube (Entire Sample)'))

cor(df[, 6:ncol(df)], use = 'complete.obs')

rcorr(as.matrix(df[, 6:ncol(df)]), type = "spearman")
