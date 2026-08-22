def extract_scheme(raw_text, source_url):
    """Mock version of extractor.extract_scheme — returns fake data for testing
    the rest of the pipeline while the real Gemini API key issue is unresolved."""
    return {
        "scheme_name": "Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)",
        "ministry": "Ministry of Agriculture and Farmers Welfare",
        "benefit": "Rs 6,000 per year in 3 equal instalments",
        "benefit_type": "cash",
        "who_qualifies": [
            {"field": "occupation", "operator": "eq", "value": "farmer", "description": "Small or marginal farmer"}
        ],
        "who_does_NOT_qualify": [
            {"field": "is_income_tax_payer", "operator": "eq", "value": True, "description": "Income tax payer"}
        ],
        "documents_needed": ["Aadhaar card", "Land record", "Bank account details"],
        "application_steps": "Step 1: Go to pmkisan.gov.in. Step 2: Register with Aadhaar.",
        "deadline": "Ongoing",
        "state": "central",
        "source_url": source_url,
        "rejection_reasons": ["Aadhaar name mismatch"],
        "common_faqs": [{"q": "Why is my payment stopped?", "a": "Pending eKYC."}]
    }