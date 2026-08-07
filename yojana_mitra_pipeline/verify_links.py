import json

d = json.load(open('schemes_output.json', encoding='utf-8'))
print(f"{len(d)} schemes\n")
for s in d:
    name = s.get('scheme_name', '?')
    app_url = s.get('application_url') or '(none found)'
    print(f"{name}")
    print(f"  source_url:      {s.get('source_url')}")
    print(f"  application_url: {app_url}")
    print()