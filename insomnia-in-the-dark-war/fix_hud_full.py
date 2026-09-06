import subprocess

def fix_mojibake_loop(text, max_iter=5):
    for _ in range(max_iter):
        lines = text.splitlines(keepends=True)
        out = []
        changed = False
        for line in lines:
            try:
                b = line.encode('cp1252')
                nl = b.decode('utf-8')
                if nl != line:
                    changed = True
                out.append(nl)
            except:
                out.append(line)
        text = ''.join(out)
        if not changed:
            break
    return text

data = subprocess.check_output(['git', 'show', 'd459547:insomnia-in-the-dark-war/scripts/hud.gd'])
text = data.decode('utf-8')
fixed = fix_mojibake_loop(text)

# Handle the one stubborn line manually - 'ĐÊM ĐÃ XUỐNG'
import re
fixed = fixed.replace(
    'âš ï¸ ÄÃŠM ÄÃƒ XUá»NG!',
    '⚠️ ĐÊM ĐÃ XUỐNG!'
)

with open('scripts/hud.gd', 'w', encoding='utf-8') as f:
    f.write(fixed)

cnt = fixed.count(chr(0xc3))
print('Remaining Ã count:', cnt)
print('Done')
