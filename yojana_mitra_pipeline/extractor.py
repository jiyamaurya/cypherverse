from openai import OpenAI
import json
import os
from dotenv import load_dotenv

load_dotenv()
client = OpenAI(
    api_key=os.environ["GROQ_API_KEY"],
    base_url="https://api.groq.com/openai/v1"
)

MODEL = "llama-3.1-8b-instant"

EXTRACTION_PROMPT = """Extract this government scheme into EXACT JSON matching this schema.
Return ONLY valid JSON. No markdown, no code fences, no explanation, no preamble.

{{
  "scheme_name": "",
  "ministry": "",
  "benefit": "",
  "benefit_type": "cash | kind | subsidy | insurance | other",
  "who_qualifies": [
    {{"field": "", "operator": "eq|neq|lte|gte|lt|gt|in|not_in", "value": null, "description": ""}}
  ],
  "who_does_NOT_qualify": [
    {{"field": "", "operator": "eq|neq|lte|gte|lt|gt|in|not_in", "value": null, "description": ""}}
  ],
  "documents_needed": [""],
  "application_steps": "a single string like Step 1: ... Step 2: ... Step 3: ...",
  "deadline": "",
  "state": "central, or a specific Indian state name",
  "source_url": "",
  "application_url": "",
  "form_download_url": "",
  "rejection_reasons": [""],
  "common_faqs": [
    {{"q": "", "a": ""}}
  ]
}}

Rules:
- Extract EVERY eligibility condition, document, FAQ, and rejection reason mentioned - do not summarize or skip any.
- If information for a field is not present, use an empty string, empty list, or best reasonable guess based on context - never invent specific numbers or dates.
- If the raw content is a general department portal covering many schemes rather than one specific scheme, still extract whatever you can find about the named scheme; if truly nothing scheme-specific exists, set "ministry" to the visible department/state name, "scheme_name" to the scheme name given below, and "benefit" to "See official website for details" rather than leaving them empty.
- who_qualifies and who_does_NOT_qualify must only contain structured, checkable conditions. If a condition cannot be safely auto-checked, use field "manual_review", operator "eq", value true, and describe it.
- application_steps must be ONE string, not a list.
- common_faqs keys must be "q" and "a".
- Every link scraped from the page appears in the raw content as "link text (https://actual-url)" — the URL in parentheses immediately after a link's visible text is that link's real destination, not just a label.
- application_url: scan the raw content for a link whose text suggests applying/registering/logging in to submit an application — phrases like "Apply Online", "New Farmer Registration", "Register Here", "Login to Portal", "Apply Now", "Submit Application". Copy the URL from that link's parentheses exactly as written. This must be a specific action link, NOT the general homepage URL already given as source_url. If several such links exist, pick the one most clearly meant for a new applicant. If truly no such link exists anywhere in the content, leave application_url as an empty string — never guess or invent one.
- form_download_url: scan the raw content for a link to a downloadable PDF/document explicitly meant to be printed or filled offline — phrases like "Download Application Form", "Form PDF", "Download Form", ".pdf" links near words like "form" or "application". Copy the exact URL from parentheses. If no such downloadable form link exists, leave it as an empty string — never guess.

Scheme name (use this if the content does not clearly restate it): {scheme_name}

Raw scraped content:
{content}
"""


import re

KEYWORDS = ["document", "eligib", "apply", "application", "process", "offline",
            "online", "benefit", "exclusion", "qualif", "rejection", "faq"]


def smart_excerpt(raw_text, content_limit):
    """Instead of blindly taking the first N characters (which throws away
    everything after the homepage boilerplate, including the actual useful
    sections buried deep in large PDFs), pull the opening context plus
    windows of text around keyword-relevant sections, up to the budget."""
    if len(raw_text) <= content_limit:
        return raw_text

    head_budget = content_limit // 3
    excerpt = raw_text[:head_budget]
    used_ranges = [(0, head_budget)]

    remaining = content_limit - head_budget
    window = 400

    matches = []
    for kw in KEYWORDS:
        for m in re.finditer(kw, raw_text, re.IGNORECASE):
            matches.append(m.start())

    matches.sort()
    for pos in matches:
        if remaining <= 0:
            break
        start = max(0, pos - 100)
        end = min(len(raw_text), pos + window)
        if any(not (end <= r[0] or start >= r[1]) for r in used_ranges):
            continue  # skip overlap with already-included text
        snippet = raw_text[start:end]
        excerpt += f"\n...\n{snippet}"
        used_ranges.append((start, end))
        remaining -= len(snippet)

    return excerpt


def extract_scheme(raw_text, source_url, scheme_name="", content_limit=5000):
    content = smart_excerpt(raw_text, content_limit)
    prompt = EXTRACTION_PROMPT.format(content=content, scheme_name=scheme_name)
    response = client.chat.completions.create(
        model=MODEL,
        messages=[{"role": "user", "content": prompt}],
        temperature=0.2,
        max_tokens=3000,
    )
    cleaned = response.choices[0].message.content.strip()

    if cleaned.startswith("```"):
        cleaned = cleaned.split("```")[1]
        if cleaned.startswith("json"):
            cleaned = cleaned[4:]
        cleaned = cleaned.strip()

    data = json.loads(cleaned)
    data["source_url"] = source_url
    return data


if __name__ == "__main__":
    from fetcher import fetch_source

    test_source = {"url": "https://pmkisan.gov.in/", "type": "html"}
    raw_text = fetch_source(test_source)
    scheme_data = extract_scheme(raw_text, test_source["url"], "PM-KISAN")
    print(json.dumps(scheme_data, indent=2, ensure_ascii=False))