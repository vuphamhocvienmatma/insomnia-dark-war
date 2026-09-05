extends StaticBody2D

signal door_state_changed(is_open: bool)
signal door_reinforced(level: int)

@export var is_open: bool = false
@export var reinforce_level: int = 1
@export var hp: float = 100.0
@export var max_hp: float = 100.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var prompt: Label = $Prompt
@onready var art: Node2D = $Art

var is_player_near: bool = false
var _swing_angle: float = 0.0

func _ready() -> void:
	add_to_group("cabin_door")
	add_to_group("defensive_wall")
	_swing_angle = 1.0 if is_open else 0.0
	if art != null and art.has_method("set_swing"):
		art.call("set_swing", _swing_angle)
	_update_collision()
	_update_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if not is_player_near:
		return

	# E key: Open / Close door
	if event.is_action_pressed("interact"):
		toggle_door()
		get_viewport().set_input_as_handled()

	# R key: Reinforce door
	elif event is InputEventKey:
		var ek: InputEventKey = event as InputEventKey
		if ek.pressed and not ek.echo and ek.keycode == KEY_R:
			reinforce_door()
			get_viewport().set_input_as_handled()


func toggle_door() -> void:
	is_open = not is_open
	_update_collision()
	_update_prompt()
	door_state_changed.emit(is_open)

	if art != null:
		var tw = create_tween()
		tw.tween_method(func(val: float) -> void:
			_swing_angle = val
			if art.has_method("set_swing"):
				art.call("set_swing", val)
			art.queue_redraw()
		, _swing_angle, 1.0 if is_open else 0.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var am: Node = get_tree().get_first_node_in_group("audio_manager")
	if am != null and am.has_method("play_sfx"):
		am.call("play_sfx", "wood_creak")

	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_toast"):
		if is_open:
			hud.call("show_toast", "🚪 Cửa cabin đã mở", 2.0, false)
		else:
			hud.call("show_toast", "🔒 Cửa cabin đã đóng chốt an toàn", 2.0, false)


func reinforce_door() -> void:
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if reinforce_level == 1:
		if GameState.scrap_count < 10:
			if hud != null and hud.has_method("show_toast"):
				hud.call("show_toast", "❌ Cần 10 Phế liệu để gia cố Cấp 2!", 2.5, true)
			return
		GameState.spend_scrap(10)
		reinforce_level = 2
		max_hp = 250.0
		hp = max_hp
		door_reinforced.emit(2)
		if hud != null and hud.has_method("show_toast"):
			hud.call("show_toast", "🛡️ Đã gia cố Cấp 2: Nẹp Sắt Cường Lực (250 HP)!", 3.5, false)

	elif reinforce_level == 2:
		if GameState.scrap_count < 25:
			if hud != null and hud.has_method("show_toast"):
				hud.call("show_toast", "❌ Cần 25 Phế liệu để gia cố Cấp 3!", 2.5, true)
			return
		GameState.spend_scrap(25)
		reinforce_level = 3
		max_hp = 500.0
		hp = max_hp
		door_reinforced.emit(3)
		if hud != null and hud.has_method("show_toast"):
			hud.call("show_toast", "🛡️ Đã gia cố Cấp 3: Cửa Thiết Giáp Tận Thế (500 HP)!", 3.5, false)

	else:
		if hp < max_hp:
			if GameState.scrap_count < 5:
				if hud != null and hud.has_method("show_toast"):
					hud.call("show_toast", "❌ Cần 5 Phế liệu để sửa chữa cửa!", 2.5, true)
				return
			GameState.spend_scrap(5)
			hp = max_hp
			if hud != null and hud.has_method("show_toast"):
				hud.call("show_toast", "🔧 Đã sửa chữa cửa phục hồi 100% HP!", 2.5, false)
		else:
			if hud != null and hud.has_method("show_toast"):
				hud.call("show_toast", "✨ Cửa đã đạt cấp độ tối đa!", 2.5, false)

	_update_prompt()
	if art != null:
		art.queue_redraw()


func take_damage(amount: float) -> void:
	if is_open:
		return

	hp = maxf(hp - amount, 0.0)
	var cam: Node = get_tree().get_first_node_in_group("main_camera")
	if cam != null and cam.has_method("trigger_shake"):
		cam.call("trigger_shake", 1.8)

	if hp <= 0.0:
		is_open = true
		_update_collision()
		
		if art != null:
			var tw = create_tween()
			tw.tween_method(func(val: float) -> void:
				_swing_angle = val
				if art.has_method("set_swing"):
					art.call("set_swing", val)
				art.queue_redraw()
			, _swing_angle, 1.0, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			
		var am: Node = get_tree().get_first_node_in_group("audio_manager")
		if am != null and am.has_method("play_sfx"):
			am.call("play_sfx", "wall_break")

		var hud: Node = get_tree().get_first_node_in_group("hud")
		if hud != null and hud.has_method("show_toast"):
			hud.call("show_toast", "⚠️ CỬA CHÍNH ĐÃ BỊ ZOMBIE PHÁ THỦNG!", 4.0, true)
			
	_update_prompt()
	if art != null:
		art.queue_redraw()


func _update_collision() -> void:
	if collision_shape != null:
		collision_shape.set_deferred("disabled", is_open)


func _update_prompt() -> void:
	if prompt == null:
		return
	if not is_player_near:
		prompt.visible = false
		return

	prompt.visible = true
	var state_txt: String = "Đóng" if is_open else "Mở"
	var cost_txt: String = ""
	if reinforce_level == 1:
		cost_txt = "[R] Gia cố C2 (10 Phế liệu)"
	elif reinforce_level == 2:
		cost_txt = "[R] Gia cố C3 (25 Phế liệu)"
	elif hp < max_hp:
		cost_txt = "[R] Sửa cửa (5 Phế liệu)"
	else:
		cost_txt = "Cấp Tối Đa"

	prompt.text = "🚪 [E/Click] " + state_txt + " cửa (" + str(int(hp)) + "/" + str(int(max_hp)) + " HP)\n🔨 " + cost_txt


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = true
		_update_prompt()


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = false
		_update_prompt()