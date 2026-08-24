import re

def fix_receipt_screen():
    f = 'lib/screens/receipt_screen.dart'
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    content = content.replace('_buildReceiptItem(', '_buildReceiptItem(context, ')
    content = content.replace('_buildReceiptItem(context, BuildContext context,', '_buildReceiptItem(BuildContext context,')
    content = content.replace('_buildDetailRow(', '_buildDetailRow(context, ')
    content = content.replace('_buildDetailRow(context, BuildContext context,', '_buildDetailRow(BuildContext context,')
    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)

def fix_desktop_luxury_section():
    f = 'lib/widgets/desktop/desktop_luxury_section.dart'
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    # desktop_luxury_section.dart:376
    content = content.replace('Theme.of(context).cardColor', 'Colors.white')
    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)

def fix_desktop_product_card():
    f = 'lib/widgets/desktop/desktop_product_card.dart'
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    # line 273: const_eval_method_invocation
    # implicit_this_reference_in_initializer
    # just search for Theme.of(context) and remove it if it's in an initializer.
    # it is likely `final Color color = Theme.of(context).cardColor` or similar inside the class but outside build
    # wait, the class is a StatelessWidget, so it's in a constructor? No, `final Color color;` ...
    # wait, I'll just change any `Theme.of(context).cardColor` to `Colors.white` globally.
    content = content.replace('(Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1E2832))', 'const Color(0xFF1E2832)')
    content = content.replace('Theme.of(context).cardColor', 'Colors.white')
    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)
        
if __name__ == '__main__':
    fix_receipt_screen()
    fix_desktop_luxury_section()
    fix_desktop_product_card()
