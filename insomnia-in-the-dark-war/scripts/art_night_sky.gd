extends Node2D

const MOON_POS := Vector2(-600.0, -260.0)
const MOON_RADIUS: float = 28.0
const MOON_COLOR := Color(0.98, 0.96, 0.88, 1.0)
const MOON_HALO := Color(0.70, 0.82, 0.98, 0.15)
const STAR_COLOR := Color(0.92, 0.96, 1.0, 0.95)

var _stars: Array[Dictionary] = []
var _shooting_stars: Array[Dictionary] = []
var _time: float = 0.0


func _ready() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 77
	for i in 60:
		_stars.append({
			"pos": Vector2(rng.randf_range(-1200.0, 1200.0), rng.randf_range(-340.0, -80.0)),
			"size": rng.randf_range(1.2, 3.0),
			"twinkle_speed": rng.randf_range(1.5, 4.0),
			"twinkle_offset": rng.randf_range(0.0, TAU)
		})


func _process(delta: float) -> void:
	_time += delta
	# Occasional shooting star
	if randf() < 0.008 and _shooting_stars.size() < 2:
		_shooting_stars.append({
			"start": Vector2(randf_range(-900.0, 600.0), randf_range(-320.0, -200.0)),
			"progress": 0.0,
			"length": randf_range(60.0, 110.0),
			"speed": randf_range(1.5, 2.5)
		})
		
	var i: int = _shooting_stars.size() - 1
	while i >= 0:
		var s: Dictionary = _shooting_stars[i]
		s["progress"] = float(s["progress"]) + delta * float(s["speed"])
		if float(s["progress"]) >= 1.0:
			_shooting_stars.remove_at(i)
		i -= 1
		
	queue_redraw()


func _draw() -> void:
	_draw_moon()
	_draw_stars()
	_draw_shooting_stars()


func _draw_moon() -> void:
	# Luminous moon with soft glowing halos
	draw_circle(MOON_POS, MOON_RADIUS * 2.8, Color(MOON_HALO.r, MOON_HALO.g, MOON_HALO.b, 0.05))
	draw_circle(MOON_POS, MOON_RADIUS * 1.8, Color(MOON_HALO.r, MOON_HALO.g, MOON_HALO.b, 0.12))
	draw_circle(MOON_POS, MOON_RADIUS * 1.25, Color(MOON_HALO.r, MOON_HALO.g, MOON_HALO.b, 0.25))
	draw_circle(MOON_POS, MOON_RADIUS, MOON_COLOR)
	# Lunar mare craters
	draw_circle(MOON_POS + Vector2(-6.0, -4.0), 5.0, Color(0.88, 0.86, 0.80, 0.6))
	draw_circle(MOON_POS + Vector2(7.0, 3.0), 7.0, Color(0.88, 0.86, 0.80, 0.6))
	draw_circle(MOON_POS + Vector2(-2.0, 9.0), 4.0, Color(0.88, 0.86, 0.80, 0.6))


func _draw_stars() -> void:
	for s in _stars:
		var pos: Vector2 = s["pos"]
		var sz: float = float(s["size"])
		var tw: float = 0.5 + 0.5 * sin(_time * float(s["twinkle_speed"]) + float(s["twinkle_offset"]))
		var col: Color = Color(STAR_COLOR.r, STAR_COLOR.g, STAR_COLOR.b, tw * 0.9)
		draw_rect(Rect2(pos.x - sz * 0.5, pos.y - sz * 0.5, sz, sz), col)
		if sz > 2.2 and tw > 0.7:
			# Cross twinkle flare
			draw_line(Vector2(pos.x - 3.0, pos.y), Vector2(pos.x + 3.0, pos.y), col, 0.8)
			draw_line(Vector2(pos.x, pos.y - 3.0), Vector2(pos.x, pos.y + 3.0), col, 0.8)


func _draw_shooting_stars() -> void:
	for s in _shooting_stars:
		var p: float = float(s["progress"])
		var st: Vector2 = s["start"]
		var length: float = float(s["length"])
		var dir: Vector2 = Vector2(1.8, 1.0).normalized()
		var head: Vector2 = st + dir * (length * 2.0 * p)
		var tail: Vector2 = head - dir * (length * (1.0 - p))
		var alpha: float = sin(p * PI) * 0.9
		draw_line(tail, head, Color(1.0, 1.0, 0.9, alpha), 1.6)
