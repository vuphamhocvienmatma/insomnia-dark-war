extends Camera2D

const CAM_Y: float = -120.0

var shake_intensity: float = 0.0
var shake_decay: float = 5.0

func _ready() -> void:
	add_to_group("main_camera")
	top_level = true
	position = Vector2(0.0, CAM_Y)

func _process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		global_position.x = lerp(global_position.x, player.global_position.x, 5.0 * delta)
	global_position.y = CAM_Y

	if shake_intensity > 0.0:
		var offset_x := smoothstep(-shake_intensity, shake_intensity, randf() * 2.0 - 1.0) * shake_intensity
		var offset_y := smoothstep(-shake_intensity, shake_intensity, randf() * 2.0 - 1.0) * shake_intensity
		offset = Vector2(offset_x, offset_y)
		shake_intensity *= pow(0.1, delta * shake_decay)
		if shake_intensity < 0.5:
			shake_intensity = 0.0
	else:
		offset = Vector2.ZERO

func trigger_shake(intensity: float) -> void:
	shake_intensity = max(shake_intensity, intensity)
