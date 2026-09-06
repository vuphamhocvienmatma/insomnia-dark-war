import os

def add_shadow_code(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # If it already has _draw, skip (auto_turret maybe?)
    if "func _draw()" in content or "func _draw() -> void:" in content:
        # For auto_turret, it might have _draw already
        pass

    draw_code = '''
func _draw() -> void:
	var eco = false
	if GameState != null and GameState.eco_mode: eco = true
	
	if not eco:
		var tm = get_tree().get_first_node_in_group("time_manager")
		if tm != null:
			var is_night = bool(tm.get("is_night"))
			var sun_ang = tm.get("sun_angle")
			var sh_int = float(tm.get("shadow_intensity"))
			if sh_int > 0.05:
				var sh_col = Color(0, 0, 0, 0.4 * sh_int)
				if is_night: sh_col = Color(0.1, 0.1, 0.3, 0.5 * sh_int)
				
				# Directional shadow
				var h = 30.0
				var w = 16.0
				var dx = sun_ang.x * h
				var pts = PackedVector2Array([
					Vector2(-w/2, 0),
					Vector2(w/2, 0),
					Vector2(w/2 + dx, -h * 0.3),
					Vector2(-w/2 + dx, -h * 0.3)
				])
				draw_colored_polygon(pts, sh_col)
				
				# Contact shadow
				draw_circle(Vector2(0, 0), w/1.5, Color(0,0,0,0.5))
'''

    if "func _draw" not in content:
        content += "\n" + draw_code
        # Add queue_redraw to _physics_process
        if "func _physics_process" in content:
            content = content.replace("func _physics_process", "func _physics_process(_delta: float) -> void:\n\tqueue_redraw()\nfunc _old_physics")
            content = content.replace("func _old_physics(_delta: float) -> void:", "func _physics_process_actual(_delta: float) -> void:")
            # wait, safer way:
            import re
            content = re.sub(r'func _physics_process\(([^)]*)\)\s*->\s*void:', r'func _physics_process(\1) -> void:\n\tqueue_redraw()', content)
        elif "func _process" in content:
            import re
            content = re.sub(r'func _process\(([^)]*)\)\s*->\s*void:', r'func _process(\1) -> void:\n\tqueue_redraw()', content)
    else:
        # If it has _draw, append the shadow code at the start of _draw
        import re
        shadow_inner = draw_code.replace("func _draw() -> void:\n", "")
        content = re.sub(r'func _draw\(\)\s*->\s*void:', 'func _draw() -> void:\n' + shadow_inner, content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Updated {filepath}")

add_shadow_code('scripts/player.gd')
add_shadow_code('scripts/zombie_ai.gd')
add_shadow_code('scripts/auto_turret.gd')
add_shadow_code('scripts/merchant_dog.gd')
