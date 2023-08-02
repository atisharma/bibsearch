import hy
import sys
import argparse

from bibsearch import bibsearch


def bib_search():
    parser = argparse.ArgumentParser(description="Search for a publication from general bibliographic data, return a bibtex entry.")
    parser.add_argument("query", type=str)
    parser.add_argument("--year", "-y", type=int, default=None)
    parser.add_argument("--limit", "-l", type=int, default=20, help="Maximum number of results.")
    parser.add_argument("--email", "-m", type=str, help="Specify your email to use Crossref's 'polite' server pool.")
    args = parser.parse_args()
    bibsearch.search_to_bibtex(args.query, year=args.year, limit=args.limit, email=args.email)

def doi_search():
    parser = argparse.ArgumentParser(description="Get a bibtex entry from a DOI.")
    parser.add_argument("doi", type=str)
    args = parser.parse_args()
    bibsearch.doi_to_bibtex(args.doi)

def works_search():
    parser = argparse.ArgumentParser(description="Search for a publication from general bibliographic data, for further processing. Usually you want to use bibsearch instead.")
    parser.add_argument("query", type=str)
    parser.add_argument("--doi", "-d", type=str, default=None)
    parser.add_argument("--fields", "-f", type=str, default=None)
    parser.add_argument("--year", "-y", type=int, default=None)
    parser.add_argument("--limit", "-l", type=int, default=20, help="Maximum number of results.")
    parser.add_argument("--email", "-m", type=str, help="Specify your email to use Crossref's 'polite' server pool.")
    args = parser.parse_args()
    bibsearch.works(args.query, year=args.year, dois=args.dois, limit=args.limit, fields=args.fields, email=args.email)
