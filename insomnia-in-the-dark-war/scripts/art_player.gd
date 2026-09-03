extends Node2D

const OUTLINE := Color(0.18, 0.14, 0.12, 1.0)
const HOODIE := Color(0.96, 0.75, 0.20, 1.0)
const HOODIE_SHADOW := Color(0.82, 0.62, 0.14, 1.0)
const PANTS := Color(0.26, 0.30, 0.36, 1.0)
const BOOTS := Color(0.32, 0.22, 0.15, 1.0)
const BOOT_SOLE := Color(0.18, 0.12, 0.08, 1.0)
const SKIN := Color(1.0, 0.88, 0.74, 1.0)
const BLUSH := Color(0.94, 0.48, 0.48, 0.55)
const HAIR := Color(0.28, 0.18, 0.13, 1.0)
const BEANIE := Color(0.20, 0.24, 0.28, 1.0)
const SCARF := Color(0.80, 0.26, 0.22, 1.0)
const BACKPACK := Color(0.40, 0.30, 0.20, 1.0)
const BEDROLL := Color(0.38, 0.48, 0.36, 1.0)
const EYE := Color(0.14, 0.10, 0.10, 1.0)
const WHITE := Color(1.0, 1.0, 1.0, 1.0)

var _walk_bob: float = 0.0
var _climb_bob: float = 0.0
var _idle_time: float = 0.0
var _blink_timer: float = 0.0
var _is_moving: bool = false
var is_climbing: bool = false


func set_climbing(c: bool) -> void:
	is_climbing = c
	queue_redraw()


func _process(delta: float) -> void:
	var vx: float = 0.0
	var p: Node = get_parent()
	if p != null and "velocity" in p:
		var v: Vector2 = p.get("velocity")
		vx = v.x
	
	_is_moving = absf(vx) > 5.0
	if is_climbing:
		_climb_bob += delta * 12.0
	elif _is_moving:
		_walk_bob += delta * 9.0
	else:
		_walk_bob = 0.0
		_idle_time += delta * 2.5
	
	_blink_timer += delta
	if _blink_timer > 4.0:
		_blink_timer = 0.0
		
	queue_redraw()


func _draw() -> void:
	var bob_y: float = sin(_walk_bob) * 2.5 if _is_moving else sin(_idle_time) * 0.8
	draw_set_transform(Vector2(0.0, bob_y), 0.0, Vector2.ONE)
	
	_draw_shadow()
	_draw_backpack()
	_draw_boots()
	_draw_legs()
	_draw_torso()
	_draw_scarf()
	_draw_head()
	_draw_cold_breath()


func _draw_cold_breath() -> void:
	# Occasional breath vapor puff in crisp cold air
	var cycle: float = fmod(_idle_time * 0.7, 3.5)
	if cycle < 1.4:
		var p: float = cycle / 1.4
		var bx: float = 6.0 + p * 12.0
		var by: float = -29.0 - p * 8.0
		var rad: float = 1.8 + p * 3.5
		var alpha: float = sin(p * PI) * 0.45
		draw_circle(Vector2(bx, by), rad, Color(0.92, 0.96, 1.0, alpha))
		draw_circle(Vector2(bx - 3.0, by + 1.0), rad * 0.7, Color(0.92, 0.96, 1.0, alpha * 0.7))


func _draw_shadow() -> void:
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-14.0, 3.0),
			Vector2(-8.0, 1.0),
			Vector2(8.0, 1.0),
			Vector2(14.0, 3.0),
			Vector2(8.0, 6.0),
			Vector2(-8.0, 6.0)
		]),
		Color(0.0, 0.0, 0.0, 0.35)
	)


func _draw_backpack() -> void:
	var roll := Rect2(-14.0, -28.0, 8.0, 6.0)
	_draw_rounded_rect(roll, BEDROLL, 2.0)
	_draw_rect_outline(roll, OUTLINE)
	draw_line(Vector2(-11.0, -28.0), Vector2(-11.0, -22.0), OUTLINE, 1.0)
	
	var bag := Rect2(-13.0, -22.0, 7.0, 14.0)
	_draw_rounded_rect(bag, BACKPACK, 2.0)
	_draw_rect_outline(bag, OUTLINE)
	
	var pocket := Rect2(-13.0, -15.0, 6.0, 6.0)
	_draw_rounded_rect(pocket, Color(0.48, 0.36, 0.24, 1.0), 1.0)
	_draw_rect_outline(pocket, OUTLINE)


func _draw_boots() -> void:
	var left_y: float = 0.0
	var right_y: float = 0.0
	if is_climbing:
		left_y = sin(_climb_bob) * 4.5
		right_y = -sin(_climb_bob) * 4.5
	elif _is_moving:
		left_y = sin(_walk_bob + PI) * 2.0
		right_y = sin(_walk_bob) * 2.0
	
	var lb := Rect2(-8.0, 0.0 + left_y, 7.0, 5.0)
	_draw_rounded_rect(lb, BOOTS, 1.5)
	_draw_rect_outline(lb, OUTLINE)
	draw_line(Vector2(-8.0, 5.0 + left_y), Vector2(-1.0, 5.0 + left_y), BOOT_SOLE, 1.5)
	
	var rb := Rect2(1.0, 0.0 + right_y, 7.0, 5.0)
	_draw_rounded_rect(rb, BOOTS, 1.5)
	_draw_rect_outline(rb, OUTLINE)
	draw_line(Vector2(1.0, 5.0 + right_y), Vector2(8.0, 5.0 + right_y), BOOT_SOLE, 1.5)


func _draw_legs() -> void:
	var pants := Rect2(-7.0, -9.0, 14.0, 10.0)
	_draw_rounded_rect(pants, PANTS, 2.0)
	_draw_rect_outline(pants, OUTLINE)
	draw_rect(Rect2(-5.0, -5.0, 3.0, 4.0), Color(0.20, 0.24, 0.28, 1.0))
	draw_rect(Rect2(2.0, -5.0, 3.0, 4.0), Color(0.20, 0.24, 0.28, 1.0))


func _draw_torso() -> void:
	var body := Rect2(-9.0, -23.0, 18.0, 15.0)
	_draw_rounded_rect(body, HOODIE, 3.5)
	_draw_rect_outline(body, OUTLINE)
	
	draw_rect(Rect2(-8.0, -10.0, 16.0, 2.0), HOODIE_SHADOW)
	
	var pocket := Rect2(-5.0, -17.0, 10.0, 6.0)
	_draw_rounded_rect(pocket, HOODIE_SHADOW, 2.0)
	_draw_rect_outline(pocket, OUTLINE)
	
	var left_swing: float = 0.0
	var right_swing: float = 0.0
	if is_climbing:
		# Alternating climbing arm reach grasping rungs
		left_swing = -sin(_climb_bob) * 6.5 - 4.0
		right_swing = sin(_climb_bob) * 6.5 - 4.0
	elif _is_moving:
		left_swing = sin(_walk_bob + PI) * 3.5
		right_swing = sin(_walk_bob) * 3.5
	
	var left_arm := Rect2(-12.0, -22.0 + left_swing, 4.0, 12.0)
	_draw_rounded_rect(left_arm, HOODIE, 2.0)
	_draw_rect_outline(left_arm, OUTLINE)
	draw_circle(Vector2(-10.0, -9.0 + left_swing), 2.5, SKIN)
	
	var right_arm := Rect2(8.0, -22.0 + right_swing, 4.0, 12.0)
	_draw_rounded_rect(right_arm, HOODIE, 2.0)
	_draw_rect_outline(right_arm, OUTLINE)
	draw_circle(Vector2(10.0, -9.0 + right_swing), 2.5, SKIN)


func _draw_scarf() -> void:
	var scarf := Rect2(-7.0, -26.0, 14.0, 5.0)
	_draw_rounded_rect(scarf, SCARF, 2.5)
	_draw_rect_outline(scarf, OUTLINE)
	var tail := Rect2(3.0, -23.0, 4.0, 8.0)
	_draw_rounded_rect(tail, SCARF, 1.5)
	_draw_rect_outline(tail, OUTLINE)


func _draw_head() -> void:
	var head_c := Vector2(0.0, -32.0)
	
	draw_circle(head_c, 8.0, SKIN)
	_draw_circle_outline(head_c, 8.0, OUTLINE)
	
	draw_circle(Vector2(-4.5, -30.5), 2.2, BLUSH)
	draw_circle(Vector2(4.5, -30.5), 2.2, BLUSH)
	
	var beanie_rect := Rect2(-8.5, -40.0, 17.0, 8.0)
	_draw_rounded_rect(beanie_rect, BEANIE, 4.0)
	_draw_rect_outline(beanie_rect, OUTLINE)
	draw_circle(Vector2(0.0, -41.0), 3.0, SCARF)
	_draw_circle_outline(Vector2(0.0, -41.0), 3.0, OUTLINE)
	
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-7.0, -33.0),
			Vector2(-3.0, -31.0),
			Vector2(0.0, -33.0),
			Vector2(3.0, -30.5),
			Vector2(7.0, -33.0),
			Vector2(5.0, -36.0),
			Vector2(-5.0, -36.0)
		]),
		HAIR
	)
	
	var is_blinking: bool = _blink_timer > 3.8 and _blink_timer < 4.0
	if is_blinking:
		draw_line(Vector2(-4.0, -32.0), Vector2(-1.5, -32.0), EYE, 1.5)
		draw_line(Vector2(1.5, -32.0), Vector2(4.0, -32.0), EYE, 1.5)
	else:
		draw_circle(Vector2(-3.0, -32.5), 1.8, EYE)
		draw_circle(Vector2(3.0, -32.5), 1.8, EYE)
		draw_circle(Vector2(-3.5, -33.2), 0.7, WHITE)
		draw_circle(Vector2(2.5, -33.2), 0.7, WHITE)
		
	draw_line(Vector2(-1.0, -29.0), Vector2(1.0, -29.0), Color(0.7, 0.35, 0.35, 1.0), 1.0)


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
	draw_polyline(pts, col, 1.8)


func _draw_circle_outline(c: Vector2, rad: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 16:
		var a := TAU * float(i) / 16.0
		pts.append(c + Vector2(cos(a), sin(a)) * rad)
	pts.append(c + Vector2(rad, 0.0))
	draw_polyline(pts, col, 1.8)
