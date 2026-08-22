import requests
from bs4 import BeautifulSoup
import pdfplumber
from io import BytesIO
import urllib3

from playwright.sync_api import sync_playwright

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
    "Accept-Language": "en-IN,en;q=0.9,hi;q=0.8",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
}


def _try_get(url, timeout, verify=True):
    return requests.get(url, timeout=timeout, headers=HEADERS, verify=verify)


def fetch_html(url):
    """Download an HTML page with fallbacks for common gov-site quirks:
    slow servers, missing www, and expired SSL certs."""
    attempts = [url]
    if "://www." not in url:
        attempts.append(url.replace("://", "://www."))

    last_error = None
    for attempt_url in attempts:
        try:
            r = _try_get(attempt_url, timeout=30)
            r.raise_for_status()
            return _extract_text(r.text, page_url=r.url)
        except requests.exceptions.SSLError:
            # Known issue on some Indian government sites with expired certs.
            # We still only read public information, so we proceed without
            # verification as a last resort, not as a default.
            try:
                r = _try_get(attempt_url, timeout=30, verify=False)
                r.raise_for_status()
                return _extract_text(r.text, page_url=r.url)
            except Exception as e:
                last_error = e
        except Exception as e:
            last_error = e

    raise last_error


def _extract_text(html, page_url=None):
    soup = BeautifulSoup(html, "html.parser")
    for tag in soup(["script", "style", "nav", "footer", "header"]):
        tag.decompose()

    # IMPORTANT: soup.get_text() throws away every <a href="..."> — the AI
    # extractor only ever sees anchor *text* like "Apply Online", never the
    # actual destination URL. That is the main reason application_url came
    # back empty for almost every scheme. Fix: rewrite each link in place as
    # "anchor text (URL)" before pulling the plain text, so the real URL
    # travels with its link text into the scraped content the AI reads.
    from urllib.parse import urljoin

    base_href = page_url
    base_tag = soup.find("base", href=True)
    if base_tag:
        base_href = urljoin(page_url, base_tag["href"]) if page_url else base_tag["href"]

    for a in soup.find_all("a", href=True):
        href = a["href"].strip()
        if not href or href.startswith(("javascript:", "#", "mailto:", "tel:")):
            continue
        # Resolve relative links (e.g. "/apply", "form.pdf") to absolute URLs
        # using the page's own URL, so the AI sees a real clickable link.
        if not href.startswith(("http://", "https://")) and base_href:
            href = urljoin(base_href, href)
        text = a.get_text(strip=True)
        if text:
            a.replace_with(f"{text} ({href})")
        else:
            a.replace_with(f"({href})")

    return soup.get_text(separator="\n", strip=True)


def fetch_pdf(url):
    try:
        r = _try_get(url, timeout=30)
        r.raise_for_status()
    except requests.exceptions.SSLError:
        r = _try_get(url, timeout=30, verify=False)
        r.raise_for_status()

    text = ""
    with pdfplumber.open(BytesIO(r.content)) as pdf:
        for page in pdf.pages:
            page_text = page.extract_text()
            if page_text:
                text += page_text + "\n"
    return text

def fetch_html_rendered(url):
    """Fetch a page using a real headless browser, so JavaScript-rendered
    content (like MyScheme.gov.in) is fully loaded before we read it."""
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(user_agent=HEADERS["User-Agent"])
        page.goto(url, timeout=30000, wait_until="networkidle")
        html = page.content()
        final_url = page.url
        browser.close()
    return _extract_text(html, page_url=final_url)

JS_APP_SHELL_MARKERS = [
    "Something went wrong. Please try again later.",
    "You need to enable JavaScript",
    "Loading...",
]


def _looks_like_js_shell(text):
    stripped = text.strip()
    if len(stripped) < 500:
        return True
    return any(marker in stripped for marker in JS_APP_SHELL_MARKERS)


def fetch_source(source):
    if source["type"] == "pdf":
        return fetch_pdf(source["url"])

    text = fetch_html(source["url"])
    if _looks_like_js_shell(text):
        # Plain fetch only saw an error shell or empty app container —
        # retry with a real headless browser that can execute JavaScript.
        try:
            rendered = fetch_html_rendered(source["url"])
            if len(rendered.strip()) > len(text.strip()):
                return rendered
        except Exception:
            pass
    return text

def fetch_combined(urls):
    """Fetch multiple URLs for one scheme and combine their text,
    labeled by source so the AI knows where each part came from."""
    combined = ""
    for entry in urls:
        try:
            text = fetch_source(entry)
            combined += f"\n\n=== Source: {entry['url']} ===\n{text}"
        except Exception as e:
            combined += f"\n\n=== Source: {entry['url']} (FAILED: {e}) ===\n"
    return combined


if __name__ == "__main__":
    test_source = {"url": "https://pmkisan.gov.in/", "type": "html"}
    content = fetch_source(test_source)
    print(f"Fetched {len(content)} characters")