import os
path = 'scripts/auto_turret.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s1 = '''			am.call("play_sfx", "turret_shoot")'''
r1 = '''			am.call("play_sfx", "turret_shoot")
			
		var ground = get_tree().get_first_node_in_group("ground_props")
		if ground and ground.has_method("add_decal"):
			# Bullet casings or impact mark near target
			ground.call("add_decal", "bullet", target.global_position + Vector2(randf_range(-15, 15), 0))'''
content = content.replace(s1, r1)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
