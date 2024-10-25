"
Use ISBN via google's books API to get bibliographic details.
"

(import json)
(import requests)
(import datetime [datetime])


(defclass ISBNError [requests.HTTPError])


(defn fetch-volume-info [isbn]
  "Return a dict from an ISBN, however the API provides it."
  (let [response (requests.get f"https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}")
        fields (if (= 200 response.status-code)
                 (if (:totalItems (.json response))
                   (:volumeInfo (get (:items (.json response)) 0))
                   (raise (ISBNError f"No results for {isbn} with Google Books API.")))
                 (raise (ISBNError f"JSON retrieval for {isbn} failed, error {response.status-code}")))]
    fields))

(defn get-isbn [isbn]
  "Return a dict from an ISBN with standardised fields."
  (let [book (fetch-volume-info isbn)
        date (:publishedDate book "Unknown")
        year (get (.split date "-") 0)
        identifiers (dfor d (:industryIdentifiers book)
                      (.lower (:type d)) (:identifier d))
        isbn (:isbn-13 book (:isbn-10 book isbn))]
    {#** book
     #** identifiers
     "isbn" isbn
     "date" date
     "year" year}))

(defn isbn-to-json [isbn]
  "Return a json summary from an ISBN."
  (json.dumps (get-isbn isbn) :indent 4))

(defn isbn-to-bibtex [isbn]
  "Return a bibtex entry from a ISBN."
  (let [book (get-isbn isbn)
        author-1 (get (:authors book) 0)
        authors (.join " and " (:authors book))
        surname (get (.split author-1) -1)
        title (:title book)]
    f"@book{{{surname}{year}{title},
  author    = {{{authors}}},
  title     = {{{title}}},
  publisher = {{{(:publisher book)}}},
  year      = {{{(:year book)}}},
  isbn      = {{{(:isbn book)}}}
}}"))

(defn isbn-to-bash [isbn]
  "Return bash script setting bash variables from a ISBN.
  Sets `$title`, `$authors`, `$isbn`, `$publisher` and `$issued`."
  (let [book (get-isbn isbn)
        authors (.join "; " (:authors book))]
    (.join "; "
           [f"title=\"{(:title book)}\""
            f"isbn=\"{(:isbn book)}\""
            f"issued=\"{(:publishedDate book)}\""
            f"publisher=\"{(:publisher book "")}\""
            f"authors=\"{authors}\""])))

(defn isbn-to-markdown [isbn]
  "Return markdown-formatted text."
  (let [book (get-isbn isbn)
        authors (.join "; " (:authors book))]
    f"# {(:title book)}

Author: {authors}
Published {(or (:date book None) (:year book))}
Publisher: {(:publisher book "")}
ISBN: {(:isbn book)}
"))


