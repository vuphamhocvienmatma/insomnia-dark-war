import os
path = 'scripts/player.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s = '''		# In cabin
		if position.x > -180.0 and position.x < 180.0:
			sound_text = "cộc cộc"
		elif w == "snowstorm":
			sound_text = "xộp xộp"
		elif w == "heavy_rain" or w == "drizzle":
			sound_text = "lép nhép"
			
		_spawn_floating_text(sound_text, Color(0.8, 0.8, 0.8, 0.6))'''
r = '''		# In cabin
		var am = get_tree().get_first_node_in_group("audio_manager")
		var pitch = 1.0
		var fx_name = "footstep"
		
		if position.x > -180.0 and position.x < 180.0:
			sound_text = "cộc cộc"
			pitch = 0.8 # Wood sound simulation
		elif w == "snowstorm":
			sound_text = "xộp xộp"
			pitch = 1.2
		elif w == "heavy_rain" or w == "drizzle":
			sound_text = "lép nhép"
			pitch = 1.1
		else:
			pitch = 1.4 # Sand simulation
			
		if am and am.has_method("play_sfx"):
			am.call("play_sfx", fx_name, global_position, pitch)
			
		_spawn_floating_text(sound_text, Color(0.8, 0.8, 0.8, 0.6))'''
content = content.replace(s, r)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
