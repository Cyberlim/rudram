import os
import glob
import re

def fix_files():
    files = glob.glob('lib/widgets/desktop/*.dart') + glob.glob('lib/screens/desktop/*.dart')
    for file in files:
        try:
            with open(file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # fix the double replace
            old_str = '(Theme.of(context).textTheme.bodyLarge?.color ?? const (Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1E2832)))'
            new_str = '(Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1E2832))'
            content = content.replace(old_str, new_str)
            
            # remove const from various widgets if they have Theme.of(context) inside
            # we can just do a regex that finds `const WidgetName( ... Theme.of(context) ... )`
            # But the safer way is to read errors.txt and remove `const ` on the previous line or same line.
            
            if content != original_content:
                with open(file, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Fixed double replace in {file}")
        except Exception as e:
            print(e)

if __name__ == '__main__':
    fix_files()
