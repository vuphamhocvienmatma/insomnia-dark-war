extends Node2D

const OUTLINE := Color(0.20, 0.18, 0.16)
const BOOTS := Color(0.22, 0.16, 0.12)
const PANTS := Color(0.28, 0.32, 0.38)
const SWEATER := Color(0.95, 0.72, 0.15)
const SCARF := Color(0.75, 0.22, 0.22)
const SKIN := Color(1.0, 0.87, 0.68)
const HAIR := Color(0.14, 0.11, 0.10)

var _walk_bob: float = 0.0


func _process(delta: float) -> void:
	var vx: float = 0.0
	var p := get_parent()
	if p != null and "velocity" in p:
		var v: Vector2 = p.get("velocity")
		vx = v.x
	if vx != 0.0:
		_walk_bob += delta * 8.0
	else:
		_walk_bob = 0.0
	queue_redraw()


func _draw() -> void:
	var bob_offset: float = sin(_walk_bob) * 2.0
	draw_set_transform(Vector2(0.0, bob_offset), 0.0, Vector2.ONE)
	_draw_backpack()
	_draw_boots()
	_draw_pants()
	_draw_sweater()
	_draw_scarf()
	_draw_head()
	_draw_face_details()
	_draw_hair()


func _draw_rounded_rect(r: Rect2, col: Color, radius: float) -> void:
	draw_rect(r, col)
	draw_circle(Vector2(r.position.x + radius, r.position.y + radius), radius, col)
	draw_circle(Vector2(r.position.x + r.size.x - radius, r.position.y + radius), radius, col)
	draw_circle(Vector2(r.position.x + radius, r.position.y + r.size.y - radius), radius, col)
	draw_circle(Vector2(r.position.x + r.size.x - radius, r.position.y + r.size.y - radius), radius, col)


func _draw_boots() -> void:
	var left := Rect2(-7.0, 0.0, 6.0, 6.0)
	var right := Rect2(1.0, 0.0, 6.0, 6.0)
	_draw_rounded_rect(left, BOOTS, 2.0)
	_draw_rounded_rect(right, BOOTS, 2.0)
	_draw_rect_outline(left, OUTLINE)
	_draw_rect_outline(right, OUTLINE)


func _draw_pants() -> void:
	var pants := Rect2(-7.0, -8.0, 14.0, 8.0)
	_draw_rounded_rect(pants, PANTS, 3.0)
	_draw_rect_outline(pants, OUTLINE)


func _draw_sweater() -> void:
	var body := Rect2(-8.0, -22.0, 16.0, 14.0)
	_draw_rounded_rect(body, SWEATER, 3.0)
	_draw_rect_outline(body, OUTLINE)
	var left_swing: float = sin(_walk_bob + PI) * 2.0
	var right_swing: float = sin(_walk_bob) * 2.0
	var left_arm := Rect2(-11.0, -20.0 + left_swing, 3.0, 10.0)
	var right_arm := Rect2(8.0, -20.0 + right_swing, 3.0, 10.0)
	_draw_rounded_rect(left_arm, SWEATER, 2.0)
	_draw_rounded_rect(right_arm, SWEATER, 2.0)
	_draw_rect_outline(left_arm, OUTLINE)
	_draw_rect_outline(right_arm, OUTLINE)


func _draw_scarf() -> void:
	var scarf := Rect2(-6.0, -24.0, 12.0, 3.0)
	_draw_rounded_rect(scarf, SCARF, 2.0)
	_draw_rect_outline(scarf, OUTLINE)


func _draw_backpack() -> void:
	var bag := Rect2(-10.0, -18.0, 4.0, 12.0)
	_draw_rounded_rect(bag, Color(0.4, 0.3, 0.2, 1.0), 2.0)
	_draw_rect_outline(bag, OUTLINE)


func _draw_head() -> void:
	var head_pos := Vector2(0.0, -30.0)
	draw_circle(head_pos, 7.0, SKIN)
	_draw_circle_outline(head_pos, 7.0, OUTLINE)
	draw_circle(Vector2(-2.0, -30.0), 1.2, OUTLINE)
	draw_circle(Vector2(2.0, -30.0), 1.2, OUTLINE)


func _draw_face_details() -> void:
	draw_line(Vector2(-2.0, -27.0), Vector2(2.0, -27.0), Color(0.8, 0.4, 0.4, 1.0), 1.0)


func _draw_hair() -> void:
	var dome_pts := PackedVector2Array()
	var segments: int = 20
	for i in segments + 1:
		var angle: float = PI + PI * float(i) / float(segments)
		dome_pts.append(Vector2(cos(angle) * 7.5, sin(angle) * 7.5 - 31.0))
	draw_polyline(dome_pts, HAIR, 2.0)
	_draw_circle_outline(Vector2(0.0, -31.0), 7.5, OUTLINE)
	var top := Rect2(-7.0, -34.0, 14.0, 3.0)
	_draw_rounded_rect(top, HAIR, 2.0)
	_draw_rect_outline(top, OUTLINE)
	var left_strand := Rect2(-8.0, -32.0, 2.0, 10.0)
	var right_strand := Rect2(6.0, -32.0, 2.0, 10.0)
	_draw_rounded_rect(left_strand, HAIR, 2.0)
	_draw_rounded_rect(right_strand, HAIR, 2.0)
	_draw_rect_outline(left_strand, OUTLINE)
	_draw_rect_outline(right_strand, OUTLINE)


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
