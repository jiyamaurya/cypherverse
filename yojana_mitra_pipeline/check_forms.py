import json

d = json.load(open('C:/yojana_mitra/assets/data/schemes_seed.json', encoding='utf-8'))
print(f"{len(d)} schemes\n")
for s in d:
    name = s.get('scheme_name', '?')
    form = s.get('form_download_url')
    print(f"{name}: {form if form else '(no downloadable form found)'}")