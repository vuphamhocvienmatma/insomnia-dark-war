import os
path = 'shaders/lofi_post_process.gdshader'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s = '''		// Insomnia Shift
		if (insomnia_level > 0.0) {
			vec2 insom_shift = vec2(sin(TIME * 2.5) * 0.0008, cos(TIME * 1.5) * 0.0008) * insomnia_level;'''
r = '''		// Insomnia Shift
		if (insomnia_level > 0.01) {
			vec2 insom_shift = vec2(sin(TIME * 2.5) * 0.0008, cos(TIME * 1.5) * 0.0008) * insomnia_level;'''
content = content.replace(s, r)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
