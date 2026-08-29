extends Node2D

const SILHOUETTE := Color(0.14, 0.17, 0.27, 1.0)

var _building_rects: Array[Rect2] = []

func _ready() -> void:
	z_index = -10
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var x: float = -1250.0
	while x < 1250.0:
		var w: float = rng.randf_range(60.0, 140.0)
		var h: float = rng.randf_range(60.0, 220.0)
		_building_rects.append(Rect2(x, -h, w, h))
		x += rng.randf_range(120.0, 220.0)

func _draw() -> void:
	_draw_gradient_sky()
	_draw_sun()
	_draw_buildings()
	_draw_power_poles()
	_draw_power_lines()

func _draw_gradient_sky() -> void:
	var top_color := Color(0.15, 0.19, 0.36, 1.0)
	var bottom_color := Color(0.96, 0.62, 0.45, 1.0)
	var band_h: float = 120.0
	var bands: int = 6
	for i in bands:
		var t: float = float(i) / float(bands)
		var color: Color = top_color.lerp(bottom_color, t)
		var y: float = -720.0 + band_h * float(i)
		draw_rect(Rect2(-1250.0, y, 2500.0, band_h), color)

func _draw_sun() -> void:
	draw_circle(Vector2(-750.0, -70.0), 36.0, Color(0.99, 0.80, 0.55, 1.0))

func _draw_buildings() -> void:
	for rect in _building_rects:
		draw_rect(rect, SILHOUETTE)

func _draw_power_poles() -> void:
	var pole_y_start: float = 0.0
	var pole_y_end: float = -260.0
	for px in [-950.0, 900.0]:
		draw_line(Vector2(px, pole_y_start), Vector2(px, pole_y_end), SILHOUETTE, 4.0)
		draw_line(Vector2(px - 35.0, -250.0), Vector2(px + 35.0, -250.0), SILHOUETTE, 7.0)
		draw_line(Vector2(px - 25.0, -215.0), Vector2(px + 25.0, -215.0), SILHOUETTE, 5.0)
		draw_line(Vector2(px - 15.0, -180.0), Vector2(px + 15.0, -180.0), SILHOUETTE, 3.0)

func _draw_power_lines() -> void:
	var line_color := Color(0.14, 0.17, 0.27, 0.8)
	draw_line(Vector2(-950.0, -245.0), Vector2(900.0, -245.0), line_color, 1.0)
	draw_line(Vector2(-950.0, -210.0), Vector2(900.0, -210.0), line_color, 1.0)
