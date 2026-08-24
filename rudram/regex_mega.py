import re

def fix():
    f = 'lib/widgets/desktop/shop_mega_menu.dart'
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # regex to replace `_buildSectionHeader("anything")` with `_buildSectionHeader(context, "anything")`
    # but not if it already has context
    content = re.sub(r'_buildSectionHeader\((["\'])(.*?)\1\)', r'_buildSectionHeader(context, \1\2\1)', content)
    
    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)

if __name__ == '__main__':
    fix()
