import os

path = 'scripts/time_manager.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s1 = '''signal sunset_warning'''
r1 = '''signal sunset_warning
signal mood_changed(mood_name: String)

var current_mood: String = ""'''
content = content.replace(s1, r1)

s2 = '''		if ratio < 0.65:
			# Morning to late afternoon golden transition'''
r2 = '''		var new_mood: String = "dawn"
		if ratio > 0.3 and ratio <= 0.65:
			new_mood = "golden"
		elif ratio > 0.65:
			new_mood = "dusk"
			
		if new_mood != current_mood:
			current_mood = new_mood
			mood_changed.emit(current_mood)
			
		if ratio < 0.65:
			# Morning to late afternoon golden transition'''
content = content.replace(s2, r2)

s3 = '''func transition_to_night() -> void:
	is_night = true
	time_elapsed = 0.0
	phase_changed.emit(true)'''
r3 = '''func transition_to_night() -> void:
	is_night = true
	time_elapsed = 0.0
	phase_changed.emit(true)
	
	# Handle night moods based on game state
	current_mood = "night"
	if GameState.is_tired:
		current_mood = "insomnia"
	
	var ls = get_node_or_null("/root/LevelSetup")
	if ls != null:
		if ls.get("current_night_mutation") != "":
			current_mood = "nightmare"
			
	mood_changed.emit(current_mood)'''
content = content.replace(s3, r3)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Added mood system to time_manager.gd")
