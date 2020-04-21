library(tidyverse)

goodreads = read_csv('goodreads_library_export.csv')

goodreads

leaderboard = read_csv('leaderboard.csv')

leaderboard

newbooks = goodreads %>%
  filter(`Exclusive Shelf` == 'read') %>% 
  unite('author', Author, `Additional Authors`, sep = ', ', na.rm = TRUE) %>%
  select(bookid = `Book Id`, title = Title, author, myrating = `My Rating`, avgrating = `Average Rating`, dateread = `Date Read`, shelves = Bookshelves) %>%
  mutate(author = str_squish(author)) %>% 
  anti_join(leaderboard, by = 'bookid') %>% 
  mutate(
    ratings = 0,
    elo = 1200
  )

newbooks

leaderboard = bind_rows(leaderboard, newbooks)

leaderboard = leaderboard %>% left_join(
  goodreads %>% select(bookid = `Book Id`, shelves = Bookshelves),
  by = 'bookid'
) %>% 
  mutate(shelves.x = shelves.y) %>% 
  rename(shelves = shelves.x) %>% 
  select(-shelves.y)

leaderboard %>% write_csv('leaderboard.csv')
