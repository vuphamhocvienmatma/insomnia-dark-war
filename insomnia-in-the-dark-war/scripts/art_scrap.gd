extends Node2D

const OUTLINE := Color(0.13, 0.15, 0.18)
const METAL := Color(0.45, 0.55, 0.60)

var _type: String = "scrap"

func set_type(t: String) -> void:
	_type = t
	queue_redraw()

func _draw() -> void:
	if _type == "seed":
		draw_circle(Vector2(0.0, 0.0), 5.0, Color(0.4, 0.8, 0.3))
		_draw_circle_outline(Vector2.ZERO, 5.0, OUTLINE)
		draw_line(Vector2(0.0, -5.0), Vector2(0.0, -10.0), Color(0.3, 0.6, 0.2), 2.0)
	elif _type == "water":
		draw_circle(Vector2(0.0, 2.0), 5.0, Color(0.3, 0.55, 0.95))
		_draw_circle_outline(Vector2(0.0, 2.0), 5.0, OUTLINE)
		draw_polygon([Vector2(-4.0, -2.0), Vector2(4.0, -2.0), Vector2(0.0, -10.0)], [Color(0.3, 0.55, 0.95), Color(0.3, 0.55, 0.95), Color(0.3, 0.55, 0.95)])
	else:
		draw_circle(Vector2.ZERO, 6.0, METAL)
		_draw_circle_outline(Vector2.ZERO, 6.0, OUTLINE)
		for i in 4:
			var a := TAU * float(i) / 4.0
			draw_rect(Rect2(cos(a) * 6.0 - 2.0, sin(a) * 6.0 - 2.0, 4.0, 4.0), METAL)

func _draw_circle_outline(c: Vector2, rad: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 16:
		var a := TAU * float(i) / 16.0
		pts.append(c + Vector2(cos(a), sin(a)) * rad)
	draw_polyline(pts, col, 2.0)
