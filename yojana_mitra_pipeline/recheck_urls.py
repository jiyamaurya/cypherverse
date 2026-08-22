import json
import requests
import fetcher

d = json.load(open('schemes_output.json', encoding='utf-8'))
for s in d:
    app_url = s.get('application_url')
    if app_url:
        try:
            check = requests.head(app_url, timeout=10, allow_redirects=True, headers=fetcher.HEADERS)
            if check.status_code >= 400:
                print(f"{s['scheme_name']}: {app_url} -> {check.status_code}, discarding")
                s['application_url'] = None
            else:
                print(f"{s['scheme_name']}: {app_url} -> OK ({check.status_code})")
        except Exception as e:
            print(f"{s['scheme_name']}: {app_url} -> unreachable, discarding ({e})")
            s['application_url'] = None

json.dump(d, open('schemes_output.json', 'w', encoding='utf-8'), indent=2, ensure_ascii=False)