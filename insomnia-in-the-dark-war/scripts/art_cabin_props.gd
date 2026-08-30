extends Node2D

const WOOD := Color(0.55, 0.42, 0.30, 1.0)
const AWNING_RED := Color(0.85, 0.30, 0.28, 1.0)
const AWNING_WHITE := Color(0.95, 0.93, 0.88, 1.0)
const SOLAR := Color(0.10, 0.16, 0.35, 1.0)
const SOLAR_LINE := Color(0.35, 0.50, 0.75, 1.0)

func _ready() -> void:
	z_index = -3

func _draw() -> void:
	_draw_solar_panel()
	_draw_ladder()
	_draw_interior_details()


func _draw_interior_details() -> void:
	var frame := Rect2(-120.0, -180.0, 40.0, 30.0)
	_draw_rounded_rect(frame, Color(0.6, 0.4, 0.3, 1.0), 4.0)
	_draw_rect_outline(frame, Color(0.6, 0.5, 0.4, 1.0))
	draw_set_transform(Vector2(-80.0, -160.0), 0.0, Vector2(1.2, 1.0))
	draw_circle(Vector2.ZERO, 6.0, Color(1.0, 0.9, 0.6, 1.0))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_arc(Vector2(-80.0, -160.0), 7.2, 0.0, TAU, 16, Color(0.12, 0.10, 0.10, 1.0), 1.0)
	draw_line(Vector2(-80.0, -160.0), Vector2(-80.0, -200.0), Color(0.12, 0.10, 0.10, 1.0), 1.0)
	draw_rect(Rect2(80.0, -180.0, 60.0, 8.0), Color(0.5, 0.35, 0.25, 1.0))
	_draw_rect_outline(Rect2(80.0, -180.0, 60.0, 8.0), Color(0.12, 0.10, 0.10, 1.0))
	var book_colors := [Color(0.8, 0.3, 0.3, 1.0), Color(0.3, 0.6, 0.8, 1.0), Color(0.4, 0.7, 0.4, 1.0), Color(0.8, 0.7, 0.3, 1.0)]
	for i in 4:
		var bx: float = 84.0 + float(i) * 13.0
		draw_rect(Rect2(bx, -188.0, 8.0, 12.0), book_colors[i])
	draw_rect(Rect2(40.0, -30.0, 20.0, 30.0), Color(0.5, 0.35, 0.25, 1.0))
	_draw_rect_outline(Rect2(40.0, -30.0, 20.0, 30.0), Color(0.12, 0.10, 0.10, 1.0))
	draw_rect(Rect2(-30.0, -10.0, 60.0, 8.0), Color(0.7, 0.3, 0.3, 1.0))

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
	var top_y: float = -200.0
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

func _draw_rounded_rect(r: Rect2, col: Color, radius: float) -> void:
	draw_rect(r, col)
	draw_circle(Vector2(r.position.x + radius, r.position.y + radius), radius, col)
	draw_circle(Vector2(r.position.x + r.size.x - radius, r.position.y + radius), radius, col)
	draw_circle(Vector2(r.position.x + radius, r.position.y + r.size.y - radius), radius, col)
	draw_circle(Vector2(r.position.x + r.size.x - radius, r.position.y + r.size.y - radius), radius, col)
