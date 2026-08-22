from fetcher import fetch_pdf

test_pdfs = [
    "https://pmfby.gov.in/pdf/Revised_Operational_Guidelines.pdf",
    "https://nha.gov.in/img/resources/Operation%20Manual%20for%20AB%20PM-JAY.pdf",
    "https://www.nitiforstates.gov.in/public-assets/Policy/policy-repo/agriculture-and-allied-services/SNC511A000049.pdf",
]

for url in test_pdfs:
    try:
        text = fetch_pdf(url)
        print(f"{url}\n  -> {len(text)} characters\n  preview: {text[:150]}\n")
    except Exception as e:
        print(f"{url}\n  -> FAILED: {e}\n")