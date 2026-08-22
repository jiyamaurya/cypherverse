import json

path = 'C:/yojana_mitra/assets/data/schemes_seed.json'
d = json.load(open(path, encoding='utf-8'))

str_fields = ['scheme_name', 'ministry', 'benefit', 'benefit_type',
              'application_steps', 'deadline', 'state', 'source_url']

fixed = 0
for s in d:
    for f in str_fields:
        if s.get(f) is None:
            s[f] = ''
            fixed += 1

json.dump(d, open(path, 'w', encoding='utf-8'), indent=2, ensure_ascii=False)
print(f'Fixed {fixed} null field(s)')