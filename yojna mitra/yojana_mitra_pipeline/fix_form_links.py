import json

path = 'C:/yojana_mitra/assets/data/schemes_seed.json'
d = json.load(open(path, encoding='utf-8'))

# Both of these look like cross-scheme contamination (wrong PDF for this scheme),
# same pattern we caught earlier with application_url — better to show none
# than a confidently wrong one.
suspicious = {
    "PM-Kisan Samman Nidhi": "https://pmkisan.gov.in/Documents/Kcc.pdf",
    "Pradhan Mantri Krishi Sinchayee Yojana": "https://pmksy.gov.in/pdfLinks/DIPTemplate.pdf",
}

for s in d:
    name = s.get('scheme_name')
    if suspicious.get(name) == s.get('form_download_url'):
        print(f"Clearing suspicious form link for: {name}")
        s['form_download_url'] = None

json.dump(d, open(path, 'w', encoding='utf-8'), indent=2, ensure_ascii=False)