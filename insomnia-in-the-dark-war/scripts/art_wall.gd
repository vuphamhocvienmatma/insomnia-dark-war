extends Node2D

const OUTLINE := Color(0.18, 0.14, 0.12, 1.0)
const LOG_A := Color(0.58, 0.44, 0.32, 1.0)
const LOG_B := Color(0.50, 0.38, 0.26, 1.0)
const LOG_SHADOW := Color(0.38, 0.28, 0.18, 1.0)
const IRON_STRAP := Color(0.32, 0.36, 0.40, 1.0)
const BOLT := Color(0.70, 0.74, 0.78, 1.0)
const ROPE := Color(0.72, 0.60, 0.42, 1.0)


func _draw() -> void:
	# Left pointed timber log
	var left_pts := PackedVector2Array([
		Vector2(-9.0, 0.0),
		Vector2(-9.0, -56.0),
		Vector2(-4.5, -64.0),
		Vector2(0.0, -56.0),
		Vector2(0.0, 0.0)
	])
	draw_colored_polygon(left_pts, LOG_A)
	_draw_polyline_loop(left_pts, OUTLINE)
	draw_line(Vector2(-4.5, -54.0), Vector2(-4.5, -2.0), LOG_SHADOW, 1.2)
	
	# Right pointed timber log
	var right_pts := PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(0.0, -58.0),
		Vector2(4.5, -66.0),
		Vector2(9.0, -58.0),
		Vector2(9.0, 0.0)
	])
	draw_colored_polygon(right_pts, LOG_B)
	_draw_polyline_loop(right_pts, OUTLINE)
	draw_line(Vector2(4.5, -56.0), Vector2(4.5, -2.0), LOG_SHADOW, 1.2)
	
	# Horizontal iron reinforcing straps
	for y in [-45.0, -20.0]:
		var strap := Rect2(-10.0, y, 20.0, 6.0)
		draw_rect(strap, IRON_STRAP)
		_draw_rect_outline(strap, OUTLINE)
		# Heavy steel bolts
		draw_circle(Vector2(-5.0, y + 3.0), 1.5, BOLT)
		draw_circle(Vector2(-5.0, y + 3.0), 0.8, OUTLINE)
		draw_circle(Vector2(5.0, y + 3.0), 1.5, BOLT)
		draw_circle(Vector2(5.0, y + 3.0), 0.8, OUTLINE)
		
	# Cross rope lashing
	draw_line(Vector2(-8.0, -32.0), Vector2(8.0, -35.0), ROPE, 1.5)
	draw_line(Vector2(-8.0, -35.0), Vector2(8.0, -32.0), ROPE, 1.5)

	# Coiled barbed wire across pointed log tips
	for i in 4:
		var bx: float = -7.5 + float(i) * 5.0
		draw_arc(Vector2(bx, -62.0), 3.8, 0.0, TAU, 8, Color(0.52, 0.56, 0.60, 0.95), 1.2)
		draw_line(Vector2(bx - 1.5, -65.5), Vector2(bx + 1.5, -58.5), Color(0.28, 0.30, 0.34, 1.0), 1.0)


func _draw_polyline_loop(pts_array: PackedVector2Array, col: Color) -> void:
	var p := PackedVector2Array(pts_array)
	p.append(pts_array[0])
	draw_polyline(p, col, 1.5)


func _draw_rect_outline(r: Rect2, col: Color) -> void:
	var pts := PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, 1.5)
