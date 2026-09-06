import os
path = 'scripts/mailbox_ui.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s1 = '''var current_letter: Dictionary = {}
var _typewriter_tween: Tween'''
r1 = '''var current_letter: Dictionary = {}
var _typewriter_tween: Tween
var _am: Node = null'''
content = content.replace(s1, r1)

s2 = '''func _ready() -> void:
	z_index = 100'''
r2 = '''func _ready() -> void:
	z_index = 100
	_am = get_tree().get_first_node_in_group("audio_manager")'''
content = content.replace(s2, r2)

s3 = '''func _typewriter_step(val: int) -> void:
	var prev = content_lbl.visible_characters
	content_lbl.visible_characters = val
	if val > prev:
		# Play sound
		var am: Node = get_tree().get_first_node_in_group("audio_manager")
		if am and am.has_method("play_sfx"): am.call("play_sfx", "typewriter_tick")'''
r3 = '''func _typewriter_step(val: int) -> void:
	var prev = content_lbl.visible_characters
	content_lbl.visible_characters = val
	if val > prev:
		# Play sound
		if _am == null: _am = get_tree().get_first_node_in_group("audio_manager")
		if _am and _am.has_method("play_sfx"): _am.call("play_sfx", "typewriter_tick")'''
content = content.replace(s3, r3)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
