import os
path = 'scripts/level_setup.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s1 = '''const GROUND_PROPS_SCRIPT := preload("res://scripts/art_ground_props.gd")'''
r1 = '''const GROUND_PROPS_SCRIPT := preload("res://scripts/art_ground_props.gd")
const LIGHTING_SCRIPT := preload("res://scripts/art_lighting.gd")'''
content = content.replace(s1, r1)

s2 = '''	_weather = weather'''
r2 = '''	_weather = weather
	
	var lighting = Node2D.new()
	lighting.name = "Lighting"
	lighting.set_script(LIGHTING_SCRIPT)
	add_child(lighting)'''
content = content.replace(s2, r2)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Added art_lighting to level_setup")
