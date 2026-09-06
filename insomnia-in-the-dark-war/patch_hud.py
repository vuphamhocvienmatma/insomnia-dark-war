content = open('scripts/hud.gd', encoding='utf-8').read()

# 1. Add _insomnia_tw tween conflict fix
old = 'func _on_tired_changed(is_tired: bool) -> void:'
new = 'var _insomnia_tw: Tween\nfunc _on_tired_changed(is_tired: bool) -> void:'
content = content.replace(old, new, 1)

old2 = '''		if crect and crect.material is ShaderMaterial:
			var tw = create_tween()
			tw.tween_method(func(val): crect.material.set_shader_parameter("insomnia_level", val), 0.0 if not is_tired else 0.8, 0.8 if is_tired else 0.0, 3.0)'''
new2 = '''		if crect and crect.material is ShaderMaterial:
			if _insomnia_tw != null and _insomnia_tw.is_valid():
				_insomnia_tw.kill()
			_insomnia_tw = create_tween()
			_insomnia_tw.tween_method(func(val): crect.material.set_shader_parameter("insomnia_level", val), 0.0 if not is_tired else 0.8, 0.8 if is_tired else 0.0, 3.0)'''
content = content.replace(old2, new2, 1)

# 2. Add _pulse_tween fix
old3 = '''func _pulse(ln: Label) -> void:
	if not stats_panel.visible:
		return
	ln.scale = Vector2(1.05, 1.05)
	var tw: Tween = create_tween()
	tw.tween_property(ln, "scale", Vector2.ONE, 0.12)'''
new3 = '''var _pulse_tween: Tween
func _pulse(ln: Label) -> void:
	if not stats_panel.visible:
		return
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	ln.scale = Vector2(1.05, 1.05)
	_pulse_tween = create_tween()
	_pulse_tween.tween_property(ln, "scale", Vector2.ONE, 0.12)'''
content = content.replace(old3, new3, 1)

# 3. Remove _last_solar_text and solar_text assignment (copy-paste bug)
content = content.replace('var _last_solar_text: String = ""\n', '')
content = content.replace(
    '''			var new_solar_text: String = chr(0x26a1) + " Solar: " + str(sol_int) + "%"
			if new_solar_text != _last_solar_text and solar_text != null:
				_last_solar_text = new_solar_text
				solar_text.text = new_solar_text''',
    ''
)
content = content.replace(
    '''		if solar_text != null:
			solar_text.text = chr(0x26a1) + " Solar: " + str(int(new_amount)) + "%"''',
    ''
)

with open('scripts/hud.gd', 'w', encoding='utf-8') as f:
    f.write(content)

print('Done')
print('Has _insomnia_tw:', '_insomnia_tw' in content)
print('Has _pulse_tween:', '_pulse_tween' in content)
