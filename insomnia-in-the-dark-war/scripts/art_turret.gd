extends Node2D

const OUTLINE := Color(0.13, 0.15, 0.18)
const METAL := Color(0.45, 0.55, 0.60)
const METAL_LIGHT := Color(0.65, 0.75, 0.80)

func _draw() -> void:
	var base := Rect2(-10.0, -8.0, 20.0, 8.0)
	draw_rect(base, METAL)
	_draw_rect_outline(base, OUTLINE)
	draw_circle(Vector2(0.0, -10.0), 6.0, METAL_LIGHT)
	_draw_circle_outline(Vector2(0.0, -10.0), 6.0, OUTLINE)
	draw_rect(Rect2(4.0, -14.0, 14.0, 4.0), OUTLINE)

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
