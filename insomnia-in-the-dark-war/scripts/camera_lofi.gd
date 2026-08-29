extends Camera2D

const CAM_Y: float = -170.0

var shake_intensity: float = 0.0
var shake_decay: float = 5.0

func _ready() -> void:
	add_to_group("main_camera")
	limit_left = -1300
	limit_right = 1300
	limit_top = -700
	limit_bottom = 400
	position = Vector2(0.0, CAM_Y)

func _process(delta: float) -> void:
	if shake_intensity > 0.0:
		offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		shake_intensity = lerp(shake_intensity, 0.0, shake_decay * delta)
	else:
		offset = Vector2.ZERO

func trigger_shake(intensity: float) -> void:
	shake_intensity = max(shake_intensity, intensity)
