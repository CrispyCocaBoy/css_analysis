library(pacman)

p_load(fpp3, ggplot2, ggthemes, readr)

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

fit <- model(filter(aggregated_ts, source == "YouTube"), 
             'sadness' = STL(sadness ~ trend() + season(), robust = T)
)
autoplot(components(fit))

fit <- model(filter(aggregated_ts, source == "YouTube"), 
             'joy' = STL(joy ~ trend() + season(), robust = T)
)
autoplot(components(fit))

fit <- model(filter(aggregated_ts, source == "YouTube"), 
             'trust' = STL(trust ~ trend() + season(), robust = T)
)
autoplot(components(fit))

fit <- model(filter(aggregated_ts, source == "YouTube"), 
             'fear' = STL(fear ~ trend() + season(), robust = T)
)
autoplot(components(fit))

fit <- model(filter(aggregated_ts, source == "YouTube"), 
             'surprise' = STL(surprise ~ trend() + season(), robust = T)
)
autoplot(components(fit))

fit <- model(filter(aggregated_ts, source == "YouTube"), 
             'disgust' = STL(disgust ~ trend() + season(), robust = T)
)
autoplot(components(fit))

fit <- model(filter(aggregated_ts, source == "YouTube"), 
             'anger' = STL(anger ~ trend() + season(), robust = T)
)
autoplot(components(fit))

fit <- model(filter(aggregated_ts, source == "YouTube"), 
             'anticipation' = STL(anticipation ~ trend() + season(), robust = T)
)
autoplot(components(fit))
