from fetcher import fetch_html_rendered

text = fetch_html_rendered("https://www.myscheme.gov.in/schemes/pmfby")
print(f"{len(text)} characters")
print(text[:500])