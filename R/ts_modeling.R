library(pacman)

p_load(fpp3, ggplot2, ggthemes)

df <- read_csv("results/aggregated/emotions/full_with_emotions_final.csv")

theme_set(theme_bw())

aggregated_df <- df %>% 
  group_by(date(created_utc), source) %>% 
  summarize(across(joy:anticipation, ~ mean(.x, na.rm = TRUE))) %>% 
  rename(date = `date(created_utc)`)

aggregated_ts <- aggregated_df %>% 
  as_tsibble(key = source, index = date) %>% 
  fill_gaps()

gg_season(aggregated_ts, joy)

aggregated_ts %>% 
  filter_index(. ~ "2021-12-31") %>% 
  gg_season(sadness) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b")

fit <- model(filter(aggregated_ts, source == "YouTube"), 
      'joy' = STL(joy ~ trend() + season(), robust = T),
      'trust' = STL(trust ~ trend() + season(), robust = T),
      'fear' = STL(fear ~ trend() + season(), robust = T),
      'surprise' = STL(sadness ~ trend() + season(), robust = T),
      'disgust' = STL(disgust ~ trend() + season(), robust = T),
      'sadness' = STL(sadness ~ trend() + season(), robust = T),
      'anger' = STL(anger ~ trend() + season(), robust = T),
      'anticipation' = STL(anticipation ~ trend() + season(), robust = T)
      )

autoplot(components(fit[2,]))
