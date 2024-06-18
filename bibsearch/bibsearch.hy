"""
Use the crossref API and doi.org API to get bibliographic details and/or bibtex.
"""
(require hyrule [-> ->>])

(import json)
(import requests)
(import datetime [datetime])

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

(defn search-to-bibtex [query * [year None] [limit 20] [email None]] 
  "Search for publication from general bibliographic data and return a bibtex entry."
  (->> (works query :year year :limit limit :fields "DOI")
       (map (fn [d] (get d "DOI")))
       (map doi-to-bibtex)
       (list)
       (.join ",\n\n")
       (print "\n")))

(defn doi-to-bibtex [doi]
  "Return a bibtex entry from a DOI."
  (let [response (requests.get f"https://doi.org/{doi}"
                                :headers {"Accept" "application/x-bibtex; charset=utf-8"})]  
    (if (= 200 response.status-code)
      (.decode response.content "utf-8")
      (raise f"Bibtex retrieval for {doi} failed, error {response.status-code}"))))

(defn doi-to-json [oi]
  "Return a json summary from a DOI."
  (let [response (requests.get f"https://doi.org/{doi}"
                                :headers {"Accept" "application/citeproc+json; charset=utf-8"})  
        fields (if (= 200 response.status-code)
                 (.json response)
                 (raise f"JSON retrieval for {doi} failed, error {response.status-code}"))
        authors (.join "; " (lfor n (:author fields) f"{(:family n)}, {(:given n)}"))]
    (setv (get fields "authors") authors)
    (json.dumps fields :indent 4)))

(defn doi-to-text [doi]
  "Return a text/x-bibliography entry from a DOI."
  (let [response (requests.get f"https://doi.org/{doi}"
                                :headers {"Accept" "text/x-bibliography; charset=utf-8"})]  
    (if (= 200 response.status-code)
      (.decode response.content "utf-8")
      (raise f"Bibliography retrieval for {doi} failed, error {response.status-code}"))))

(defn doi-to-bash [doi]
  "Return bash script setting bash variables from a DOI.
  Sets `$title`, `$authors`, `$doi`, `$publisher` and `$issued`."
  (let [response (requests.get f"https://doi.org/{doi}"
                                :headers {"Accept" "application/citeproc+json; charset=utf-8"})  
        fields (if (= 200 response.status-code)
                 (.json response)
                 (raise f"JSON retrieval for {doi} failed, error {response.status-code}"))
        authors (.join "; " (lfor n (:author fields) f"{(:family n)}, {(:given n)}"))
        ymd (get fields "issued" "date-parts" 0) ; some fields (m, d) may be missing
        issued (.strftime
                 (datetime #* (+ ymd [1 1 1]))
                 "%Y-%m-%d")]
    (.join "; "
           [f"title=\"{(:title fields)}\""
            f"doi=\"{(:DOI fields)}\""
            f"issued=\"{issued}\""
            f"publisher=\"{(:publisher fields "")}\""
            f"authors=\"{(:authors fields authors)}\""])))

(defn doi-to-markdown [doi]
  "Return markdown-formatted text."
  (let [response (requests.get f"https://doi.org/{doi}"
                                :headers {"Accept" "application/citeproc+json; charset=utf-8"})  
        fields (if (= 200 response.status-code)
                 (.json response)
                 (raise f"JSON retrieval for {doi} failed, error {response.status-code}"))
        authors (.join "; " (lfor n (:author fields) f"{(:family n)}, {(:given n)}"))
        ymd (get fields "issued" "date-parts" 0) ; some fields (m, d) may be missing
        abstract (:abstract fields None)
        doi (:DOI fields)
        issued (.strftime
                 (datetime #* (+ ymd [1 1 1]))
                 "%Y-%m-%d")]
    f"# {(:title fields)}

Author: {(:authors fields authors)}
ISsued: {issued}
Publisher: {(:publisher fields "")}

[DOI](https://doi.org/{doi})
"))
