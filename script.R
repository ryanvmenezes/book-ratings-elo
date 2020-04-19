suppressMessages(library(tidyverse))

while (TRUE) {
  # todo: update script that
  # 1. finds new books and seeds them with ratings = 0 and elo = 1200
  # 2. updates shelves for all read books
  
  books = suppressMessages(read_csv('leaderboard.csv'))
  
  prev.results = read_rds('results.rds')
  
  books.by.shelf = books %>%
    select(bookid, title, shelves) %>% 
    separate_rows(shelves, sep = ', ')
  
  no.shared.shelves = TRUE
  
  # pick a book that hasn't been rated much before
  book1 = books %>% sample_n(1, weight = 1 - (ratings / sum(ratings)))
  
  book1
  
  # find its complement
  book2 = book1 %>% 
    select(shelves) %>% 
    separate_rows(shelves, sep = ', ')
  
  # take out non-fiction unless it's the only shelf for the book
  if (nrow(book2) > 1) {
    book2 = book2 %>% 
      filter(!str_detect(shelves, 'non-fiction'))
  }
  
  book2 = book2 %>% 
    left_join(books.by.shelf, by = 'shelves') %>% 
    distinct(bookid, title) %>% 
    anti_join(book1, by = c('bookid', 'title')) %>%
    sample_n(1)
  
  books
    
  matchup = books %>% filter(bookid %in% c(book1$bookid, book2$bookid))
  
  print(matchup %>% select(bookid, title, author))
  
  valid.input = FALSE
  
  while (!valid.input) {
    winnerid = readline(prompt="Winner: (1) (2) or (3 - tie): ")
    
    if (winnerid == 'break') { break }
    
    winnerid = suppressWarnings(as.integer(winnerid))
    
    if (winnerid %in% c(1,2,3)) { valid.input = TRUE }
  }
  
  if (winnerid == 'break') { break }
  
  result = matchup %>%
    mutate(
      matchup.index = 1:2,
      winner = winnerid,
      win = case_when(
        winnerid == 3 ~ 0.5,
        TRUE ~ as.double(matchup.index == winner)
      ),
      exp.prob = 0.0,
      new.ratings = ratings + 1,
      new.elo = 0.0
    )
  
  r1 = result$elo[1]
  r2 = result$elo[2]
  
  result$exp.prob[1] = 1 / (1 + 10^((r2 - r1) / 400))
  result$exp.prob[2] = 1 / (1 + 10^((r1 - r2) / 400))
  
  result$new.elo[1] = r1 + 32*(result$win[1] - result$exp.prob[1])
  result$new.elo[2] = r1 + 32*(result$win[2] - result$exp.prob[2])
  
  books = books %>% 
    left_join(
      result %>% 
        select(bookid, title, ratings = new.ratings, elo = new.elo),
      by = c('bookid', 'title'),
      suffix = c('.old', '.new')
    ) %>% 
    mutate(
      ratings = coalesce(ratings.new, ratings.old),
      elo = coalesce(elo.new, elo.old)
    ) %>% 
    select(-matches('\\.old|\\.new')) %>% 
    arrange(-elo)
  
  books %>% write_csv('leaderboard.csv')
  
  prev.results = prev.results %>% 
    bind_rows(
      result %>% 
        mutate(matchup.id = max(prev.results$matchup.id) + 1)
    )
  
  prev.results %>% write_rds('results.rds', compress = 'gz')
}
