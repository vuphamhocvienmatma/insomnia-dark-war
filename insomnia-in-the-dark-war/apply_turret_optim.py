import os
path = 'scripts/auto_turret.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s1 = '''var current_target: CharacterBody2D = null
var targets_in_range: Array[CharacterBody2D] = []'''
r1 = '''var current_target: CharacterBody2D = null
var targets_in_range: Array[CharacterBody2D] = []
var _tracers: Array[Dictionary] = []'''
content = content.replace(s1, r1)

s2 = '''		current_target.call("take_damage", final_damage)
		
		var line := Line2D.new()
		line.add_point(Vector2.ZERO)
		line.add_point(current_target.global_position - global_position)
		line.width = 3.0
		line.default_color = Color(1.0, 0.5, 0.0, 0.8)
		add_child(line)
		get_tree().create_timer(0.1).timeout.connect(line.queue_free)'''
r2 = '''		current_target.call("take_damage", final_damage)
		
		# Zero-allocation hitscan tracer
		var to_local_pos = current_target.global_position - global_position
		_tracers.append({"end_pos": to_local_pos, "ttl": 0.05})
		queue_redraw()'''
content = content.replace(s2, r2)

# Now inject into _process
# Wait, auto_turret.gd doesn't have _process yet.
process_code = '''
func _process(delta: float) -> void:
	if _tracers.size() > 0:
		var needs_redraw = false
		for i in range(_tracers.size() - 1, -1, -1):
			_tracers[i].ttl -= delta
			if _tracers[i].ttl <= 0:
				_tracers.remove_at(i)
			needs_redraw = true
		if needs_redraw:
			queue_redraw()

func _draw() -> void:'''

content = content.replace("func _draw() -> void:", process_code)

s3 = '''				# Contact shadow
				draw_circle(Vector2(0, 0), w/1.5, Color(0,0,0,0.5))'''
r3 = '''				# Contact shadow
				draw_circle(Vector2(0, 0), w/1.5, Color(0,0,0,0.5))
				
	# Draw active tracers
	for tracer in _tracers:
		draw_line(Vector2.ZERO, tracer.end_pos, Color(1.0, 0.5, 0.0, 0.8), 3.0)'''
content = content.replace(s3, r3)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated auto_turret.gd")
