import json

d = json.load(open('schemes_output.json', encoding='utf-8'))
for s in d:
    if s.get('scheme_name', '').lower().startswith('kisan credit card'):
        print(f"Before: {s.get('application_url')}")
        s['application_url'] = None  # wrong scheme's URL, discard
        print(f"After: {s.get('application_url')}")

json.dump(d, open('schemes_output.json', 'w', encoding='utf-8'), indent=2, ensure_ascii=False)