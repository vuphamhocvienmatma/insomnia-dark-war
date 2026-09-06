import os

def fix_mojibake(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        return False
        
    changed = False
    new_lines = []
    for line in lines:
        try:
            b = line.encode('cp1252')
            new_line = b.decode('utf-8')
            if new_line != line:
                changed = True
            new_lines.append(new_line)
        except (UnicodeEncodeError, UnicodeDecodeError):
            new_lines.append(line)
            
    if changed:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
        return True
    return False

files = [
    'scripts/art_cabin_props.gd',
    'scripts/companion_cat.gd',
    'scripts/hud.gd'
]

for file in files:
    iterations = 0
    while fix_mojibake(file) and iterations < 5:
        iterations += 1
        print("Fixed layer", iterations, "for", file)
