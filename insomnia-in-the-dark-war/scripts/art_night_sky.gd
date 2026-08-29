extends Node2D

const MOON_POS := Vector2(-600.0, -260.0)
const MOON_RADIUS: float = 26.0
const MOON_COLOR := Color(0.95, 0.93, 0.78, 1.0)
const MOON_BORDER_COLOR := Color(0.7, 0.65, 0.5, 1.0)
const STAR_COLOR := Color(0.9, 0.95, 1.0, 0.9)
const STAR_SIZE: float = 2.0

var _star_positions: Array[Vector2] = []

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 40:
		var sx: float = rng.randf_range(-1200.0, 1200.0)
		var sy: float = rng.randf_range(-300.0, -120.0)
		_star_positions.append(Vector2(sx, sy))

func _draw() -> void:
	_draw_moon()
	_draw_stars()

func _draw_moon() -> void:
	draw_circle(MOON_POS, MOON_RADIUS, MOON_COLOR)
	var border_pts := PackedVector2Array()
	var segments: int = 32
	for i in segments:
		var angle: float = TAU * float(i) / float(segments)
		border_pts.append(MOON_POS + Vector2(cos(angle), sin(angle)) * MOON_RADIUS)
	draw_polyline(border_pts, MOON_BORDER_COLOR, 2.0)

func _draw_stars() -> void:
	var half: float = STAR_SIZE / 2.0
	for pos in _star_positions:
		var rect := Rect2(pos.x - half, pos.y - half, STAR_SIZE, STAR_SIZE)
		draw_rect(rect, STAR_COLOR)
