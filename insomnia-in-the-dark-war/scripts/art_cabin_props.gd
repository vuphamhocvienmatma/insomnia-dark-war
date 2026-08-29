extends Node2D

const WOOD := Color(0.45, 0.32, 0.22, 1.0)
const AWNING_RED := Color(0.85, 0.30, 0.28, 1.0)
const AWNING_WHITE := Color(0.95, 0.93, 0.88, 1.0)
const SOLAR := Color(0.10, 0.16, 0.35, 1.0)
const SOLAR_LINE := Color(0.35, 0.50, 0.75, 1.0)

func _ready() -> void:
	z_index = -3

func _draw() -> void:
	_draw_awning()
	_draw_solar_panel()
	_draw_ladder()

func _draw_awning() -> void:
	var stripe_w: float = 14.0
	var stripe_h: float = 10.0
	var base_y: float = -180.0
	var base_x: float = -182.0
	for i in 6:
		var color: Color = AWNING_RED if (i % 2 == 0) else AWNING_WHITE
		var rx: float = base_x + stripe_w * float(i)
		var rect := Rect2(rx, base_y, stripe_w, stripe_h)
		draw_rect(rect, color)
		_draw_rect_outline(rect, Color(0.12, 0.10, 0.10, 1.0))
	draw_line(Vector2(base_x, base_y + stripe_h), Vector2(base_x + stripe_w * 6.0, base_y + stripe_h), Color(0.12, 0.10, 0.10, 1.0), 1.0)

func _draw_solar_panel() -> void:
	var panel := Rect2(-150.0, -246.0, 100.0, 14.0)
	draw_rect(panel, SOLAR)
	_draw_rect_outline(panel, Color(0.12, 0.10, 0.10, 1.0))
	var px: float = -150.0
	while px < -50.0:
		draw_line(Vector2(px, -246.0), Vector2(px, -232.0), SOLAR_LINE, 1.0)
		px += 20.0
	draw_line(Vector2(-150.0, -239.0), Vector2(-50.0, -239.0), SOLAR_LINE, 1.0)

func _draw_ladder() -> void:
	var left_x: float = 246.0
	var right_x: float = 258.0
	var top_y: float = -232.0
	draw_line(Vector2(left_x, 0.0), Vector2(left_x, top_y), WOOD, 3.0)
	draw_line(Vector2(right_x, 0.0), Vector2(right_x, top_y), WOOD, 3.0)
	var rung_y: float = -16.0
	while rung_y > top_y:
		draw_line(Vector2(left_x, rung_y), Vector2(right_x, rung_y), WOOD, 2.0)
		rung_y -= 16.0

func _draw_rect_outline(r: Rect2, col: Color) -> void:
	var pts := PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, 2.0)
