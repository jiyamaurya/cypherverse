from fetcher import fetch_source

urls = [
    "https://www.myscheme.gov.in/schemes/nfsm",
    "https://www.myscheme.gov.in/schemes/pkvy",
]

for url in urls:
    text = fetch_source({"url": url, "type": "html"})
    print(f"{url}\n  -> {len(text.strip())} chars\n  preview: {text.strip()[:200]}\n")