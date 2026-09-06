import os
path = 'scripts/hud.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s1 = '''func _on_tired_changed(is_tired: bool) -> void:'''
r1 = '''var _insomnia_tw: Tween
func _on_tired_changed(is_tired: bool) -> void:'''
content = content.replace(s1, r1)

s2 = '''		if crect and crect.material is ShaderMaterial:
			var tw = create_tween()
			tw.tween_method(func(val): crect.material.set_shader_parameter("insomnia_level", val), 0.0 if not is_tired else 0.8, 0.8 if is_tired else 0.0, 3.0)'''
r2 = '''		if crect and crect.material is ShaderMaterial:
			if _insomnia_tw != null and _insomnia_tw.is_valid():
				_insomnia_tw.kill()
			_insomnia_tw = create_tween()
			_insomnia_tw.tween_method(func(val): crect.material.set_shader_parameter("insomnia_level", val), 0.0 if not is_tired else 0.8, 0.8 if is_tired else 0.0, 3.0)'''
content = content.replace(s2, r2)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
