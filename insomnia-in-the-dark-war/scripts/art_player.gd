extends Node2D

const OUTLINE := Color(0.13, 0.15, 0.18)
const WOOD := Color(0.55, 0.40, 0.30)
const SKIN := Color(1.0, 0.88, 0.71)
const HAT := Color(0.78, 0.16, 0.16)

func _draw() -> void:
	var body := Rect2(-8.0, -24.0, 16.0, 24.0)
	draw_rect(body, WOOD)
	_draw_rect_outline(body, OUTLINE)
	var head_c := Vector2(0.0, -30.0)
	draw_circle(head_c, 8.0, SKIN)
	_draw_circle_outline(head_c, 8.0, OUTLINE)
	draw_arc(head_c, 9.0, PI, TAU, 16, HAT, 3.0)
	draw_circle(Vector2(0.0, -38.0), 3.0, HAT)
	draw_circle(Vector2(3.0, -30.0), 1.5, OUTLINE)

func _draw_rect_outline(r: Rect2, col: Color) -> void:
	var pts := PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, 2.0)

func _draw_circle_outline(c: Vector2, rad: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 16:
		var a := TAU * float(i) / 16.0
		pts.append(c + Vector2(cos(a), sin(a)) * rad)
	draw_polyline(pts, col, 2.0)
