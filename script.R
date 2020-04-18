library(tidyverse)

BOOKS = read_csv('goodreads_library_export.csv')

BOOKS

books = BOOKS %>% 
  filter(`Exclusive Shelf` == 'read') %>% 
  unite('author', Author, `Additional Authors`, sep = ', ', na.rm = TRUE) %>% 
  select(bookid = `Book Id`, title = Title, author, myrating = `My Rating`, avgrating = `Average Rating`, dateread = `Date Read`) %>% 
  mutate(author = str_squish(author))

books

books %>% write_csv('books-edited.csv')
