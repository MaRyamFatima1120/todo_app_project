import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # BorderRadius.circular(10) -> BorderRadius.circular(10.r)
    # Check if already has .r to avoid 10.r.r
    content = re.sub(r'BorderRadius\.circular\(\s*([0-9.]+)(?!\.r)\s*\)', r'BorderRadius.circular(\1.r)', content)
    
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
