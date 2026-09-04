extends Node2D

const OUTLINE := Color(0.20, 0.15, 0.12, 1.0)
const FUR_ORANGE := Color(0.96, 0.62, 0.22, 1.0)
const FUR_DARK := Color(0.82, 0.48, 0.15, 1.0)
const FUR_BELLY := Color(0.98, 0.92, 0.82, 1.0)
const EAR_PINK := Color(0.95, 0.65, 0.65, 1.0)
const EYE_GREEN := Color(0.35, 0.72, 0.45, 1.0)
const EYE_PUPIL := Color(0.12, 0.10, 0.10, 1.0)
const WHITE := Color(1.0, 1.0, 1.0, 1.0)

var _anim_time: float = 0.0
var _redraw_accum: float = 0.0
var _last_moving: bool = false
var _is_moving: bool = false


func _process(delta: float) -> void:
	var p: Node = get_parent()
	var vx: float = 0.0
	if p != null and "velocity" in p:
		var v: Vector2 = p.get("velocity")
		vx = v.x
	_is_moving = absf(vx) > 2.0
	var state_changed: bool = (_is_moving != _last_moving)
	_last_moving = _is_moving

	# When velocity == 0 and state has not changed: queue_redraw is NEVER called!
	if state_changed:
		queue_redraw()
	elif _is_moving:
		_anim_time += delta * 3.0
		_redraw_accum += delta
		if _redraw_accum >= 0.066: # 15 fps
			_redraw_accum = 0.0
			queue_redraw()


func _draw() -> void:
	var breath_y: float = sin(_anim_time * 0.8) * 0.5 if _is_moving else 0.0
	var tail_wag: float = sin(_anim_time * 1.5) * 3.0 if _is_moving else 0.0
	
	# Shadow
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-12.0, 2.0),
			Vector2(-6.0, 0.0),
			Vector2(6.0, 0.0),
			Vector2(12.0, 2.0),
			Vector2(6.0, 4.5),
			Vector2(-6.0, 4.5)
		]),
		Color(0.0, 0.0, 0.0, 0.35)
	)
	
	# Tail
	var t_pts: PackedVector2Array = PackedVector2Array([
		Vector2(-7.0, -4.0),
		Vector2(-11.0, -8.0 + tail_wag * 0.5),
		Vector2(-13.0, -14.0 + tail_wag)
	])
	draw_polyline(t_pts, FUR_DARK, 3.0)
	draw_circle(Vector2(-13.0, -14.0 + tail_wag), 1.6, FUR_BELLY)
	
	# Body
	var body_rect: Rect2 = Rect2(-8.0, -10.0 + breath_y, 14.0, 10.0)
	_draw_rounded_rect(body_rect, FUR_ORANGE, 4.0)
	_draw_rect_outline(body_rect, OUTLINE)
	
	# Tabby stripes on back
	draw_line(Vector2(-4.0, -10.0 + breath_y), Vector2(-4.0, -6.0 + breath_y), FUR_DARK, 1.5)
	draw_line(Vector2(-1.0, -10.0 + breath_y), Vector2(-1.0, -5.0 + breath_y), FUR_DARK, 1.5)
	draw_line(Vector2(2.0, -10.0 + breath_y), Vector2(2.0, -6.0 + breath_y), FUR_DARK, 1.5)
	
	# Paws
	draw_circle(Vector2(-5.0, 0.0), 2.2, FUR_BELLY)
	_draw_circle_outline(Vector2(-5.0, 0.0), 2.2, OUTLINE)
	draw_circle(Vector2(3.0, 0.0), 2.2, FUR_BELLY)
	_draw_circle_outline(Vector2(3.0, 0.0), 2.2, OUTLINE)
	
	# Head
	var head_c: Vector2 = Vector2(7.0, -10.0 + breath_y * 0.5)
	
	# Ears
	draw_polygon([head_c + Vector2(-4.0, -3.0), head_c + Vector2(-3.0, -9.0), head_c + Vector2(0.0, -4.0)], [FUR_ORANGE, FUR_ORANGE, FUR_ORANGE])
	draw_polygon([head_c + Vector2(-3.5, -4.0), head_c + Vector2(-2.8, -8.0), head_c + Vector2(-0.5, -4.5)], [EAR_PINK, EAR_PINK, EAR_PINK])
	draw_polygon([head_c + Vector2(1.0, -4.0), head_c + Vector2(4.0, -9.0), head_c + Vector2(5.0, -3.0)], [FUR_ORANGE, FUR_ORANGE, FUR_ORANGE])
	draw_polygon([head_c + Vector2(1.5, -4.5), head_c + Vector2(3.8, -8.0), head_c + Vector2(4.5, -4.0)], [EAR_PINK, EAR_PINK, EAR_PINK])
	
	# Head circle
	draw_circle(head_c, 5.5, FUR_ORANGE)
	_draw_circle_outline(head_c, 5.5, OUTLINE)
	
	# Cheeks / muzzle
	draw_circle(head_c + Vector2(1.0, 1.5), 2.5, FUR_BELLY)
	draw_circle(head_c + Vector2(3.5, 1.5), 2.0, FUR_BELLY)
	
	# Nose
	draw_circle(head_c + Vector2(2.2, 0.2), 0.8, EAR_PINK)
	
	# Eyes
	draw_circle(head_c + Vector2(1.5, -1.0), 1.4, EYE_GREEN)
	draw_circle(head_c + Vector2(1.5, -1.0), 0.8, EYE_PUPIL)
	draw_circle(head_c + Vector2(1.2, -1.3), 0.5, WHITE)
	
	# Whiskers
	draw_line(head_c + Vector2(3.5, 1.0), head_c + Vector2(8.0, 0.0), OUTLINE, 0.8)
	draw_line(head_c + Vector2(3.5, 2.0), head_c + Vector2(7.5, 3.5), OUTLINE, 0.8)


func _draw_rounded_rect(r: Rect2, col: Color, radius: float) -> void:
	draw_rect(r, col)
	draw_circle(Vector2(r.position.x + radius, r.position.y + radius), radius, col)
	draw_circle(Vector2(r.position.x + r.size.x - radius, r.position.y + radius), radius, col)
	draw_circle(Vector2(r.position.x + radius, r.position.y + r.size.y - radius), radius, col)
	draw_circle(Vector2(r.position.x + r.size.x - radius, r.position.y + r.size.y - radius), radius, col)


func _draw_rect_outline(r: Rect2, col: Color) -> void:
	var pts := PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, 1.5)


func _draw_circle_outline(c: Vector2, rad: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 14:
		var a := TAU * float(i) / 14.0
		pts.append(c + Vector2(cos(a), sin(a)) * rad)
	pts.append(c + Vector2(rad, 0.0))
	draw_polyline(pts, col, 1.5)
