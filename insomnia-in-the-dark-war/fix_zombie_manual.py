import re

with open('scripts/zombie_ai.gd', encoding='utf-8') as f:
    content = f.read()

# Replace broken toast calls
content = content.replace(
    chr(0xfffd) + chr(0xa0) + chr(0xfffd) + chr(0x8f) + ' Ten trom Thief da cuom',
    '⚠️ Tên trộm Thief đã cuỗm'
)

# Check for the corrupt marker ⚠
import re
content = re.sub(
    r'show_toast\", \"[^\x20-\x7e\u00a0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+Tên trộm',
    'show_toast\", \"⚠️ Tên trộm',
    content
)
content = re.sub(
    r'show_toast\", \"[^\x20-\x7e\u00a0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+[Ã\x80-\xbf]+\s*hạ gục',
    'show_toast\", \"🎉 Đã hạ gục',
    content
)

# Simple targeted fix: find lines with corrupt text before 'hạ gục' or 'Thief'
lines = content.splitlines(keepends=True)
new_lines = []
for line in lines:
    if 'Thief' in line and 'show_toast' in line and '\ufffd' in line:
        line = re.sub(r'\"[^\"]{0,10}Tên trộm', '"⚠️ Tên trộm', line)
    if 'hạ gục' in line and 'show_toast' in line and '\ufffd' in line:
        line = re.sub(r'\"[^\"]{0,10}Đã hạ gục', '"🎉 Đã hạ gục', line)
    new_lines.append(line)
    
content = ''.join(new_lines)

with open('scripts/zombie_ai.gd', 'w', encoding='utf-8') as f:
    f.write(content)

print('Done. Corrupt:', 'Ã' in content, '| \ufffd:', '\ufffd' in content)
