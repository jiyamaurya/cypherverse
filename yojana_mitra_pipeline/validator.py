REQUIRED_FIELDS = ["scheme_name", "ministry", "benefit", "source_url"]
SOFT_REQUIRED_FIELDS = ["who_qualifies"]  # missing = flagged, not rejected
VALID_OPERATORS = {"eq", "neq", "lte", "gte", "lt", "gt", "in", "not_in"}


def validate(data):
    """Check a scheme dict against required fields and rule structure.
    Returns a list of error strings — empty list means it's valid."""
    errors = []

    str_fields = ['scheme_name', 'ministry', 'benefit', 'benefit_type',
                  'application_steps', 'deadline', 'state', 'source_url']
    for f in str_fields:
        if data.get(f) is None:
            data[f] = ''

    app_url = data.get("application_url", "")
    if app_url and not app_url.startswith(("http://", "https://")):
        data["application_url"] = None

    for field in REQUIRED_FIELDS:
        if not data.get(field):
            errors.append(f"missing or empty field: {field}")

    for rule_group in ["who_qualifies", "who_does_NOT_qualify"]:
        rules = data.get(rule_group, [])
        if not isinstance(rules, list):
            errors.append(f"{rule_group} must be a list")
            continue
        cleaned_rules = []
        for rule in rules:
            if not isinstance(rule, dict) or rule.get("operator") not in VALID_OPERATORS:
                # Salvage whatever description we have instead of failing the whole scheme
                desc = rule.get("description", "Could not parse eligibility condition") if isinstance(rule, dict) else str(rule)
                cleaned_rules.append({
                    "field": "manual_review",
                    "operator": "eq",
                    "value": True,
                    "description": desc
                })
            else:
                cleaned_rules.append(rule)
        data[rule_group] = cleaned_rules

    if not isinstance(data.get("application_steps"), str):
        errors.append("application_steps must be a single string, not a list")

    for i, faq in enumerate(data.get("common_faqs", [])):
        if "q" not in faq or "a" not in faq:
            errors.append(f"common_faqs[{i}] must use 'q' and 'a' keys")

    for field in SOFT_REQUIRED_FIELDS:
        if not data.get(field):
            data[field] = [{
                "field": "manual_review",
                "operator": "eq",
                "value": True,
                "description": "Eligibility details not found on source page — needs manual verification"
            }]

    data['documents_needed'] = [d for d in data.get('documents_needed', []) if d and d.strip()]
    if not data.get('deadline') or not data['deadline'].strip():
        data['deadline'] = 'Not specified'

    return errors


if __name__ == "__main__":
    sample = {
        "scheme_name": "Test Scheme",
        "ministry": "Test Ministry",
        "benefit": "Rs 1000",
        "who_qualifies": [{"field": "occupation", "operator": "eq", "value": "farmer", "description": "test"}],
        "who_does_NOT_qualify": [],
        "application_steps": "Step 1: Apply online.",
        "common_faqs": [{"q": "test?", "a": "test."}],
        "source_url": "https://example.gov.in"
    }
    result = validate(sample)
    print("Valid!" if not result else f"Errors: {result}")