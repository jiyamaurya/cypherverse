from fetcher import fetch_pdf

test_pdfs = [
    "https://pmkisan.gov.in/Documents/RevisedFormat_Guidelines.pdf",
    "https://rbidocs.rbi.org.in/rdocs/content/pdfs/10MCKCC040718_AN.pdf",
]

for url in test_pdfs:
    try:
        text = fetch_pdf(url)
        print(f"{url}\n  -> {len(text)} characters extracted\n  preview: {text[:200]}\n")
    except Exception as e:
        print(f"{url}\n  -> FAILED: {e}\n")