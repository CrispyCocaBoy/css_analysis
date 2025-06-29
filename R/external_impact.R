library(pacman)

p_load(tidyverse, ggplot2, ggsci)
theme_set(theme_bw())

# Analyze the external impact of events seeing how emotions changed from one week before the event to the next week
# Check which emotions exhibit statistically significant difference before vs after

# 17 Feb

# 1. extract data of interest in the interval

df <- read_csv("results/aggregated/emotions/full_with_emotions_final.csv")

event <- as.Date("2018-02-21")
lower <- event - 7
upper <- event + 7
interval_interest <- interval(lower, upper)

emotions <- c("joy", "trust", "fear", "surprise", "sadness", "disgust", "anger", "anticipation")

filtered_df <- df %>% 
  filter(created_utc %within% interval_interest) %>% 
  mutate(when = ifelse(created_utc %within% interval(lower, event), "before", "after"))

(n_before <- nrow(filtered_df[which(filtered_df$when == "before"),]))
(n_after <- nrow(filtered_df[which(filtered_df$when == "after"),]))

wilcox.test(joy ~ when, data = filtered_df)
wilcox.test(trust ~ when, data = filtered_df)
wilcox.test(fear ~ when, data = filtered_df)
wilcox.test(surprise ~ when, data = filtered_df)
wilcox.test(sadness ~ when, data = filtered_df)
wilcox.test(disgust ~ when, data = filtered_df)
wilcox.test(anger ~ when, data = filtered_df)
wilcox.test(anticipation ~ when, data = filtered_df)

test_emotion_shift <- function(date_interest, window, alpha, plot) {
  event <- as.Date(date_interest)
  lower <- event - window
  upper <- event + window
  interval_interest <- interval(lower, upper)
  
  emotions <- c("joy", "trust", "fear", "surprise", "sadness", "disgust", "anger", "anticipation")
  
  filtered_df <- df %>% 
    filter(created_utc %within% interval_interest) %>% 
    mutate(when = ifelse(created_utc %within% interval(lower, event), "before", "after"))
  
  (n_before <- nrow(filtered_df[which(filtered_df$when == "before"),]))
  (n_after <- nrow(filtered_df[which(filtered_df$when == "after"),]))
  
  
  
  p_vals_test <- c()
  if (between(nrow(filtered_df), 3, 5000)) {
    p_vals_test <- append(p_vals_test, shapiro.test(filtered_df$joy)$p.value)
    p_vals_test <- append(p_vals_test, shapiro.test(filtered_df$trust)$p.value)
    p_vals_test <- append(p_vals_test, shapiro.test(filtered_df$fear)$p.value)
    p_vals_test <- append(p_vals_test, shapiro.test(filtered_df$surprise)$p.value)
    p_vals_test <- append(p_vals_test, shapiro.test(filtered_df$sadness)$p.value)
    p_vals_test <- append(p_vals_test, shapiro.test(filtered_df$disgust)$p.value)
    p_vals_test <- append(p_vals_test, shapiro.test(filtered_df$anger)$p.value)
    p_vals_test <- append(p_vals_test, shapiro.test(filtered_df$anticipation)$p.value)
  }
  
  
  if (any(p_vals_test < alpha) | is_empty(p_vals_test)) {
    joy_res <- wilcox.test(joy ~ when, data = filtered_df)
    trust_res <- wilcox.test(trust ~ when, data = filtered_df)
    fear_res <- wilcox.test(fear ~ when, data = filtered_df)
    surprise_res <- wilcox.test(surprise ~ when, data = filtered_df)
    sadness_res <- wilcox.test(sadness ~ when, data = filtered_df)
    disgust_res <- wilcox.test(disgust ~ when, data = filtered_df)
    anger_res <- wilcox.test(anger ~ when, data = filtered_df)
    anticipation_res <- wilcox.test(anticipation ~ when, data = filtered_df)
  } else {
    joy_res <- t.test(joy ~ when, data = filtered_df)
    trust_res <- t.test(trust ~ when, data = filtered_df)
    fear_res <- t.test(fear ~ when, data = filtered_df)
    surprise_res <- t.test(surprise ~ when, data = filtered_df)
    sadness_res <- t.test(sadness ~ when, data = filtered_df)
    disgust_res <- t.test(disgust ~ when, data = filtered_df)
    anger_res <- t.test(anger ~ when, data = filtered_df)
    anticipation_res <- t.test(anticipation ~ when, data = filtered_df)
  }
  
  
  p_vals <- c(joy_res$p.value, trust_res$p.value, fear_res$p.value, surprise_res$p.value, sadness_res$p.value, disgust_res$p.value, anger_res$p.value, anticipation_res$p.value)
  
  print(paste("Using: sample size before: ", n_before, "sample size after: ", n_after))
  
  idx <- 1
  
  for (test in p_vals) {
    if (test < alpha) {
      print(emotions[idx])
      idx <-  idx + 1
    } else {
      idx <-  idx + 1
    }
  }
  
  if (plot == TRUE) {
    first_wk <- df %>% 
      filter(created_utc %within% interval_interest)
    
    aggregated_first_wk <- first_wk %>% 
      group_by(date(created_utc), source) %>% 
      summarize(across(joy:anticipation, ~ mean(.x, na.rm = TRUE))) %>% 
      pivot_longer(!c(`date(created_utc)`, source), names_to = 'emotion', values_to = 'value') %>% 
      mutate(when = ifelse(`date(created_utc)` %within% interval(lower, event), "before", "after"),
             when = as.factor(when),
             condition = paste(when, emotion))
    
    
    ggplot(aggregated_first_wk, aes(x = `date(created_utc)`, y = value, color = emotion)) +
      geom_line(alpha = 0.5) +
      geom_smooth(aes(group = condition), method = 'lm', se = F, alpha = 0.9) +
      geom_vline(xintercept = as.Date(date_interest), color = "red", linetype = 'dashed') +
      scale_x_date(date_labels = '%b-%d', date_breaks = "1 day") +
      facet_grid(source ~ .) +
      labs(x = 'Date', y = 'Average Emotion Level', title = paste('Emotion Level Change from Target Event (', date_interest, ')')) +
      theme(plot.title = element_text(hjust = .5)) +
      scale_color_nejm()  
    }
  
}

test_emotion_shift(date_interest = "2018-03-09", window = 7, alpha = 0.05, plot = F)
test_emotion_shift(date_interest = "2018-03-14", window = 7, alpha = 0.05, plot = T)
test_emotion_shift(date_interest = "2018-03-24", window = 7, alpha = 0.05, plot = T)
test_emotion_shift(date_interest = "2018-04-03", window = 7, alpha = 0.05, plot = T)
test_emotion_shift(date_interest = "2018-06-03", window = 7, alpha = 0.05, plot = T)
test_emotion_shift(date_interest = "2018-06-04", window = 7, alpha = 0.05, plot = T)
test_emotion_shift(date_interest = "2018-06-26", window = 7, alpha = 0.05, plot = T)
test_emotion_shift(date_interest = "2018-08-09", window = 7, alpha = 0.05, plot = T)

test_emotion_shift(date_interest = "2022-11-02", window = 7, alpha = 0.05, plot = T)

# Anniversaries -----------------------------------------------------------

test_emotion_shift(date_interest = "2019-02-14", window = 7, alpha = 0.05, plot = T)
test_emotion_shift(date_interest = "2020-02-14", window = 7, alpha = 0.05, plot = T)
test_emotion_shift(date_interest = "2021-02-14", window = 7, alpha = 0.05, plot = T)
test_emotion_shift(date_interest = "2022-02-14", window = 7, alpha = 0.05, plot = T)
test_emotion_shift(date_interest = "2023-02-14", window = 7, alpha = 0.05, plot = T)
test_emotion_shift(date_interest = "2024-02-14", window = 7, alpha = 0.05, plot = T)
test_emotion_shift(date_interest = "2025-02-14", window = 7, alpha = 0.05, plot = T)
