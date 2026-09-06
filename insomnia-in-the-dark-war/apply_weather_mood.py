import os

path = 'scripts/art_weather.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s1 = '''			tm.phase_changed.connect(_on_phase_changed)'''
r1 = '''			tm.phase_changed.connect(_on_phase_changed)
		if tm.has_signal("mood_changed"):
			tm.mood_changed.connect(_on_mood_changed)'''
content = content.replace(s1, r1)

s2 = '''func _on_phase_changed(is_night: bool) -> void:
	pass # Weather persists through day/night in this version, handled by level_setup'''
r2 = '''func _on_phase_changed(is_night: bool) -> void:
	pass

func _on_mood_changed(mood: String) -> void:
	if not pp_mat: return
	if mood == "insomnia":
		pp_mat.set_shader_parameter("tint_amount", 0.5)
		pp_mat.set_shader_parameter("vignette_intensity", 0.6)
		pp_mat.set_shader_parameter("grain_amount", 0.4)
	elif mood == "nightmare":
		pp_mat.set_shader_parameter("tint_color", Color(0.8, 0.2, 0.2))
		pp_mat.set_shader_parameter("tint_amount", 0.4)
		pp_mat.set_shader_parameter("vignette_intensity", 0.5)
		pp_mat.set_shader_parameter("aberration_amount", 1.2)'''
content = content.replace(s2, r2)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Connected mood to art_weather")
