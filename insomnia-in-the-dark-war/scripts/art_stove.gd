extends Node2D

const OUTLINE := Color(0.13, 0.15, 0.18)

func _draw() -> void:
	var body := Rect2(-12.0, -20.0, 24.0, 20.0)
	draw_rect(body, Color(0.22, 0.28, 0.31))
	_draw_rect_outline(body, OUTLINE)
	draw_rect(Rect2(-5.0, -12.0, 10.0, 8.0), Color(0.9, 0.5, 0.15))
	draw_rect(Rect2(-3.0, -30.0, 6.0, 10.0), Color(0.22, 0.28, 0.31))
	_draw_rect_outline(Rect2(-3.0, -30.0, 6.0, 10.0), OUTLINE)

func _draw_rect_outline(r: Rect2, col: Color) -> void:
	var pts := PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, 2.0)
