extends Node2D

var _front_alpha: float = 1.0

func _ready() -> void:
	z_index = 5

func _process(delta: float) -> void:
	var cam = get_tree().get_first_node_in_group("main_camera")
	if cam:
		var target = clampf((1.05 - cam.zoom.x) * 15.0, 0.05, 1.0)
		_front_alpha = lerpf(_front_alpha, target, 5.0 * delta)
		queue_redraw()

func _draw() -> void:
	if _front_alpha <= 0.05: return
	# Front wall spanning the cabin width
	var wall_rect = Rect2(-232.0, -215.0, 464.0, 233.0)
	var col = Color(0.24, 0.16, 0.11, _front_alpha)
	draw_rect(wall_rect, col)
	# Planks
	var lines = 8
	for i in lines:
		var y = -215.0 + (i * 233.0 / lines)
		draw_line(Vector2(-232.0, y), Vector2(232.0, y), Color(0.12, 0.08, 0.05, _front_alpha), 1.5)

	# Window cutout drawn as a filled rect of glass
	var win_rect = Rect2(-60.0, -120.0, 120.0, 60.0)
	var glass = Color(0.6, 0.8, 0.9, _front_alpha * 0.7)
	draw_rect(win_rect, glass)
	draw_rect(win_rect, Color(0.1, 0.1, 0.1, _front_alpha), false, 4.0)
	# Window cross
	draw_line(Vector2(0.0, -120.0), Vector2(0.0, -60.0), Color(0.1, 0.1, 0.1, _front_alpha), 3.0)
	draw_line(Vector2(-60.0, -90.0), Vector2(60.0, -90.0), Color(0.1, 0.1, 0.1, _front_alpha), 3.0)

	# Mezzanine Railing Overlay
	var WOOD_BEAM = Color(0.22, 0.15, 0.10, _front_alpha)
	var WOOD_LINE = Color(0.18, 0.12, 0.08, _front_alpha * 0.85)
	var OUTLINE = Color(0.18, 0.14, 0.12, _front_alpha)

	# Left railing section: -185.0 to 136.0
	var left_top_rail: Rect2 = Rect2(-185.0, -149.0, 321.0, 3.5)
	draw_rect(left_top_rail, WOOD_BEAM)
	draw_rect(left_top_rail, OUTLINE, false, 1.2)

	var bx: float = -180.0
	while bx < 132.0:
		draw_line(Vector2(bx, -140.0), Vector2(bx, -149.0), WOOD_LINE, 1.8)
		bx += 16.0
	draw_line(Vector2(136.0, -140.0), Vector2(136.0, -152.0), WOOD_BEAM, 3.5)
	draw_circle(Vector2(136.0, -152.0), 2.0, Color(0.85, 0.70, 0.30, _front_alpha))

	# Right railing section: 164.0 to 195.0
	var right_top_rail: Rect2 = Rect2(164.0, -149.0, 31.0, 3.5)
	draw_rect(right_top_rail, WOOD_BEAM)
	draw_rect(right_top_rail, OUTLINE, false, 1.2)
	draw_line(Vector2(164.0, -140.0), Vector2(164.0, -152.0), WOOD_BEAM, 3.5)
	draw_circle(Vector2(164.0, -152.0), 2.0, Color(0.85, 0.70, 0.30, _front_alpha))
	draw_line(Vector2(180.0, -140.0), Vector2(180.0, -149.0), WOOD_LINE, 1.8)

