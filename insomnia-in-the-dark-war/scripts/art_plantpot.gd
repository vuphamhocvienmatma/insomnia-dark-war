extends Node2D

const OUTLINE := Color(0.18, 0.14, 0.12, 1.0)
const TERRACOTTA := Color(0.85, 0.48, 0.32, 1.0)
const TERRACOTTA_RIM := Color(0.92, 0.55, 0.38, 1.0)
const SOIL := Color(0.32, 0.22, 0.15, 1.0)
const STEM := Color(0.42, 0.75, 0.35, 1.0)
const LEAF := Color(0.48, 0.82, 0.40, 1.0)
const FLOWER_PETAL := Color(0.96, 0.58, 0.72, 1.0)
const FLOWER_CORE := Color(1.0, 0.85, 0.30, 1.0)

var _state: String = "empty"
var _time: float = 0.0
var _redraw_timer: float = 0.0


func _ready() -> void:
	_time = randf() * TAU
	queue_redraw()


var _last_drawn_progress: float = -1.0


func _process(delta: float) -> void:
	var p: Node = get_parent()
	var progress: float = 0.0
	if p != null and "growth_progress" in p:
		progress = float(p.get("growth_progress"))
	if _state == "empty" and progress <= 0.0:
		return
	_time += delta * 2.0
	_redraw_timer += delta
	# Throttle <= 10 lần/giây (>= 0.1s) và chỉ gọi khi progress đổi >= 1% (0.01) hoặc khi nở hoa đầy đủ
	if _redraw_timer >= 0.1 and (absf(progress - _last_drawn_progress) >= 0.01 or progress >= 0.9):
		_redraw_timer = 0.0
		_last_drawn_progress = progress
		queue_redraw()


func set_state(s: String) -> void:
	_state = s
	queue_redraw()


func _draw() -> void:
	var pot_shape := PackedVector2Array([
		Vector2(-8.0, -11.0),
		Vector2(8.0, -11.0),
		Vector2(5.5, 0.0),
		Vector2(-5.5, 0.0)
	])
	
	# Pot body
	draw_colored_polygon(pot_shape, TERRACOTTA)
	_draw_polyline_loop(pot_shape, OUTLINE)
	
	# Terracotta pot rim
	var rim := Rect2(-9.0, -14.0, 18.0, 4.0)
	_draw_rounded_rect(rim, TERRACOTTA_RIM, 1.5)
	_draw_rect_outline(rim, OUTLINE)
	
	# Rich potting soil inside
	draw_line(Vector2(-7.0, -12.0), Vector2(7.0, -12.0), SOIL, 2.5)

	var progress: float = 0.0
	var p: Node = get_parent()
	if p != null and "growth_progress" in p:
		progress = float(p.get("growth_progress"))

	var sway: float = sin(_time) * 1.5

	if progress > 0.05 and progress < 0.5:
		# Tiny cute cotyledon sprout
		var h: float = lerpf(4.0, 10.0, progress * 2.0)
		draw_line(Vector2(0.0, -13.0), Vector2(sway * 0.5, -13.0 - h), STEM, 2.0)
		draw_circle(Vector2(-3.0 + sway * 0.5, -13.0 - h - 1.0), 2.5, LEAF)
		draw_circle(Vector2(3.0 + sway * 0.5, -13.0 - h - 1.0), 2.5, LEAF)
	elif progress >= 0.5:
		# Tall lush plant with multiple leaves and blooming flower
		var h: float = 16.0
		draw_line(Vector2(0.0, -13.0), Vector2(sway, -13.0 - h), STEM, 2.2)
		
		# Side leaves
		draw_colored_polygon(PackedVector2Array([Vector2(-1.0, -18.0), Vector2(-8.0, -22.0), Vector2(-2.0, -23.0)]), LEAF)
		draw_colored_polygon(PackedVector2Array([Vector2(1.0, -20.0), Vector2(8.0, -24.0), Vector2(2.0, -25.0)]), LEAF)
		
		# Flower bud or full bloom
		var flower_center: Vector2 = Vector2(sway, -13.0 - h - 4.0)
		if progress >= 0.9:
			# 5 rounded petals
			for i in 5:
				var a: float = TAU * float(i) / 5.0 + _time * 0.2
				var petal_pos: Vector2 = flower_center + Vector2(cos(a), sin(a)) * 3.8
				draw_circle(petal_pos, 3.2, FLOWER_PETAL)
				_draw_circle_outline(petal_pos, 3.2, OUTLINE)
			# Golden center
			draw_circle(flower_center, 2.8, FLOWER_CORE)
			_draw_circle_outline(flower_center, 2.8, OUTLINE)
		else:
			# Opening flower bud
			draw_circle(flower_center, 3.5, FLOWER_PETAL)
			_draw_circle_outline(flower_center, 3.5, OUTLINE)

	# Progress bar if planted
	if progress > 0.0 and progress < 1.0:
		var bar_w: float = 24.0
		var bar_h: float = 3.5
		var bar_y: float = 6.0
		draw_rect(Rect2(-bar_w * 0.5, bar_y, bar_w, bar_h), Color(0.15, 0.15, 0.15, 0.75))
		draw_rect(Rect2(-bar_w * 0.5, bar_y, bar_w * progress, bar_h), Color(0.45, 0.85, 0.40, 1.0))
		_draw_rect_outline(Rect2(-bar_w * 0.5, bar_y, bar_w, bar_h), OUTLINE)


func _draw_polyline_loop(pts: PackedVector2Array, col: Color) -> void:
	var p := PackedVector2Array(pts)
	p.append(pts[0])
	draw_polyline(p, col, 1.5)


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
	for i in 12:
		var a := TAU * float(i) / 12.0
		pts.append(c + Vector2(cos(a), sin(a)) * rad)
	pts.append(c + Vector2(rad, 0.0))
	draw_polyline(pts, col, 1.2)
