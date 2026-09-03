extends Camera2D

const CAM_Y: float = -120.0
const CABIN_HALF_WIDTH: float = 220.0

var shake_intensity: float = 0.0
var shake_decay: float = 5.0
var _sway_time: float = 0.0


func _ready() -> void:
	add_to_group("main_camera")
	top_level = true
	position = Vector2(0.0, CAM_Y)
	zoom = Vector2(1.05, 1.05)


func _process(delta: float) -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	var is_in_cabin: bool = false
	
	if player != null:
		global_position.x = lerpf(global_position.x, player.global_position.x, 3.5 * delta)
		is_in_cabin = absf(player.global_position.x) < CABIN_HALF_WIDTH
		
	# Solid steady camera height
	global_position.y = CAM_Y
	
	# Smooth contextual zoom: slightly closer inside cabin, wider in wasteland
	var target_zoom_val: float = 1.08 if is_in_cabin else 0.98
	var target_zoom: Vector2 = Vector2(target_zoom_val, target_zoom_val)
	zoom = zoom.lerp(target_zoom, 1.5 * delta)

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


func trigger_shake(intensity: float) -> void:
	shake_intensity = max(shake_intensity, intensity)

