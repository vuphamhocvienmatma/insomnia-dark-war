import os
path = 'scripts/art_lighting.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('var fire_pos = Vector2(-22, -22)', 'var fire_pos = Vector2(-80, -35)')

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
