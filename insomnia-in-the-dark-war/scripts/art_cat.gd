extends Node2D

const OUTLINE := Color(0.13, 0.15, 0.18)
const FUR := Color(1.0, 0.60, 0.10)

func _draw() -> void:
	var body := Rect2(-7.0, -10.0, 14.0, 10.0)
	draw_rect(body, FUR)
	_draw_rect_outline(body, OUTLINE)
	var head_c := Vector2(7.0, -12.0)
	draw_circle(head_c, 5.0, FUR)
	_draw_circle_outline(head_c, 5.0, OUTLINE)
	draw_polygon([Vector2(4.0, -16.0), Vector2(7.0, -22.0), Vector2(10.0, -16.0)], [FUR, FUR, FUR])
	draw_polygon([Vector2(9.0, -16.0), Vector2(12.0, -22.0), Vector2(13.0, -16.0)], [FUR, FUR, FUR])
	draw_polyline(PackedVector2Array([Vector2(-7.0, -6.0), Vector2(-12.0, -8.0), Vector2(-14.0, -14.0)]), FUR, 2.0)
	draw_circle(Vector2(8.0, -12.0), 1.0, OUTLINE)

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
