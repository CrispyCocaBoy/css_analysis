library(pacman)

p_load(tidyverse, ggplot2, lubridate, ggthemes)

theme_set(theme_bw())

df <- read_csv("results/aggregated/emotions/reddit_with_emotions_checkpoint_15000.csv")

# Plot 1 week from event --------------------------------------------------

interval <- interval(as.Date("2018-02-14"), as.Date("2018-02-22"))

first_wk <- df %>% 
  filter(created_utc %within% interval)

aggregated_first_wk <- first_wk %>% 
  group_by(date(created_utc)) %>% 
  summarize(across(joy:disgust, ~ mean(.x, na.rm = TRUE))) %>% 
  pivot_longer(!`date(created_utc)`, names_to = 'emotion', values_to = 'value')

ggplot(aggregated_first_wk, aes(x = `date(created_utc)`, y = value, color = emotion)) +
  geom_line() +
  labs(x = 'Date', y = 'Average Emotion Level', title = 'Emotion Level one Week from Event (Reddit)') +
  theme(plot.title = element_text(hjust = .5))

# We can see spike in joy and decrease in disgust when "march for our lives" event is announced on Feb 19 2018
# manifestation to end gun violence


# 1 Month from Event ------------------------------------------------------

interval <- interval(as.Date("2018-02-14"), as.Date("2018-03-15"))

first_wk <- df %>% 
  filter(created_utc %within% interval)

aggregated_first_wk <- first_wk %>% 
  group_by(date(created_utc)) %>% 
  summarize(across(joy:disgust, ~ mean(.x, na.rm = TRUE))) %>% 
  pivot_longer(!`date(created_utc)`, names_to = 'emotion', values_to = 'value')

ggplot(aggregated_first_wk, aes(x = `date(created_utc)`, y = value, color = emotion)) +
  geom_line() +
  labs(x = 'Date', y = 'Average Emotion Level', title = 'Emotion Level one Month from Event (Reddit)') +
  theme(plot.title = element_text(hjust = .5))

# Student national walkout on the 14th march and change of trend in the emotions

# 1 Year from Event -------------------------------------------------------

interval <- interval(as.Date("2018-02-14"), as.Date("2019-02-15"))

first_wk <- df %>% 
  filter(created_utc %within% interval)

aggregated_first_wk <- first_wk %>% 
  group_by(date(created_utc)) %>% 
  summarize(across(joy:disgust, ~ mean(.x, na.rm = TRUE))) %>% 
  pivot_longer(!`date(created_utc)`, names_to = 'emotion', values_to = 'value')

ggplot(aggregated_first_wk, aes(x = `date(created_utc)`, y = value, color = emotion)) +
  geom_point() +
  geom_line() +
  labs(x = 'Date', y = 'Average Emotion Level', title = 'Emotion Level one Year from Event') +
  theme(plot.title = element_text(hjust = .5))

# 9 August people surprised by video interrogation of Cruz


# Overall Data ------------------------------------------------------------


aggregated_first_wk <- df %>%
  mutate(created_date = as.Date(created_utc)) %>%
  group_by(created_date) %>%
  summarize(across(joy:disgust, ~ mean(.x, na.rm = TRUE))) %>%
  pivot_longer(!created_date, names_to = 'emotion', values_to = 'value') %>%
  drop_na()

ggplot(aggregated_first_wk, aes(x = created_date, y = value, color = emotion)) +
  geom_point() +
  geom_line() +
  facet_wrap(~ year(created_date), scales = 'free_x') +  # remove `space`
  scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  labs(x = 'Month', y = 'Average Emotion Level', title = 'Emotion Level from Event to 2025 (Reddit)') +
  theme(
    plot.title = element_text(hjust = .5),
    axis.text.x = element_text(angle = 45, hjust = 1),
    strip.text = element_text(size = 12)
  )
