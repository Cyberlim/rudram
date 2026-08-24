import re
import os

def fix_const_errors():
    errors_file = 'errors.txt'
    with open(errors_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    files_to_fix = {}
    for line in lines:
        if 'Error: ' in line:
            parts = line.split(':')
            if len(parts) >= 3:
                filename = parts[0]
                try:
                    lineno = int(parts[1]) - 1 # 0-indexed
                except ValueError:
                    continue
                if filename not in files_to_fix:
                    files_to_fix[filename] = set()
                files_to_fix[filename].add(lineno)

    for filename, linenos in files_to_fix.items():
        print(f"Fixing const in {filename}...")
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                file_lines = f.readlines()
            
            for lineno in sorted(list(linenos)):
                # search for 'const ' from lineno up to 10 lines backwards
                for i in range(lineno, max(-1, lineno - 15), -1):
                    if i < len(file_lines):
                        if 'const ' in file_lines[i] and 'Theme.of' not in file_lines[i]:
                             # wait, if 'Theme.of' is not in the line, but 'const ' is, it might be the start of the widget
                             file_lines[i] = file_lines[i].replace('const ', '')
                             break
                        elif 'const ' in file_lines[i] and 'Theme.of' in file_lines[i]:
                             # remove const that appears BEFORE Theme.of, or just all
                             file_lines[i] = file_lines[i].replace('const ', '')
                             break

            with open(filename, 'w', encoding='utf-8') as f:
                f.writelines(file_lines)
        except Exception as e:
            print(f"Error fixing {filename}: {e}")

def fix_context_errors():
    # 1. desktop_our_features_section.dart
    f1 = 'lib/widgets/desktop/desktop_our_features_section.dart'
    if os.path.exists(f1):
        with open(f1, 'r', encoding='utf-8') as f:
            content = f.read()
        content = content.replace('Widget _buildFeatureItem({', 'Widget _buildFeatureItem({required BuildContext context,')
        content = content.replace('_buildFeatureItem(', '_buildFeatureItem(context: context, ')
        with open(f1, 'w', encoding='utf-8') as f:
            f.write(content)
            
    # 2. desktop_footer_section.dart
    f2 = 'lib/widgets/desktop/desktop_footer_section.dart'
    if os.path.exists(f2):
        with open(f2, 'r', encoding='utf-8') as f:
            content = f.read()
        content = content.replace('Widget _buildSocialIcon(IconData icon)', 'Widget _buildSocialIcon(BuildContext context, IconData icon)')
        content = content.replace('_buildSocialIcon(Icons.facebook)', '_buildSocialIcon(context, Icons.facebook)')
        content = content.replace('_buildSocialIcon(Icons.camera_alt)', '_buildSocialIcon(context, Icons.camera_alt)')
        content = content.replace('_buildSocialIcon(Icons.ondemand_video)', '_buildSocialIcon(context, Icons.ondemand_video)')
        content = content.replace('_buildSocialIcon(Icons.link)', '_buildSocialIcon(context, Icons.link)')
        with open(f2, 'w', encoding='utf-8') as f:
            f.write(content)

if __name__ == '__main__':
    fix_const_errors()
    fix_context_errors()
