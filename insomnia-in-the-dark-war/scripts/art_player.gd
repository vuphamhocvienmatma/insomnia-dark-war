extends Node2D

const OUTLINE := Color(0.12, 0.10, 0.10)
const BOOTS := Color(0.22, 0.16, 0.12)
const PANTS := Color(0.28, 0.32, 0.38)
const SWEATER := Color(0.85, 0.55, 0.20)
const SCARF := Color(0.75, 0.22, 0.22)
const SKIN := Color(1.0, 0.87, 0.68)
const BEANIE := Color(0.18, 0.50, 0.50)
const POM_POM := Color(0.9, 0.9, 0.9)

func _draw() -> void:
	_draw_boots()
	_draw_pants()
	_draw_sweater()
	_draw_scarf()
	_draw_head()
	_draw_beanie()

func _draw_boots() -> void:
	var left := Rect2(-7.0, 0.0, 6.0, 6.0)
	var right := Rect2(1.0, 0.0, 6.0, 6.0)
	draw_rect(left, BOOTS)
	draw_rect(right, BOOTS)
	_draw_rect_outline(left, OUTLINE)
	_draw_rect_outline(right, OUTLINE)

func _draw_pants() -> void:
	var pants := Rect2(-7.0, -8.0, 14.0, 8.0)
	draw_rect(pants, PANTS)
	_draw_rect_outline(pants, OUTLINE)

func _draw_sweater() -> void:
	var body := Rect2(-8.0, -22.0, 16.0, 14.0)
	draw_rect(body, SWEATER)
	_draw_rect_outline(body, OUTLINE)
	var left_arm := Rect2(-11.0, -20.0, 3.0, 10.0)
	var right_arm := Rect2(8.0, -20.0, 3.0, 10.0)
	draw_rect(left_arm, SWEATER)
	draw_rect(right_arm, SWEATER)
	_draw_rect_outline(left_arm, OUTLINE)
	_draw_rect_outline(right_arm, OUTLINE)

func _draw_scarf() -> void:
	var scarf := Rect2(-6.0, -24.0, 12.0, 3.0)
	draw_rect(scarf, SCARF)
	_draw_rect_outline(scarf, OUTLINE)

func _draw_head() -> void:
	var head_pos := Vector2(0.0, -30.0)
	draw_circle(head_pos, 7.0, SKIN)
	_draw_circle_outline(head_pos, 7.0, OUTLINE)
	draw_circle(Vector2(-2.0, -30.0), 1.2, OUTLINE)
	draw_circle(Vector2(2.0, -30.0), 1.2, OUTLINE)

func _draw_beanie() -> void:
	var brim := Rect2(-7.0, -37.0, 14.0, 4.0)
	draw_rect(brim, BEANIE)
	_draw_rect_outline(brim, OUTLINE)
	var dome_pts := PackedVector2Array()
	var segments: int = 20
	for i in segments + 1:
		var angle: float = PI + PI * float(i) / float(segments)
		dome_pts.append(Vector2(cos(angle) * 7.0, sin(angle) * 7.0 - 33.0))
	draw_polyline(dome_pts, BEANIE, 2.0)
	_draw_circle_outline(Vector2(0.0, -33.0), 7.0, OUTLINE)
	draw_circle(Vector2(0.0, -42.0), 2.5, POM_POM)
	_draw_circle_outline(Vector2(0.0, -42.0), 2.5, OUTLINE)

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
