extends Node2D

const OUTLINE := Color(0.13, 0.15, 0.18)
const GOLD := Color(1.0, 0.84, 0.0)

func _draw() -> void:
	var pts := PackedVector2Array([Vector2(0.0, -8.0), Vector2(8.0, 0.0), Vector2(0.0, 8.0), Vector2(-8.0, 0.0)])
	draw_polygon(pts, [GOLD, GOLD, GOLD, GOLD])
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_polyline(closed, Color(1.0, 0.95, 0.6), 2.0)
	var glow := pts.duplicate()
	glow.append(pts[0])
	draw_polyline(glow, OUTLINE, 1.0)
