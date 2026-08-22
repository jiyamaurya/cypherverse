import os, re

ROOT = r'C:\yojana_mitra'
LIB = os.path.join(ROOT, 'lib')

fixes = {

    # ── 1. app_theme.dart — add missing imports ──────────────────
    'app_theme.dart': {
        'add_imports': [
            "import 'package:yojana_mitra/core/constants/app_colors.dart';",
            "import 'package:yojana_mitra/core/constants/app_sizes.dart';",
        ]
    },

    # ── 2. home_screen.dart — add dart:ui back + fix underscores ─
    'home_screen.dart': {
        'add_imports': ["import 'dart:ui';"],
        'fix_underscores': True,
    },

    # ── 3. login_screen.dart — add dart:ui + AppStrings ──────────
    'login_screen.dart': {
        'add_imports': [
            "import 'dart:ui';",
            "import 'package:yojana_mitra/core/constants/app_strings.dart';",
        ],
    },

    # ── 4. splash_screen.dart — add missing constants imports ─────
    'splash_screen.dart': {
        'add_imports': [
            "import 'package:yojana_mitra/core/constants/app_colors.dart';",
            "import 'package:yojana_mitra/core/constants/app_sizes.dart';",
            "import 'package:yojana_mitra/core/constants/app_strings.dart';",
        ],
    },

    # ── 5. profile_screen.dart — add dart:ui back + fix ──────────
    'profile_screen.dart': {
        'add_imports': ["import 'dart:ui';"],
        'fix_underscores': True,
        'replacements': [
            ('activeColor:', 'activeThumbColor:'),
        ],
    },

    # ── 6. profile_setup_screen.dart — remove unused vars ─────────
    'profile_setup_screen.dart': {
        'remove_lines': [
            "const _kMedGreen = Color(0xFF2E7D32);",
            "import 'dart:math' as math;",
        ],
        'fix_underscores': True,
    },

    # ── 7. schemes_screen.dart — remove duplicate import ──────────
    'schemes_screen.dart': {
        'dedup_imports': True,
        'fix_underscores': True,
    },

    # ── 8. scheme_apply_screen.dart — fix underscores ─────────────
    'scheme_apply_screen.dart': {
        'fix_underscores': True,
    },

    # ── 9. scheme_detail_screen.dart — fix underscores ────────────
    'scheme_detail_screen.dart': {
        'fix_underscores': True,
    },

    # ── 10. scheme_eligibility_screen.dart — fix underscores ──────
    'scheme_eligibility_screen.dart': {
        'fix_underscores': True,
    },

    # ── 11. chat_screen.dart — fix underscores ────────────────────
    'chat_screen.dart': {
        'fix_underscores': True,
    },

    # ── 12. documents_screen.dart — fix underscores ───────────────
    'documents_screen.dart': {
        'fix_underscores': True,
    },
}

def process_file(filepath, filename, opts):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    # Add missing imports (after first 'import' line)
    for imp in opts.get('add_imports', []):
        if imp not in content:
            # Insert after last existing import
            lines = content.split('\n')
            last_import = 0
            for i, line in enumerate(lines):
                if line.strip().startswith('import '):
                    last_import = i
            lines.insert(last_import + 1, imp)
            content = '\n'.join(lines)

    # Remove specific lines
    for line_to_remove in opts.get('remove_lines', []):
        content = content.replace(line_to_remove + '\n', '')
        content = content.replace(line_to_remove, '')

    # String replacements
    for old, new in opts.get('replacements', []):
        content = content.replace(old, new)

    # Fix double underscores in parameter names (__, ___)
    if opts.get('fix_underscores'):
        # Fix patterns like (__, ___) in lambda/callback params
        content = re.sub(r'\(__, ___\)', '(_, __)', content)
        content = re.sub(r'\(_, __, ___\)', '(_, __, _)', content)
        # Fix standalone __ as parameter
        content = re.sub(r'(?<=\()__(?=,)', '_', content)
        content = re.sub(r'(?<=, )___(?=\))', '__', content)
        content = re.sub(r'(?<=\()___(?=\))', '__', content)

    # Remove duplicate imports
    if opts.get('dedup_imports'):
        lines = content.split('\n')
        seen = set()
        new_lines = []
        for line in lines:
            s = line.strip()
            if s.startswith('import '):
                if s in seen:
                    continue
                seen.add(s)
            new_lines.append(line)
        content = '\n'.join(new_lines)

    # Remove unused local variable 'progress' in profile_setup
    if filename == 'profile_setup_screen.dart':
        content = re.sub(r'\s+final double progress = [^\n]+;\n', '\n', content)

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

total = 0
for dirpath, _, filenames in os.walk(LIB):
    for filename in filenames:
        if filename in fixes:
            filepath = os.path.join(dirpath, filename)
            if process_file(filepath, filename, fixes[filename]):
                print('Fixed: ' + filename)
                total += 1

print('Done: ' + str(total) + ' files fixed')
print('Now run: flutter analyze')