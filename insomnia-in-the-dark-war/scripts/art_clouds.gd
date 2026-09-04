extends Node2D

const CLOUD_FOREGROUND: Color = Color(1.0, 0.98, 0.95, 0.65)
const CLOUD_DISTANT: Color = Color(0.92, 0.88, 0.90, 0.40)
const SPEED_NEAR: float = 7.0
const SPEED_FAR: float = 3.5
const SCROLL_RESET: float = -2600.0
const SCROLL_LIMIT: float = 2600.0

# Near clouds (comfortably inside viewport between y = -360 and -270)
var _near_clouds: Array[Vector2] = [
	Vector2(-900.0, -310.0),
	Vector2(-100.0, -340.0),
	Vector2(850.0, -290.0)
]

# Distant smaller parallax clouds
var _far_clouds: Array[Vector2] = [
	Vector2(-1400.0, -370.0),
	Vector2(300.0, -360.0),
	Vector2(1600.0, -375.0)
]


var _redraw_timer: float = 0.0


func _process(delta: float) -> void:
	for i in _near_clouds.size():
		_near_clouds[i].x += SPEED_NEAR * delta
		if _near_clouds[i].x > SCROLL_LIMIT:
			_near_clouds[i].x = SCROLL_RESET

	for i in _far_clouds.size():
		_far_clouds[i].x += SPEED_FAR * delta
		if _far_clouds[i].x > SCROLL_LIMIT:
			_far_clouds[i].x = SCROLL_RESET

	_redraw_timer += delta
	if _redraw_timer >= 0.04:
		_redraw_timer = 0.0
		queue_redraw()


func _draw() -> void:
	# Draw distant clouds first
	for pos in _far_clouds:
		_draw_cloud(pos, 0.65, CLOUD_DISTANT)

	# Draw foreground clouds
	for pos in _near_clouds:
		_draw_cloud(pos, 1.0, CLOUD_FOREGROUND)


func _draw_cloud(origin: Vector2, scale_fac: float, col: Color) -> void:
	draw_circle(origin, 14.0 * scale_fac, col)
	draw_circle(origin + Vector2(16.0, -4.0) * scale_fac, 19.0 * scale_fac, col)
	draw_circle(origin + Vector2(34.0, 2.0) * scale_fac, 13.0 * scale_fac, col)
	draw_circle(origin + Vector2(48.0, 4.0) * scale_fac, 9.0 * scale_fac, col)
