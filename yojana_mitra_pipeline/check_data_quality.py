import json

d = json.load(open('schemes_output.json', encoding='utf-8'))
for s in d:
    name = s.get('scheme_name', '?')
    n_qualify = len(s.get('who_qualifies', []))
    n_docs = len(s.get('documents_needed', []))
    n_faqs = len(s.get('common_faqs', []))
    manual = any(r.get('field') == 'manual_review' for r in s.get('who_qualifies', []))
    flag = " <- THIN/MANUAL" if (n_qualify <= 1 or manual or n_docs == 0) else ""
    print(f"{name}: rules={n_qualify}, docs={n_docs}, faqs={n_faqs}{flag}")