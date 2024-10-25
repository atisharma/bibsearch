import hy
import sys
import argparse

from bibsearch.bibsearch import works, search_to_bibtex
from bibsearch.doi import doi_to_bibtex, doi_to_bash, doi_to_json, doi_to_text, doi_to_markdown
from bibsearch.isbn import isbn_to_bibtex, isbndoi_to_bash, isbndoi_to_json, isbndoi_to_text, isbndoi_to_markdown


def bib_search():
    parser = argparse.ArgumentParser(description="Search for a publication from general bibliographic data, return a bibtex entry.")
    parser.add_argument("query", type=str)
    parser.add_argument("--year", "-y", type=int, default=None)
    parser.add_argument("--limit", "-l", type=int, default=20, help="Maximum number of results.")
    parser.add_argument("--email", "-m", type=str, help="Specify your email to use Crossref's 'polite' server pool.")
    args = parser.parse_args()
    search_to_bibtex(args.query, year=args.year, limit=args.limit, email=args.email)

def doi_search():
    parser = argparse.ArgumentParser(description="Get a bibliography entry from a DOI.")
    parser.add_argument("doi", type=str)
    parser.add_argument("--bibtex", "-x", action=argparse.BooleanOptionalAction, default=True, help="Output as bibtex." )
    parser.add_argument("--text", "-t", action=argparse.BooleanOptionalAction, default=False, help="Output in textual format." )
    parser.add_argument("--bash", "-b", action=argparse.BooleanOptionalAction, default=False, help="Output as bash script." )
    parser.add_argument("--json", "-j", action=argparse.BooleanOptionalAction, default=False, help="Output as json." )
    parser.add_argument("--markdown", "-m", action=argparse.BooleanOptionalAction, default=False, help="Output as markdown." )
    args = parser.parse_args()
    if args.json:
        print(doi_to_json(args.doi))
    if args.markdown:
        print(doi_to_markdown(args.doi))
    elif args.bash:
        print(doi_to_bash(args.doi))
    elif args.text:
        print(doi_to_text(args.doi))
    else:
        print(doi_to_bibtex(args.doi))

def isbn_search():
    parser = argparse.ArgumentParser(description="Get a bibliography entry from an ISBN.")
    parser.add_argument("isbn", type=str)
    parser.add_argument("--bibtex", "-x", action=argparse.BooleanOptionalAction, default=True, help="Output as bibtex." )
    parser.add_argument("--bash", "-b", action=argparse.BooleanOptionalAction, default=False, help="Output as bash script." )
    parser.add_argument("--json", "-j", action=argparse.BooleanOptionalAction, default=False, help="Output as json." )
    parser.add_argument("--markdown", "-m", action=argparse.BooleanOptionalAction, default=False, help="Output as markdown." )
    args = parser.parse_args()
    if args.json:
        print(isbn_to_json(args.isbn))
    if args.markdown:
        print(isbn_to_markdown(args.isbn))
    elif args.bash:
        print(isbn_to_bash(args.isbn))
    elif args.text:
        print(isbn_to_text(args.isbn))
    else:
        print(isbn_to_bibtex(args.isbn))

def arxiv_search():
    parser = argparse.ArgumentParser(description="Get a bibliography entry from a DOI.")
    parser.add_argument("id", type=str, help="The arXiv id.")
    parser.add_argument("--bibtex", "-x", action=argparse.BooleanOptionalAction, default=True, help="Output as bibtex." )
    parser.add_argument("--text", "-t", action=argparse.BooleanOptionalAction, default=False, help="Output in textual format." )
    parser.add_argument("--bash", "-b", action=argparse.BooleanOptionalAction, default=False, help="Output as bash script." )
    parser.add_argument("--json", "-j", action=argparse.BooleanOptionalAction, default=False, help="Output as json." )
    parser.add_argument("--markdown", "-m", action=argparse.BooleanOptionalAction, default=False, help="Output as markdown." )
    args = parser.parse_args()
    doi = "10.48550/arXiv." + args.id
    if args.json:
        print(doi_to_json(doi))
    if args.markdown:
        print(doi_to_markdown(doi))
    elif args.bash:
        print(doi_to_bash(doi))
    elif args.text:
        print(doi_to_text(doi))
    else:
        print(doi_to_bibtex(doi))

def works_search():
    parser = argparse.ArgumentParser(description="Search for a publication from general bibliographic data, for further processing. Usually you want to use bibsearch instead.")
    parser.add_argument("query", type=str)
    parser.add_argument("--doi", "-d", type=str, default=None)
    parser.add_argument("--fields", "-f", type=str, default=None)
    parser.add_argument("--year", "-y", type=int, default=None)
    parser.add_argument("--limit", "-l", type=int, default=20, help="Maximum number of results.")
    parser.add_argument("--email", "-m", type=str, help="Specify your email to use Crossref's 'polite' server pool.")
    args = parser.parse_args()
    print(works(args.query, year=args.year, dois=args.dois, limit=args.limit, fields=args.fields, email=args.email))
