"""
Use the crossref API and doi.org API to get bibliographic details and/or bibtex.
"""
(require hyrule [-> ->>])

(import json)
(import requests)

(import habanero [Crossref])


(defn works [query * [email None] [year None] [dois None] [limit 20] [fields None]]
  "Search for publication from general bibliographic data."
  (let [default-fields ["DOI" "title" "type" "page" "prefix" "volume" "issue" "author" "container-title" "ISSN" "subject" "issued" "publisher" "publisher-location" "URL"]
        client (Crossref :mailto email)
        results (client.works :query query
                              :year year
                              :ids dois
                              :limit limit
                              :select (or fields default-fields)
                              :warn True)]
    (if (= (get results "status") "ok")
      (get results "message" "items")
      (get results "status"))))

(defn doi-to-bibtex [doi]
  "Return a bibtex entry from a DOI."
  (let [response (requests.get f"https://doi.org/{doi}"
                                :headers {"Accept" "application/x-bibtex; charset=utf-8"})]  
    (if (= 200 response.status-code)
      (.decode response.content "utf-8")
      (raise f"Bibtex for {doi} failed, error {r.status-code}"))))

(defn search-to-bibtex [query * [year None] [limit 20] [email None]] 
  "Search for publication from general bibliographic data and return a bibtex entry."
  (->> (works query :year year :limit limit :fields "DOI")
       (map (fn [d] (get d "DOI")))
       (map doi-to-bibtex)
       (list)
       (.join ",\n\n")
       (print "\n")))
