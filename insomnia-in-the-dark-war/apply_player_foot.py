import os
path = 'scripts/player.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s1 = '''var ladder_prompt: Label'''
r1 = '''var ladder_prompt: Label

var _footprint_timer: float = 0.0'''
content = content.replace(s1, r1)

s2 = '''	if direction != Vector2.ZERO:
		direction = direction.normalized()'''
r2 = '''	if direction != Vector2.ZERO:
		direction = direction.normalized()
		_footprint_timer -= _delta
		if _footprint_timer <= 0.0:
			_footprint_timer = 0.35 # Step interval
			var ground = get_tree().get_first_node_in_group("ground_props")
			if ground and ground.has_method("add_decal"):
				ground.call("add_decal", "footprint", global_position)'''
content = content.replace(s2, r2)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated player footprints")
