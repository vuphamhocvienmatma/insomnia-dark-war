import os

path = 'scripts/hud.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Remove _last_solar_text logic
content = content.replace('var _last_solar_text: String = ""\n', '')
content = content.replace('''			var new_solar_text: String = "⚡ Solar: " + str(sol_int) + "%"
			if new_solar_text != _last_solar_text and solar_text != null:
				_last_solar_text = new_solar_text
				solar_text.text = new_solar_text''', '')

# 2. Tween conflict in _on_tired_changed
s_tired = '''func _on_tired_changed(is_tired: bool) -> void:'''
r_tired = '''var _insomnia_tw: Tween
func _on_tired_changed(is_tired: bool) -> void:'''
content = content.replace(s_tired, r_tired)

s_tired2 = '''		if crect and crect.material is ShaderMaterial:
			var tw = create_tween()
			tw.tween_method(func(val): crect.material.set_shader_parameter("insomnia_level", val), 0.0 if not is_tired else 0.8, 0.8 if is_tired else 0.0, 3.0)'''
r_tired2 = '''		if crect and crect.material is ShaderMaterial:
			if _insomnia_tw != null and _insomnia_tw.is_valid():
				_insomnia_tw.kill()
			_insomnia_tw = create_tween()
			_insomnia_tw.tween_method(func(val): crect.material.set_shader_parameter("insomnia_level", val), 0.0 if not is_tired else 0.8, 0.8 if is_tired else 0.0, 3.0)'''
content = content.replace(s_tired2, r_tired2)

# 3. Tween leak in _pulse
s_pulse = '''func _pulse(ln: Label) -> void:
	if not stats_panel.visible:
		return
	ln.scale = Vector2(1.05, 1.05)
	var tw: Tween = create_tween()
	tw.tween_property(ln, "scale", Vector2.ONE, 0.12)'''
r_pulse = '''var _pulse_tween: Tween
func _pulse(ln: Label) -> void:
	if not stats_panel.visible:
		return
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	ln.scale = Vector2(1.05, 1.05)
	_pulse_tween = create_tween()
	_pulse_tween.tween_property(ln, "scale", Vector2.ONE, 0.12)'''
content = content.replace(s_pulse, r_pulse)

# 4. Remove solar_text logic in _on_solar_changed
s_solar = '''func _on_solar_changed(new_amount: float) -> void:
	if solar_bar != null:
		solar_bar.value = new_amount
	if solar_text != null:
		solar_text.text = "⚡ Solar: " + str(int(new_amount)) + "%"'''
r_solar = '''func _on_solar_changed(new_amount: float) -> void:
	if solar_bar != null:
		solar_bar.value = new_amount'''
content = content.replace(s_solar, r_solar)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
