extends Node2D

const OUTLINE := Color(0.18, 0.14, 0.12, 1.0)
const METAL_A := Color(0.70, 0.74, 0.80, 1.0)
const METAL_B := Color(0.48, 0.52, 0.60, 1.0)
const BRASS := Color(0.88, 0.70, 0.30, 1.0)
const SPROUT_LEAF := Color(0.42, 0.82, 0.38, 1.0)
const SEED_SHELL := Color(0.62, 0.45, 0.30, 1.0)
const GLASS_WATER := Color(0.45, 0.75, 0.95, 0.85)
const CORK := Color(0.75, 0.55, 0.35, 1.0)

var _type: String = "scrap"
var _time: float = 0.0


func _ready() -> void:
	_time = randf() * TAU
	queue_redraw()


func set_type(t: String) -> void:
	_type = t
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta * 3.0
	position.y = sin(_time) * 2.0


func _draw() -> void:
	# Small drop shadow on ground
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-8.0, 3.0),
			Vector2(0.0, 1.0),
			Vector2(8.0, 3.0),
			Vector2(0.0, 5.0)
		]),
		Color(0.0, 0.0, 0.0, 0.22)
	)

	if _type == "seed":
		# Seed bag / sprout
		draw_circle(Vector2(0.0, -4.0), 5.5, SEED_SHELL)
		_draw_circle_outline(Vector2(0.0, -4.0), 5.5, OUTLINE)
		# Sprouting twin leaves
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(0.0, -6.0),
				Vector2(-7.0, -12.0),
				Vector2(-3.0, -15.0),
				Vector2(0.0, -9.0)
			]),
			SPROUT_LEAF
		)
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(0.0, -6.0),
				Vector2(7.0, -12.0),
				Vector2(3.0, -15.0),
				Vector2(0.0, -9.0)
			]),
			SPROUT_LEAF
		)
		draw_line(Vector2(0.0, -4.0), Vector2(0.0, -10.0), Color(0.3, 0.6, 0.25, 1.0), 1.5)
	elif _type == "water":
		# Glass canteen flask with blue water
		var flask: Rect2 = Rect2(-6.0, -11.0, 12.0, 13.0)
		_draw_rounded_rect(flask, GLASS_WATER, 3.0)
		_draw_rect_outline(flask, OUTLINE)
		# Water fill level
		draw_rect(Rect2(-5.0, -5.0, 10.0, 6.0), Color(0.25, 0.55, 0.85, 0.7))
		# Glistening glass highlight
		draw_line(Vector2(-3.0, -9.0), Vector2(-3.0, -3.0), Color(1.0, 1.0, 1.0, 0.6), 1.2)
		# Cork stopper
		draw_rect(Rect2(-3.0, -14.0, 6.0, 3.5), CORK)
		_draw_rect_outline(Rect2(-3.0, -14.0, 6.0, 3.5), OUTLINE)
	else:
		# Mechanical brass & steel cog gear
		for i in 6:
			var a: float = TAU * float(i) / 6.0
			var gx: float = cos(a) * 8.0
			var gy: float = sin(a) * 8.0 - 5.0
			draw_rect(Rect2(gx - 2.5, gy - 2.5, 5.0, 5.0), BRASS)
			_draw_rect_outline(Rect2(gx - 2.5, gy - 2.5, 5.0, 5.0), OUTLINE)
			
		draw_circle(Vector2(0.0, -5.0), 7.5, METAL_A)
		_draw_circle_outline(Vector2(0.0, -5.0), 7.5, OUTLINE)
		draw_circle(Vector2(0.0, -5.0), 3.2, METAL_B)
		_draw_circle_outline(Vector2(0.0, -5.0), 3.2, OUTLINE)
		draw_circle(Vector2(-1.5, -6.5), 1.2, Color(1.0, 1.0, 1.0, 0.7))

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


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
