extends Node2D

const OUTLINE: Color = Color(0.12, 0.12, 0.14, 1.0)
const ROBOT_BRASS: Color = Color(0.85, 0.68, 0.38, 1.0)
const ROBOT_STEEL: Color = Color(0.48, 0.52, 0.58, 1.0)
const ROBOT_DARK: Color = Color(0.24, 0.26, 0.30, 1.0)
const EYE_CYAN: Color = Color(0.20, 0.90, 1.0, 1.0)
const PACK_LEATHER: Color = Color(0.55, 0.38, 0.24, 1.0)
const PACK_STRAP: Color = Color(0.35, 0.22, 0.12, 1.0)
const BEDROLL: Color = Color(0.72, 0.32, 0.28, 1.0)

var _time: float = 0.0
var _redraw_timer: float = 0.0


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	_time += delta
	_redraw_timer += delta
	if _redraw_timer >= 0.066:
		_redraw_timer = 0.0
		queue_redraw()


func _draw() -> void:
	var breath: float = sin(_time * 2.5) * 1.0
	var tail_wag: float = sin(_time * 8.0) * 0.35

	# Shadow
	draw_colored_polygon(PackedVector2Array([
		Vector2(-20.0, 3.0),
		Vector2(20.0, 3.0),
		Vector2(14.0, 7.0),
		Vector2(-14.0, 7.0)
	]), Color(0.0, 0.0, 0.0, 0.28))

	# Tail with wagging antenna ball
	var tail_start := Vector2(-15.0, -14.0)
	var tail_mid := tail_start + Vector2(-10.0, -8.0 + tail_wag * 6.0)
	var tail_tip := tail_mid + Vector2(-6.0, -4.0 + tail_wag * 10.0)
	draw_line(tail_start, tail_mid, ROBOT_STEEL, 2.5)
	draw_line(tail_mid, tail_tip, ROBOT_STEEL, 2.0)
	draw_circle(tail_tip, 2.8, EYE_CYAN)

	# 4 Robot Legs with joint hinges
	_draw_robot_leg(Vector2(-12.0, -6.0), Vector2(-13.0, 3.0))
	_draw_robot_leg(Vector2(-6.0, -6.0), Vector2(-5.0, 3.0))
	_draw_robot_leg(Vector2(6.0, -6.0), Vector2(7.0, 3.0))
	_draw_robot_leg(Vector2(12.0, -6.0), Vector2(14.0, 3.0))

	# Robot Torso
	var body_rect := Rect2(-15.0, -20.0 + breath, 28.0, 15.0)
	_draw_rounded_rect(body_rect, ROBOT_BRASS, 4.0)
	_draw_rect_outline(body_rect, OUTLINE)
	# Mechanical side vents
	draw_line(Vector2(-4.0, -16.0 + breath), Vector2(4.0, -16.0 + breath), ROBOT_DARK, 1.2)
	draw_line(Vector2(-4.0, -13.0 + breath), Vector2(4.0, -13.0 + breath), ROBOT_DARK, 1.2)

	# Overloaded Cargo Backpack
	var pack_rect := Rect2(-13.0, -32.0 + breath, 22.0, 13.0)
	_draw_rounded_rect(pack_rect, PACK_LEATHER, 3.0)
	_draw_rect_outline(pack_rect, OUTLINE)
	# Fastener straps
	draw_line(Vector2(-8.0, -32.0 + breath), Vector2(-8.0, -19.0 + breath), PACK_STRAP, 1.5)
	draw_line(Vector2(4.0, -32.0 + breath), Vector2(4.0, -19.0 + breath), PACK_STRAP, 1.5)
	# Top rolled bedroll
	var roll_rect := Rect2(-11.0, -36.0 + breath, 18.0, 5.0)
	_draw_rounded_rect(roll_rect, BEDROLL, 2.0)
	_draw_rect_outline(roll_rect, OUTLINE)
	# Little communication antenna dish on pack
	draw_line(Vector2(8.0, -36.0 + breath), Vector2(10.0, -44.0 + breath), ROBOT_STEEL, 1.5)
	draw_arc(Vector2(10.0, -45.0 + breath), 3.0, -PI * 0.8, PI * 0.2, 8, ROBOT_BRASS, 1.5)

	# Robot Neck & Head
	var neck := Rect2(9.0, -22.0 + breath, 6.0, 9.0)
	_draw_rounded_rect(neck, ROBOT_STEEL, 2.0)
	
	var head_rect := Rect2(12.0, -28.0 + breath, 16.0, 14.0)
	_draw_rounded_rect(head_rect, ROBOT_BRASS, 4.0)
	_draw_rect_outline(head_rect, OUTLINE)

	# Ears (pointed back)
	var ear_pts := PackedVector2Array([
		Vector2(14.0, -28.0 + breath),
		Vector2(8.0, -35.0 + breath),
		Vector2(16.0, -31.0 + breath)
	])
	draw_colored_polygon(ear_pts, ROBOT_STEEL)
	draw_polyline(ear_pts, OUTLINE, 1.2)

	# Face Screen visor
	var visor := Rect2(19.0, -25.0 + breath, 8.0, 7.0)
	draw_rect(visor, ROBOT_DARK)
	_draw_rect_outline(visor, OUTLINE)

	# Glowing Cyan Expression [ ^ _ ^ ]
	draw_line(Vector2(21.0, -22.0 + breath), Vector2(23.0, -24.0 + breath), EYE_CYAN, 1.2)
	draw_line(Vector2(23.0, -24.0 + breath), Vector2(25.0, -22.0 + breath), EYE_CYAN, 1.2)


func _draw_robot_leg(hip: Vector2, foot: Vector2) -> void:
	var knee := (hip + foot) * 0.5 + Vector2(1.5, 0.0)
	draw_line(hip, knee, ROBOT_STEEL, 2.8)
	draw_line(knee, foot, ROBOT_STEEL, 2.2)
	draw_circle(hip, 2.0, ROBOT_DARK)
	draw_circle(knee, 1.6, ROBOT_DARK)
	draw_rect(Rect2(foot.x - 2.0, foot.y - 1.0, 5.0, 2.5), ROBOT_BRASS)


func _draw_rounded_rect(r: Rect2, col: Color, _rad: float) -> void:
	draw_rect(r, col)


func _draw_rect_outline(r: Rect2, col: Color) -> void:
	var pts: PackedVector2Array = PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, 1.2)
