import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # Add import if needed
    if 'package:flutter_screenutil/flutter_screenutil.dart' not in content and ('Get.height' in content or 'Get.width' in content or 'height:' in content or 'fontSize:' in content):
        if 'import \'package:flutter/material.dart\';' in content:
            content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter_screenutil/flutter_screenutil.dart';")
        elif 'import "package:flutter/material.dart";' in content:
            content = content.replace('import "package:flutter/material.dart";', 'import "package:flutter/material.dart";\nimport "package:flutter_screenutil/flutter_screenutil.dart";')

    # Get.height / Get.width replacements
    content = re.sub(r'Get\.height\s*\*\s*([0-9.]+)', r'\1.sh', content)
    content = re.sub(r'Get\.width\s*\*\s*([0-9.]+)', r'\1.sw', content)
    content = re.sub(r'Get\.height', r'1.sh', content)
    content = re.sub(r'Get\.width', r'1.sw', content)
    
    # Basic size replacements
    # Be careful not to replace something like height: 1.sh -> height: 1.sh.h
    content = re.sub(r'height:\s*([0-9]+)\s*,', r'height: \1.h,', content)
    content = re.sub(r'width:\s*([0-9]+)\s*,', r'width: \1.w,', content)
    content = re.sub(r'radius:\s*([0-9]+)\s*,', r'radius: \1.r,', content)
    content = re.sub(r'fontSize:\s*([0-9]+)\s*,', r'fontSize: \1.sp,', content)
    content = re.sub(r'fontSize:\s*([0-9]+)\s*\)', r'fontSize: \1.sp)', content)
    content = re.sub(r'size:\s*([0-9]+)\s*,', r'size: \1.sp,', content)
    
    # SizedBox(height: 20)
    content = re.sub(r'SizedBox\(height:\s*([0-9]+)\)', r'SizedBox(height: \1.h)', content)
    content = re.sub(r'SizedBox\(width:\s*([0-9]+)\)', r'SizedBox(width: \1.w)', content)

    # EdgeInsets.all(20)
    content = re.sub(r'EdgeInsets\.all\(\s*([0-9]+)\s*\)', r'EdgeInsets.all(\1.r)', content)
    
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            # skip main.dart as we already did it manually
            if 'main.dart' in file:
                continue
            process_file(os.path.join(root, file))
