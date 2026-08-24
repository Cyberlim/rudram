import subprocess
import re

def fix_errors():
    while True:
        print("Running flutter analyze...")
        result = subprocess.run(['flutter', 'analyze'], capture_output=True, text=True, shell=True)
        output = result.stdout + result.stderr
        
        errors = []
        for line in output.splitlines():
            if 'error -' in line and ('const_eval_method_invocation' in line or 'undefined_identifier' in line or 'duplicate_definition' in line or 'implicit_this_reference_in_initializer' in line):
                # Format: lib\widgets\desktop\desktop_luxury_section.dart:376:21 - const_eval_method_invocation
                match = re.search(r'([a-zA-Z0-9_\\\/\.]+):(\d+):(\d+) - (const_eval_method_invocation|implicit_this_reference_in_initializer)', line)
                if match:
                    errors.append((match.group(1), int(match.group(2))))
                    
        if not errors:
            print("No more const_eval_method_invocation errors!")
            break
            
        print(f"Found {len(errors)} errors. Fixing...")
        
        files_to_fix = {}
        for file, lineno in errors:
            if file not in files_to_fix:
                files_to_fix[file] = []
            files_to_fix[file].append(lineno)
            
        for file, linenos in files_to_fix.items():
            with open(file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                
            for lineno in sorted(list(set(linenos)), reverse=True):
                # Look backwards from lineno (1-indexed)
                # First check if the error is due to an initializer with Theme.of
                # desktop_product_card.dart has this problem.
                # If Theme.of(context) is present, we remove `const ` backward.
                for i in range(lineno - 1, max(-1, lineno - 20), -1):
                    if 'const ' in lines[i]:
                        lines[i] = lines[i].replace('const ', '')
                        break
                        
            with open(file, 'w', encoding='utf-8') as f:
                f.writelines(lines)

if __name__ == '__main__':
    fix_errors()
