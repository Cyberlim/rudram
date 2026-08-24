import os

def fix_mega():
    f = 'lib/widgets/desktop/shop_mega_menu.dart'
    if not os.path.exists(f): return
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()

    # 1. _buildSectionHeader
    content = content.replace('Widget _buildSectionHeader(String title)', 'Widget _buildSectionHeader(BuildContext context, String title)')
    content = content.replace('_buildSectionHeader(\'Luxury Highlights\')', '_buildSectionHeader(context, \'Luxury Highlights\')')
    content = content.replace('_buildSectionHeader(\'Fine Jewellery\')', '_buildSectionHeader(context, \'Fine Jewellery\')')
    content = content.replace('_buildSectionHeader(\'Silver Collections\')', '_buildSectionHeader(context, \'Silver Collections\')')
    content = content.replace('_buildSectionHeader(\'Gifting\')', '_buildSectionHeader(context, \'Gifting\')')

    # 2. _buildMenuItem
    content = content.replace('Widget _buildMenuItem({', 'Widget _buildMenuItem({required BuildContext context, ')
    content = content.replace('_buildMenuItem(', '_buildMenuItem(context: context, ')

    # 3. _buildTextLink
    content = content.replace('Widget _buildTextLink(String text)', 'Widget _buildTextLink(BuildContext context, String text)')
    # it is used in lists: `_buildTextLink('Rings'),` -> we need to find all `_buildTextLink(` and replace with `_buildTextLink(context, `
    content = content.replace('_buildTextLink(', '_buildTextLink(context, ')

    # Fix the method signature replace that might have duplicated
    content = content.replace('Widget _buildTextLink(context, BuildContext context, String text)', 'Widget _buildTextLink(BuildContext context, String text)')
    content = content.replace('Widget _buildMenuItem(context: context, {required BuildContext context, ', 'Widget _buildMenuItem({required BuildContext context, ')

    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)
        
if __name__ == '__main__':
    fix_mega()
