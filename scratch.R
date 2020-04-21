tmpbooks = books %>% select(bookid, title, ratings)

tmpbooks %>% 
  mutate(
    weight = ((1 - (ratings / sum(ratings)))*10)^3
  ) %>% 
  arrange(-ratings)

tmpsamples = map_dfr(1:100000, ~tmpbooks %>% sample_n(1, weight = ((1 - (ratings / sum(ratings)))*10)^3))

tmpsamples

tmpsamples %>%
  count(bookid, title, ratings) %>% 
  arrange(-ratings) %>% 
  head()

tmpsamples %>%
  count(bookid, title, ratings) %>% 
  ggplot(aes(`ratings`, `n`)) +
  geom_point() +
  geom_smooth(method = 'lm')
