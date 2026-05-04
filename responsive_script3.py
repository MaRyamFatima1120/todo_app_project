import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # Remove const before SizedBox that has .h or .w
    content = re.sub(r'const\s+SizedBox\(([^)]*?(\.h|\.w|\.sp|\.r)[^)]*?)\)', r'SizedBox(\1)', content)
    
    # Remove const before EdgeInsets that has .r
    content = re.sub(r'const\s+EdgeInsets\.all\(([^)]*?\.r[^)]*?)\)', r'EdgeInsets.all(\1)', content)
    
    # Remove const before EdgeInsets.symmetric that has .h or .w
    content = re.sub(r'const\s+EdgeInsets\.symmetric\(([^)]*?(\.h|\.w)[^)]*?)\)', r'EdgeInsets.symmetric(\1)', content)

    # Remove const before EdgeInsets.only that has .h or .w
    content = re.sub(r'const\s+EdgeInsets\.only\(([^)]*?(\.h|\.w)[^)]*?)\)', r'EdgeInsets.only(\1)', content)
    
    # Remove const before BorderRadius that has .r
    content = re.sub(r'const\s+BorderRadius\.circular\(([^)]*?\.r[^)]*?)\)', r'BorderRadius.circular(\1)', content)
    
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
