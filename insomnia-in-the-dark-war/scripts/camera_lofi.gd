extends Camera2D

const CAM_Y: float = -120.0
const CABIN_HALF_WIDTH: float = 220.0

var shake_intensity: float = 0.0
var shake_decay: float = 5.0
var _sway_time: float = 0.0


var _player: Node2D = null


func _ready() -> void:
	add_to_group("main_camera")
	top_level = true
	position = Vector2(0.0, CAM_Y)
	zoom = Vector2(1.05, 1.05)
	_player = get_tree().get_first_node_in_group("player") as Node2D


func _process(delta: float) -> void:
	if _player == null:
		_player = get_parent() as Node2D
		if _player == null or not _player.is_in_group("player"):
			_player = get_tree().get_first_node_in_group("player") as Node2D

	var is_in_cabin: bool = false
	
	if _player != null:
		global_position.x = lerpf(global_position.x, _player.global_position.x, 3.5 * delta)
		global_position.x = clampf(global_position.x, -2800.0, 2800.0)
		is_in_cabin = absf(_player.global_position.x) < CABIN_HALF_WIDTH
		
	# Solid steady camera height
	global_position.y = CAM_Y
	
	# Contextual base zoom + User manual zoom offset
	var base_zoom_val: float = 1.05 if is_in_cabin else 0.95
	var target_zoom_val: float = clampf(base_zoom_val + user_zoom_offset, 0.60, 1.70)
	var target_zoom: Vector2 = Vector2(target_zoom_val, target_zoom_val)
	zoom = zoom.lerp(target_zoom, 5.0 * delta)

	if shake_intensity > 0.0:
		var t: float = randf()
		var angle: float = t * TAU
		var strength: float = shake_intensity * 0.5
		offset = Vector2(cos(angle), sin(angle)) * strength
		shake_intensity *= pow(0.05, delta * shake_decay)
		if shake_intensity < 0.2:
			shake_intensity = 0.0
			offset = Vector2.ZERO
	else:
		offset = Vector2.ZERO


var user_zoom_offset: float = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.is_pressed():
			if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_in()
			elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_out()


func zoom_in() -> void:
	user_zoom_offset = clampf(user_zoom_offset + 0.10, -0.45, 0.65)


func zoom_out() -> void:
	user_zoom_offset = clampf(user_zoom_offset - 0.10, -0.45, 0.65)


func reset_zoom() -> void:
	user_zoom_offset = 0.0


func get_zoom_level() -> float:
	return 1.0 + user_zoom_offset


func trigger_shake(intensity: float) -> void:
	shake_intensity = max(shake_intensity, intensity)

