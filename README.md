# hy-bibsearch

A python/hy library to produce bibtex (or markdown, json or bash script) from a
general search query, doi or isbn.

Provides command-line tools `bibsearch`, `isbnsearch` and `doisearch`.

Uses the crossref API, Google Books API and doi.org.


### Usage (command-line utilities)
```bash
$ bibsearch -h
$ doisearch -h
$ isbnsearch -h
```

### Usage (python)
```python
import bibsearch
```

### Usage (Hy)
```hy
(import bibsearch)
```
