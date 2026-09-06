import os
path = 'scripts/zombie_ai.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s1 = '''var current_target_fence: Node2D = null'''
r1 = '''var current_target_fence: Node2D = null
var _footprint_timer: float = 0.0'''
content = content.replace(s1, r1)

s2 = '''	position.x += dir * current_speed * _delta
	
	queue_redraw()'''
r2 = '''	position.x += dir * current_speed * _delta
	
	_footprint_timer -= _delta
	if _footprint_timer <= 0.0:
		_footprint_timer = 0.5
		var ground = get_tree().get_first_node_in_group("ground_props")
		if ground and ground.has_method("add_decal"):
			ground.call("add_decal", "footprint", global_position, {"is_brute": zombie_type == "brute"})
	
	queue_redraw()'''
content = content.replace(s2, r2)

s3 = '''		if cam != null and cam.has_method("trigger_shake"):
			var shake_pwr: float = 14.0 if zombie_type == "brute" else 6.0
			cam.call("trigger_shake", shake_pwr)'''
r3 = '''		if cam != null and cam.has_method("trigger_shake"):
			var shake_pwr: float = 14.0 if zombie_type == "brute" else 6.0
			cam.call("trigger_shake", shake_pwr)
		
		var ground = get_tree().get_first_node_in_group("ground_props")
		if ground and ground.has_method("add_decal"):
			ground.call("add_decal", "scratch", global_position + Vector2(randf_range(-10, 10), 0))'''
content = content.replace(s3, r3)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
