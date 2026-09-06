import os
path = 'scripts/art_cabin_front.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s1 = '''func _draw_porch_light(a: float) -> void:
	var px: float = 120.0
	var py: float = -100.0'''
r1 = '''func _draw_porch_light(a: float) -> void:
	var px: float = 120.0
	var py: float = -100.0
	
	# Sway logic
	var sway = sin(_time * 1.5) * 4.0
	px += sway
	py += abs(sway) * 0.2
	
	# Rope
	draw_line(Vector2(120.0, -145.0), Vector2(px, py), Color(0.1, 0.1, 0.1, a), 2.0)'''
content = content.replace(s1, r1)

s2 = '''func _draw() -> void:
	var a: float = 1.0
	
	_draw_wall(a)'''
r2 = '''func _draw() -> void:
	var a: float = 1.0
	
	_draw_wall(a)
	
	# Soft Occlusion Shadows
	var eco = false
	if GameState != null and GameState.eco_mode: eco = true
	if not eco:
		# Porch roof shadow
		draw_rect(Rect2(132.0, -96.0, 60.0, 114.0), Color(0.0, 0.0, 0.0, 0.3))
		# Table/bench shadow
		draw_rect(Rect2(20.0, -10.0, 60.0, 20.0), Color(0.0, 0.0, 0.0, 0.4))
'''
content = content.replace(s2, r2)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated art_cabin_front")
