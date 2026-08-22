import json

d = json.load(open('C:/yojana_mitra/assets/data/schemes_seed.json', encoding='utf-8'))

required_str_fields = ['scheme_name', 'ministry', 'benefit', 'benefit_type',
                        'application_steps', 'deadline', 'state', 'source_url']
required_list_fields = ['who_qualifies', 'who_does_NOT_qualify', 'documents_needed',
                         'rejection_reasons', 'common_faqs']

for i, s in enumerate(d):
    name = s.get('scheme_name', f'ENTRY_{i}')
    for f in required_str_fields:
        val = s.get(f)
        if not isinstance(val, str):
            print(f'{name}: field "{f}" is {type(val).__name__}, not str -> {repr(val)[:80]}')
    for f in required_list_fields:
        val = s.get(f)
        if not isinstance(val, list):
            print(f'{name}: field "{f}" is {type(val).__name__}, not list -> {repr(val)[:80]}')
        elif f in ('who_qualifies', 'who_does_NOT_qualify'):
            for r in val:
                for rf in ['field', 'operator', 'description']:
                    if not isinstance(r.get(rf), str):
                        print(f'{name}: rule in "{f}" has non-str "{rf}" -> {repr(r.get(rf))[:80]}')
        elif f == 'documents_needed' or f == 'rejection_reasons':
            for item in val:
                if not isinstance(item, str):
                    print(f'{name}: "{f}" has non-str item -> {repr(item)[:80]}')
        elif f == 'common_faqs':
            for faq in val:
                if 'q' not in faq or 'a' not in faq:
                    print(f'{name}: faq missing q/a -> {repr(faq)[:80]}')

print('Check complete.')