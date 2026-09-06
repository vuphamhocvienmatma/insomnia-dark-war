import os

def add_shadows(filepath, is_player=False):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "func _draw() -> void:" not in content:
        print(f"Skipping {filepath} - no _draw")
        return
        
    draw_code = '''	var eco = false
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
				
				# Directional shadow (Skewed)
				var h = 30.0
				var w = 12.0
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
    content = content.replace("func _draw() -> void:\n", "func _draw() -> void:\n" + draw_code)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Updated {filepath}")

add_shadows('scripts/player.gd', True)
add_shadows('scripts/zombie_ai.gd', False)
add_shadows('scripts/auto_turret.gd', False)
