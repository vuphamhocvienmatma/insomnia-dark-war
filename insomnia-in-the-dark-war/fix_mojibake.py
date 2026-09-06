import os
import glob

def fix_mojibake(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        return
        
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
        print("Fixed mojibake in", filepath)

files = [
    'project.godot',
    'scenes/cooking_modal.tscn',
    'scripts/art_cabin_props.gd',
    'scripts/cabin_door.gd',
    'scripts/companion_cat.gd',
    'scripts/hud.gd',
    'scripts/mailbox_manager.gd',
    'scripts/time_manager.gd',
    'scripts/zombie_ai.gd'
]

for file in files:
    if os.path.exists(file):
        fix_mojibake(file)
