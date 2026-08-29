extends Node2D

const CLOUD_COLOR := Color(1.0, 1.0, 1.0, 0.75)
const CLOUD_SPEED: float = 6.0
const SCROLL_RESET: float = -1300.0
const SCROLL_LIMIT: float = 1300.0

var _cloud_a: Vector2 = Vector2(-800.0, -420.0)
var _cloud_b: Vector2 = Vector2(0.0, -500.0)
var _cloud_c: Vector2 = Vector2(700.0, -380.0)

func _process(delta: float) -> void:
	_cloud_a.x += CLOUD_SPEED * delta
	_cloud_b.x += CLOUD_SPEED * delta
	_cloud_c.x += CLOUD_SPEED * delta
	if _cloud_a.x > SCROLL_LIMIT:
		_cloud_a.x = SCROLL_RESET
	if _cloud_b.x > SCROLL_LIMIT:
		_cloud_b.x = SCROLL_RESET
	if _cloud_c.x > SCROLL_LIMIT:
		_cloud_c.x = SCROLL_RESET
	queue_redraw()

func _draw() -> void:
	_draw_cloud(_cloud_a)
	_draw_cloud(_cloud_b)
	_draw_cloud(_cloud_c)

func _draw_cloud(origin: Vector2) -> void:
	draw_circle(origin, 14.0, CLOUD_COLOR)
	draw_circle(origin + Vector2(16.0, -4.0), 18.0, CLOUD_COLOR)
	draw_circle(origin + Vector2(32.0, 2.0), 12.0, CLOUD_COLOR)
