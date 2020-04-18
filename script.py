import csv
import math
import random

def write_csv(rows, fpath, headers):
    with open(fpath, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=headers)
        writer.writeheader()
        writer.writerows(rows)

with open('booklist.csv','r') as csvfile:
    reader = csv.DictReader(csvfile)
    books = []
    for row in reader:
        books.append(
            dict(
                bookid=row['bookid'],
                title=row['title'],
                author=row['author'],
                genres=row['genres'],
                matchups=int(row['matchups']),
                wins=int(row['wins']),
                ties=int(row['ties']),
                losses=int(row['losses']),
                rating=float(row['rating']),
            )
        )

with open('matchups.csv','r') as csvfile:
    reader = csv.DictReader(csvfile)
    matchups = []
    for row in reader:
        matchups.append(
            dict(
                book1id=row['book1id'],
                book2id=row['book2id'],
                book1elo0=float(row['book1elo0']),
                book2elo0=float(row['book2elo0']),
                WINNER=int(row['WINNER']),
                exp1=float(row['exp1']),
                exp2=float(row['exp2']),
                book1elo1=float(row['book1elo1']),
                book2elo1=float(row['book2elo1']),
            )
        )

while True:
    # TODO: generate weighted random sample
    denom = [b['matchups'] for b in books]
    denomsum = sum(denom)
    props = [v / float(denomsum) * 100 for v in denom]
    weights = [math.exp(-0.5 * v) * 100 for v in props]
    weightedbooks = []
    for g in zip(books, weights):
        w = g[1]
        if w < 0:
            w = 1
        book = g[0]
        booksmult = [book] * math.ceil(w)
        weightedbooks.extend(booksmult) 

    b1, b2 = random.sample(weightedbooks, 2)
    while b1['bookid'] == b2['bookid']:
        b2 = random.choice(weightedbooks)

    print('=== NEW RATING ===')
    print(f"1: {b1['title']}")
    print(f"2: {b2['title']}")

    validinput = False
    while not validinput:
        winner = input("Pick a book: ")
        winner = int(winner)
        if winner in [0,1,2]:
            validinput = True
        else:
            print('Pick a valid number: 0 (tie), 1, 2')

    b1['matchups'] += 1
    b2['matchups'] += 1
    b1['wins'] += (1 if winner == 1 else 0)
    b2['wins'] += (1 if winner == 2 else 0)
    b1['losses'] += (1 if winner == 2 else 0)
    b2['losses'] += (1 if winner == 1 else 0)
    b1['ties'] += (1 if winner == 0 else 0)
    b2['ties'] += (1 if winner == 0 else 0)
    res1 = (1 if winner == 1 else 0)
    res2 = (1 if winner == 2 else 0)
    if winner == 0:
        res1 = 0.5
        res2 = 0.5
    b1e0 = b1['rating']
    b2e0 = b2['rating']
    exp1 = 1 / (1 + 10**((b2e0 - b1e0)/400))
    exp2 = 1 / (1 + 10**((b1e0 - b2e0)/400))
    b1e1 = b1e0 + 32*(res1 - exp1)
    b2e1 = b2e0 + 32*(res2 - exp2)
    b1['rating'] = b1e1
    b2['rating'] = b2e1

    books = [b for b in books if b['bookid'] != b1['bookid'] and b['bookid'] != b2['bookid']]
    books.append(b1)
    books.append(b2)

    books = sorted(books, key=lambda x: x['rating'], reverse=True)

    write_csv(
        books,
        'booklist.csv',
        ['bookid','title','author','genres','matchups','wins','ties','losses','rating',]
    )

    scoreboard = dict(
        book1id=b1['bookid'],
        book2id=b2['bookid'],
        book1elo0=b1e0,
        book2elo0=b2e0,
        WINNER=winner,
        exp1=exp1,
        exp2=exp2,
        book1elo1=b1e1,
        book2elo1=b2e1,
    )

    matchups.append(scoreboard)

    write_csv(
        matchups,
        'matchups.csv',
        ['book1id','book2id','book1elo0','book2elo0','WINNER','exp1','exp2','book1elo1','book2elo1',]
    )

