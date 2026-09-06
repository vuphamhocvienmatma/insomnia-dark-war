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
cnt = fixed.count(chr(0xc3))
with open('scripts/hud_check.txt', 'w', encoding='utf-8') as f:
    f.write(fixed)
# Find the line with issue
for i, line in enumerate(fixed.splitlines()):
    if chr(0xc3) in line:
        with open('corrupt_sample.txt', 'w', encoding='utf-8') as f:
            f.write(repr(line))
        break
print('Count:', cnt)
