extends Node2D

const OUTLINE := Color(0.10, 0.10, 0.12, 1.0)
const SKIN := Color(0.38, 0.52, 0.44, 1.0)
const SKIN_SHADOW := Color(0.24, 0.35, 0.30, 1.0)
const SHIRT := Color(0.22, 0.24, 0.28, 1.0)
const SHIRT_TORN := Color(0.16, 0.18, 0.20, 1.0)
const PANTS := Color(0.14, 0.15, 0.18, 1.0)
const EYE_GLOW_CORE := Color(1.0, 0.25, 0.15, 1.0)
const EYE_GLOW_HALO := Color(1.0, 0.15, 0.10, 0.35)

var _sway: float = 0.0
var _shamble_cycle: float = 0.0


func _process(delta: float) -> void:
	_sway += delta * 2.8
	_shamble_cycle += delta * 4.5
	var pn: Node2D = get_parent() as Node2D
	if pn != null:
		pn.rotation = sin(_sway) * 0.06
	queue_redraw()


func _draw() -> void:
	var lurch_x: float = sin(_sway) * 2.0
	var lurch_y: float = absf(sin(_shamble_cycle)) * 2.0
	draw_set_transform(Vector2(lurch_x, -lurch_y), 0.0, Vector2.ONE)
	
	_draw_shadow()
	_draw_legs()
	_draw_body()
	_draw_arms()
	_draw_head()


func _draw_shadow() -> void:
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-12.0, 4.0),
			Vector2(0.0, 1.0),
			Vector2(12.0, 4.0),
			Vector2(0.0, 7.0)
		]),
		Color(0.0, 0.0, 0.0, 0.3)
	)


func _draw_legs() -> void:
	var leg_drag: float = sin(_shamble_cycle) * 3.0
	
	# Dragging back leg
	var l_leg := Rect2(-6.0, -9.0 + leg_drag * 0.5, 5.0, 10.0)
	_draw_rounded_rect(l_leg, PANTS, 1.5)
	_draw_rect_outline(l_leg, OUTLINE)
	
	# Forward shambling leg
	var r_leg := Rect2(1.0, -9.0 - leg_drag * 0.5, 5.0, 10.0)
	_draw_rounded_rect(r_leg, PANTS, 1.5)
	_draw_rect_outline(r_leg, OUTLINE)
	
	# Tattered cuffs
	draw_rect(Rect2(-6.0, 1.0, 5.0, 2.0), Color(0.1, 0.1, 0.1, 1.0))
	draw_rect(Rect2(1.0, 1.0, 5.0, 2.0), Color(0.1, 0.1, 0.1, 1.0))


func _draw_body() -> void:
	# Hunched tattered shirt
	var body := Rect2(-8.0, -23.0, 15.0, 15.0)
	_draw_rounded_rect(body, SHIRT, 3.0)
	_draw_rect_outline(body, OUTLINE)
	
	# Tattered shirt ribs / tears
	draw_line(Vector2(-5.0, -18.0), Vector2(-1.0, -16.0), OUTLINE, 1.2)
	draw_line(Vector2(2.0, -15.0), Vector2(5.0, -13.0), OUTLINE, 1.2)
	
	# Ragged bottom hem
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-8.0, -8.0),
			Vector2(-5.0, -5.0),
			Vector2(-2.0, -8.0),
			Vector2(2.0, -6.0),
			Vector2(5.0, -9.0),
			Vector2(7.0, -7.0),
			Vector2(7.0, -10.0),
			Vector2(-8.0, -10.0)
		]),
		SHIRT_TORN
	)


func _draw_arms() -> void:
	# Both arms reaching forward menacingly
	var reach_sway: float = sin(_sway + 1.0) * 2.0
	
	# Left arm
	var left_arm := Rect2(4.0, -22.0 + reach_sway, 12.0, 4.0)
	_draw_rounded_rect(left_arm, SHIRT, 1.5)
	_draw_rect_outline(left_arm, OUTLINE)
	# Claw hand
	draw_circle(Vector2(17.0, -20.0 + reach_sway), 2.5, SKIN)
	draw_line(Vector2(17.0, -22.0 + reach_sway), Vector2(21.0, -21.0 + reach_sway), OUTLINE, 1.0)
	draw_line(Vector2(17.0, -19.0 + reach_sway), Vector2(21.0, -18.0 + reach_sway), OUTLINE, 1.0)
	
	# Right arm
	var right_arm := Rect2(2.0, -17.0 - reach_sway * 0.5, 10.0, 3.5)
	_draw_rounded_rect(right_arm, SKIN_SHADOW, 1.5)
	_draw_rect_outline(right_arm, OUTLINE)
	draw_circle(Vector2(13.0, -15.0 - reach_sway * 0.5), 2.2, SKIN)


func _draw_head() -> void:
	var head_pos := Vector2(2.0, -31.0)
	
	# Hunched head
	draw_circle(head_pos, 7.5, SKIN)
	_draw_circle_outline(head_pos, 7.5, OUTLINE)
	
	# Decayed messy hair
	draw_colored_polygon(
		PackedVector2Array([
			head_pos + Vector2(-7.0, -3.0),
			head_pos + Vector2(-5.0, -8.0),
			head_pos + Vector2(-1.0, -9.0),
			head_pos + Vector2(3.0, -8.0),
			head_pos + Vector2(6.0, -4.0),
			head_pos + Vector2(4.0, -2.0),
			head_pos + Vector2(-1.0, -4.0)
		]),
		Color(0.15, 0.16, 0.18, 1.0)
	)
	
	# Glowing red eyes!
	var left_eye: Vector2 = head_pos + Vector2(1.5, -1.0)
	var right_eye: Vector2 = head_pos + Vector2(5.5, -1.0)
	
	# Soft outer glow halos
	draw_circle(left_eye, 3.8, EYE_GLOW_HALO)
	draw_circle(right_eye, 3.8, EYE_GLOW_HALO)
	
	# Piercing glowing core
	draw_circle(left_eye, 1.6, EYE_GLOW_CORE)
	draw_circle(right_eye, 1.6, EYE_GLOW_CORE)
	draw_circle(left_eye + Vector2(0.3, 0.0), 0.6, Color(1.0, 0.9, 0.8, 1.0))
	draw_circle(right_eye + Vector2(0.3, 0.0), 0.6, Color(1.0, 0.9, 0.8, 1.0))
	
	# Gaping mouth
	draw_colored_polygon(
		PackedVector2Array([
			head_pos + Vector2(2.0, 3.0),
			head_pos + Vector2(6.0, 3.0),
			head_pos + Vector2(4.5, 6.0)
		]),
		OUTLINE
	)


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
