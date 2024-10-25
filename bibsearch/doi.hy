"""
Use doi.org API to get bibliographic details and/or bibtex.
"""

(import json)
(import requests)
(import datetime [datetime])


(defclass DOIError [requests.HTTPError])


(defn doi-to-bibtex [doi]
  "Return a bibtex entry from a DOI."
  (let [response (requests.get
                   f"https://doi.org/{doi}"
                   :headers {"Accept" "application/x-bibtex; charset=utf-8"})]  
    (if (= 200 response.status-code)
      (.decode response.content "utf-8")
      (raise (DOIError f"Bibtex retrieval for {doi} failed, error {response.status-code}")))))

(defn doi-to-json [doi]
  "Return a json summary from a DOI."
  (let [response (requests.get
                   f"https://doi.org/{doi}"
                   :headers {"Accept" "application/citeproc+json; charset=utf-8"})  
        fields (if (= 200 response.status-code)
                 (.json response)
                 (raise (DOIError f"JSON retrieval for {doi} failed, error {response.status-code}")))
        authors (.join "; " (lfor n (:author fields) f"{(:family n)}, {(:given n)}"))]
    (setv (get fields "authors") authors)
    (json.dumps fields :indent 4)))

(defn doi-to-text [doi]
  "Return a text/x-bibliography entry from a DOI."
  (let [response (requests.get
                   f"https://doi.org/{doi}"
                   :headers {"Accept" "text/x-bibliography; charset=utf-8"})]  
    (if (= 200 response.status-code)
      (.decode response.content "utf-8")
      (raise (DOIError f"Bibliography retrieval for {doi} failed, error {response.status-code}")))))

(defn doi-to-bash [doi]
  "Return bash script setting bash variables from a DOI.
  Sets `$title`, `$authors`, `$doi`, `$publisher` and `$issued`."
  (let [response (requests.get
                   f"https://doi.org/{doi}"
                   :headers {"Accept" "application/citeproc+json; charset=utf-8"})  
        fields (if (= 200 response.status-code)
                 (.json response)
                 (raise (DOIError f"JSON retrieval for {doi} failed, error {response.status-code}")))
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
  (let [response (requests.get
                   f"https://doi.org/{doi}"
                   :headers {"Accept" "application/citeproc+json; charset=utf-8"})  
        fields (if (= 200 response.status-code)
                 (.json response)
                 (raise (DOIError f"JSON retrieval for {doi} failed, error {response.status-code}")))
        authors (.join "; " (lfor n (:author fields) f"{(:family n)}, {(:given n)}"))
        ymd (get fields "issued" "date-parts" 0) ; some fields (m, d) may be missing
        abstract (:abstract fields None)
        doi (:DOI fields)
        issued (.strftime
                 (datetime #* (+ ymd [1 1 1]))
                 "%Y-%m-%d")]
    f"# {(:title fields)}

Author: {(:authors fields authors)}
Issued: {issued}
Publisher: {(:publisher fields "")}

[DOI](https://doi.org/{doi})

## Abstract

{abstract}
"))

