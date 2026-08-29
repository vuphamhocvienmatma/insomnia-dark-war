extends Node2D

const OUTLINE := Color(0.13, 0.15, 0.18)
const SKIN := Color(0.61, 0.80, 0.40)
const BODY := Color(0.33, 0.38, 0.42)
const EYE := Color(0.8, 0.1, 0.1)

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, deg_to_rad(10.0), Vector2.ONE)
	var body := Rect2(-8.0, -22.0, 16.0, 22.0)
	draw_rect(body, BODY)
	_draw_rect_outline(body, OUTLINE)
	var head_c := Vector2(2.0, -28.0)
	draw_circle(head_c, 8.0, SKIN)
	_draw_circle_outline(head_c, 8.0, OUTLINE)
	draw_rect(Rect2(6.0, -20.0, 10.0, 4.0), SKIN)
	draw_rect(Rect2(6.0, -12.0, 10.0, 4.0), SKIN)
	draw_circle(Vector2(4.0, -28.0), 1.5, EYE)

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
