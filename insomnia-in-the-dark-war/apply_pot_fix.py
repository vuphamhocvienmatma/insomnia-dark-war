import os
path = 'scripts/plant_pot.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s1 = '''var current_state: PotState = PotState.EMPTY
var growth_timer: float = 0.0'''
r1 = '''var current_state: PotState = PotState.EMPTY
var growth_timer: float = 0.0
var _harvest_label: Label = null'''
content = content.replace(s1, r1)

s2 = '''func _ready() -> void:
	add_to_group("plant_pot")
	art_node.set_state("empty")'''
r2 = '''func _ready() -> void:
	add_to_group("plant_pot")
	art_node.set_state("empty")
	_harvest_label = Label.new()
	_harvest_label.text = "+2"
	_harvest_label.visible = false
	add_child(_harvest_label)'''
content = content.replace(s2, r2)

s3 = '''	# Bezier Curve Juice (Fake carrot flying)
	var carrot = Label.new()
	carrot.text = "??"
	carrot.global_position = global_position
	get_tree().root.add_child(carrot)
	var player = get_tree().get_first_node_in_group("player")
	var target = player.global_position if player else global_position + Vector2(0, -50)
	var tw = create_tween().set_parallel(true)
	tw.tween_property(carrot, "global_position:x", target.x, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(carrot, "global_position:y", target.y - 40.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.chain().tween_callback(func(): carrot.queue_free())'''
r3 = '''	# Bezier Curve Juice with pre-allocated Label
	_harvest_label.visible = true
	_harvest_label.position = Vector2.ZERO
	var player = get_tree().get_first_node_in_group("player")
	var target = (player.global_position - global_position) if player else Vector2(0, -50)
	var tw = create_tween().set_parallel(true)
	tw.tween_property(_harvest_label, "position:x", target.x, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(_harvest_label, "position:y", target.y - 40.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.chain().tween_callback(func(): _harvest_label.visible = false)'''
content = content.replace(s3, r3)

s4 = '''		if GameState != null and GameState.relics_found.has("miracle_watering_can"):
			growth_speed *= 1.5'''
r4 = '''		if GameState != null and GameState.relics_found.has("miracle_watering_can"):
			growth_speed *= 1.5
		
		# God Rays bonus
		var tm = get_tree().get_first_node_in_group("time_manager")
		if tm and not bool(tm.get("is_night")) and float(tm.get("shadow_intensity")) > 0.5:
			if global_position.x > -60.0 and global_position.x < 60.0:
				growth_speed *= 2.0'''
content = content.replace(s4, r4)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
