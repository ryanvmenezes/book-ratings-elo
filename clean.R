library(tidyverse)

BOOKS = read_csv('goodreads_library_export.csv')

BOOKS

books = read_csv('books-edited.csv')

books

books = books %>% 
  left_join(
    BOOKS %>% 
      select(bookid = `Book Id`, shelves = Bookshelves)
  )

books

books %>%
  select(shelves) %>%
  separate_rows(shelves, sep = ', ') %>% 
  count(shelves) %>% 
  arrange(-n)

# books = BOOKS %>% 
#   filter(`Exclusive Shelf` == 'read') %>% 
#   unite('author', Author, `Additional Authors`, sep = ', ', na.rm = TRUE) %>% 
#   select(bookid = `Book Id`, title = Title, author, myrating = `My Rating`, avgrating = `Average Rating`, dateread = `Date Read`) %>% 
#   mutate(author = str_squish(author))

books

books %>% write_csv('book-index.csv')
