"
Use the crossref API and doi.org API to get bibliographic details and/or bibtex.
"

(require hyrule [-> ->>])

(import requests)
(import habanero [Crossref])

(import bibsearch.doi [doi-to-bibtex])
(import bibsearch.isbn [isbn-to-bibtex])


(defclass CrossrefError [requests.HTTPError])

(defn works [query * [email None] [year None] [dois None] [limit 20] [fields None]]
  "Search for publication from general bibliographic data. Return dict."
  (let [default-fields ["DOI" "title" "type" "page" "prefix" "volume" "issue" "author" "container-title" "ISSN" "subject" "issued" "publisher" "publisher-location" "URL"]
        client (Crossref :mailto email)
        results (client.works :query query
                              :year year
                              :ids dois
                              :limit limit
                              :select (or fields default-fields)
                              :warn True)]
    (if results
      (get results "message" "items")
      [])))

(defn isbn-or-doi-to-bibtex [result]
  "Produce bibtex from either isbn or doi."
  (cond
    (in "DOI" result) (doi-to-bibtex (:DOI result))
    (in "ISBN" result) (isbn-to-bibtex (get (:ISBN result) 0))
    :else ""))
  
(defn search-to-bibtex [query * [year None] [limit 20] [email None]] 
  "Search for publication from general bibliographic data and return a bibtex entry."
  (->> (works query
              :year year
              :limit limit
              :fields ["ISBN" "DOI"])
       (map isbn-or-doi-to-bibtex)
       (list)
       (.join ",\n\n")
       (print "\n")))

