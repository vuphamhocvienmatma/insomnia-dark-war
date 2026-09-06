import os
path = 'scripts/audio_manager.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s = '''func play_sfx(sfx_name: String, pos: Vector2 = Vector2.ZERO) -> void:
	var sfx_path: String = "res://assets/sfx/" + sfx_name + ".ogg"'''
r = '''func play_sfx(sfx_name: String, pos: Vector2 = Vector2.ZERO, custom_pitch: float = 1.0) -> void:
	var sfx_path: String = "res://assets/sfx/" + sfx_name + ".ogg"'''
content = content.replace(s, r)

s2 = '''	if player != null:
		player.play()'''
r2 = '''	if player != null:
		player.pitch_scale = custom_pitch
		player.play()'''
content = content.replace(s2, r2)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
