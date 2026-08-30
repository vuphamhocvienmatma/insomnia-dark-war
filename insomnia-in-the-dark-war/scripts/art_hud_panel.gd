extends Node2D

const WOOD_LIGHT := Color(0.75, 0.60, 0.45, 1.0)
const WOOD_DARK := Color(0.45, 0.32, 0.22, 1.0)
const OUTLINE := Color(0.25, 0.18, 0.12, 1.0)


func _draw() -> void:
	var rect := Rect2(-80.0, -60.0, 160.0, 120.0)
	draw_rect(rect, WOOD_LIGHT)
	draw_circle(Vector2(-80.0, -60.0), 12.0, WOOD_LIGHT)
	draw_circle(Vector2(80.0, -60.0), 12.0, WOOD_LIGHT)
	draw_circle(Vector2(-80.0, 60.0), 12.0, WOOD_LIGHT)
	draw_circle(Vector2(80.0, 60.0), 12.0, WOOD_LIGHT)
	_draw_rect_outline(rect, OUTLINE)
	for i in 6:
		var y: float = -50.0 + float(i) * 18.0
		draw_line(Vector2(-76.0, y), Vector2(76.0, y), Color(WOOD_DARK.r, WOOD_DARK.g, WOOD_DARK.b, 0.3), 1.0)
	draw_circle(Vector2(-72.0, -52.0), 3.0, Color(0.6, 0.5, 0.4, 1.0))
	draw_circle(Vector2(72.0, -52.0), 3.0, Color(0.6, 0.5, 0.4, 1.0))
	draw_circle(Vector2(-72.0, 52.0), 3.0, Color(0.6, 0.5, 0.4, 1.0))
	draw_circle(Vector2(72.0, 52.0), 3.0, Color(0.6, 0.5, 0.4, 1.0))


func _draw_rect_outline(r: Rect2, col: Color) -> void:
	var pts := PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, 3.0)
