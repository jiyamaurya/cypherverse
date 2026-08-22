import json

path = 'C:/yojana_mitra/assets/data/schemes_seed.json'
d = json.load(open(path, encoding='utf-8'))

fixed = 0
for s in d:
    docs = s.get('documents_needed', [])
    new_docs = [x for x in docs if x and x.strip()]
    if len(new_docs) != len(docs):
        print(f"{s.get('scheme_name')}: removed {len(docs)-len(new_docs)} empty document entries")
        s['documents_needed'] = new_docs
        fixed += 1
    if not s.get('deadline') or not s['deadline'].strip():
        s['deadline'] = 'Not specified'
        fixed += 1

json.dump(d, open(path, 'w', encoding='utf-8'), indent=2, ensure_ascii=False)
print(f"\n{fixed} fixes applied")