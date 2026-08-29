extends Node2D

const OUTLINE := Color(0.13, 0.15, 0.18)
const WOOD := Color(0.55, 0.40, 0.30)
const WOOD_DARK := Color(0.35, 0.22, 0.17)
const METAL := Color(0.45, 0.55, 0.60)

func _draw() -> void:
	var body := Rect2(-6.0, -64.0, 12.0, 64.0)
	draw_rect(body, WOOD)
	_draw_rect_outline(body, OUTLINE)
	draw_rect(Rect2(-6.0, -44.0, 12.0, 4.0), WOOD_DARK)
	draw_rect(Rect2(-6.0, -22.0, 12.0, 4.0), WOOD_DARK)
	draw_circle(Vector2(-3.0, -42.0), 1.5, METAL)
	draw_circle(Vector2(3.0, -42.0), 1.5, METAL)
	draw_circle(Vector2(-3.0, -20.0), 1.5, METAL)
	draw_circle(Vector2(3.0, -20.0), 1.5, METAL)
	draw_circle(Vector2(-3.0, -2.0), 1.5, METAL)
	draw_circle(Vector2(3.0, -2.0), 1.5, METAL)

func _draw_rect_outline(r: Rect2, col: Color) -> void:
	var pts := PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, 2.0)
