import json
import os
import re
import time
import requests
import fetcher
from fetcher import fetch_combined
from extractor import extract_scheme
from validator import validate

OUTPUT_FILE = "schemes_output.json"


def load_existing_results():
    """Load previously successful extractions so reruns don't waste tokens
    reprocessing schemes we already have."""
    if not os.path.exists(OUTPUT_FILE):
        return {}
    with open(OUTPUT_FILE, "r", encoding="utf-8") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError:
            return {}
    return {item["_scheme_id"]: item for item in data if "_scheme_id" in item}


def is_daily_limit_error(e):
    return "tokens per day" in str(e) or "TPD" in str(e)


def is_request_too_large_error(e):
    return "Request too large" in str(e) or "reduce your message size" in str(e)

def is_truncated_json_error(e):
    return "Unterminated string" in str(e) or "Expecting" in str(e)

def is_minute_limit_error(e):
    return ("tokens per minute" in str(e) or "TPM" in str(e) or "429" in str(e)) \
        and not is_request_too_large_error(e)


def extract_with_retry(raw, url, scheme_name, max_retries=5):
    content_limit = 8000
    for attempt in range(max_retries):
        try:
            return extract_scheme(raw, url, scheme_name, content_limit=content_limit)
        except Exception as e:
            if is_daily_limit_error(e):
                raise RuntimeError(f"daily token limit reached, stopping run: {e}")
            if is_request_too_large_error(e):
                content_limit = int(content_limit * 0.5)
                print(f"  request too large, shrinking content to {content_limit} chars and retrying...")
                continue
            if is_truncated_json_error(e):
                print(f"  response got cut off mid-JSON, retrying...")
                continue
            if is_minute_limit_error(e):
                wait = 20 * (attempt + 1)
                print(f"  rate limited (per-minute), waiting {wait}s...")
                time.sleep(wait)
            else:
                raise
    raise RuntimeError("Max retries exceeded")


def run_pipeline(force=False):
    sources = json.load(open("sources.json"))
    results = load_existing_results()

    for source in sources:
        scheme_id = source["scheme_id"]
        if not force and scheme_id in results:
            print(f"Skipping {scheme_id} (already have data — use force=True to redo)")
            continue

        print(f"Processing {scheme_id}...")
        try:
            raw = fetch_combined(source["urls"])
            primary_url = source["urls"][0]["url"]
            if len(raw.strip()) < 200:
                print(f"  skipped: fetched content too short ({len(raw.strip())} chars) — likely JS-rendered or blocked page")
                continue

            scheme_name_guess = scheme_id.replace("_", " ").title()
            data = extract_with_retry(raw, primary_url, scheme_name_guess)
            errors = validate(data)
            if errors:
                print(f"  validation failed: {errors}")
                continue

            data["_scheme_id"] = scheme_id
            data["needs_verification"] = source.get("portal_source", False)

            for url_field in ["application_url", "form_download_url"]:
                link = data.get(url_field)
                if link:
                    try:
                        check = requests.head(link, timeout=10, allow_redirects=True, headers=fetcher.HEADERS)
                        if check.status_code >= 400:
                            print(f"  {url_field} returned {check.status_code}, discarding: {link}")
                            data[url_field] = None
                    except Exception:
                        print(f"  {url_field} unreachable, discarding: {link}")
                        data[url_field] = None

            results[scheme_id] = data
            print(f"  ok")

        except RuntimeError as e:
            if "daily token limit" in str(e):
                print(f"  {e}")
                print("\nStopping run — daily token budget exhausted. "
                      "Already-successful schemes are saved. Rerun later to continue.")
                break
            print(f"  failed: {e}")
        except Exception as e:
            print(f"  failed: {e}")

        time.sleep(10)

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(list(results.values()), f, indent=2, ensure_ascii=False)
    print(f"\nWrote {len(results)} scheme(s) total to {OUTPUT_FILE}")


if __name__ == "__main__":
    run_pipeline()