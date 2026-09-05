extends Node2D

var _front_alpha: float = 1.0
var _time: float = 0.0
var _tm: Node = null

func _ready() -> void:
	z_index = 5
	_tm = get_tree().get_first_node_in_group("time_manager")

func _process(delta: float) -> void:
	_time += delta
	var cam = get_tree().get_first_node_in_group("main_camera")
	if cam != null:
		var target: float = clampf((1.05 - float(cam.get("zoom").x)) * 15.0, 0.05, 1.0)
		_front_alpha = lerpf(_front_alpha, target, 5.0 * delta)
		queue_redraw()

func _draw() -> void:
	if _front_alpha <= 0.05: return
	var a: float = _front_alpha
	
	# Main wall
	var wall_rect: Rect2 = Rect2(-232.0, -215.0, 464.0, 233.0)
	draw_rect(wall_rect, Color(0.24, 0.16, 0.11, a))
	
	# Planks & Nails
	var lines: int = 8
	var plank_h: float = 233.0 / float(lines)
	for i in lines:
		var y: float = -215.0 + float(i) * plank_h
		draw_line(Vector2(-232.0, y), Vector2(232.0, y), Color(0.12, 0.08, 0.05, a * 0.8), 1.5)
		# Seams and nails
		var seam_x: float = -120.0 if (i % 2 == 0) else 90.0
		draw_line(Vector2(seam_x, y), Vector2(seam_x, y + plank_h), Color(0.12, 0.08, 0.05, a * 0.8), 1.5)
		draw_circle(Vector2(seam_x - 5.0, y + 4.0), 1.2, Color(0.1, 0.1, 0.1, a * 0.5))
		draw_circle(Vector2(seam_x + 5.0, y + 4.0), 1.2, Color(0.1, 0.1, 0.1, a * 0.5))

	_draw_porch_roof(a)
	_draw_window(a)
	_draw_flower_box(a)
	_draw_vines(a)
	_draw_sign(a)
	_draw_porch_light(a)
	_draw_mezzanine_railing(a)

func _draw_porch_roof(a: float) -> void:
	var roof_pts: PackedVector2Array = PackedVector2Array([
		Vector2(-240.0, -60.0),
		Vector2(240.0, -60.0),
		Vector2(248.0, -48.0),
		Vector2(-248.0, -48.0)
	])
	draw_colored_polygon(roof_pts, Color(0.20, 0.14, 0.10, a))
	draw_polyline(roof_pts, Color(0.1, 0.1, 0.1, a), 1.5)
	
	for cx in [-220.0, -110.0, 0.0, 110.0, 220.0]:
		var bracket: PackedVector2Array = PackedVector2Array([
			Vector2(cx, -60.0),
			Vector2(cx + 8.0, -60.0),
			Vector2(cx, -42.0)
		])
		draw_colored_polygon(bracket, Color(0.18, 0.12, 0.08, a))

func _draw_window(a: float) -> void:
	var win_rect: Rect2 = Rect2(-60.0, -120.0, 120.0, 60.0)
	draw_rect(win_rect, Color(0.6, 0.8, 0.9, a * 0.7))
	
	# Window Frame
	draw_rect(win_rect, Color(0.18, 0.12, 0.08, a), false, 4.0)
	draw_line(Vector2(0.0, -120.0), Vector2(0.0, -60.0), Color(0.18, 0.12, 0.08, a), 3.0)
	draw_line(Vector2(-60.0, -90.0), Vector2(60.0, -90.0), Color(0.18, 0.12, 0.08, a), 3.0)
	
	# Shutter left
	var shut_l: Rect2 = Rect2(-94.0, -120.0, 32.0, 60.0)
	draw_rect(shut_l, Color(0.28, 0.35, 0.30, a))
	draw_rect(shut_l, Color(0.1, 0.1, 0.1, a), false, 1.5)
	for i in range(1, 5):
		draw_line(Vector2(-94.0, -120.0 + i*12.0), Vector2(-62.0, -120.0 + i*12.0), Color(0.1, 0.1, 0.1, a*0.6), 1.5)
		
	# Shutter right
	var shut_r: Rect2 = Rect2(62.0, -120.0, 32.0, 60.0)
	draw_rect(shut_r, Color(0.28, 0.35, 0.30, a))
	draw_rect(shut_r, Color(0.1, 0.1, 0.1, a), false, 1.5)
	for i in range(1, 5):
		draw_line(Vector2(62.0, -120.0 + i*12.0), Vector2(94.0, -120.0 + i*12.0), Color(0.1, 0.1, 0.1, a*0.6), 1.5)

func _draw_flower_box(a: float) -> void:
	var box: Rect2 = Rect2(-64.0, -58.0, 128.0, 16.0)
	draw_rect(box, Color(0.4, 0.28, 0.18, a))
	draw_rect(box, Color(0.1, 0.1, 0.1, a), false, 1.5)
	
	# Flowers
	var f_cols: Array[Color] = [Color(0.8, 0.3, 0.3, a), Color(0.8, 0.8, 0.3, a), Color(0.4, 0.5, 0.8, a)]
	for i in 12:
		var fx: float = -58.0 + float(i) * 10.0
		var fy: float = -64.0 + sin(float(i)*1.5) * 4.0
		draw_circle(Vector2(fx, fy), 4.0, Color(0.3, 0.6, 0.3, a)) # Leaves
		draw_circle(Vector2(fx, fy - 2.0), 3.0, f_cols[i % 3])

func _draw_vines(a: float) -> void:
	var vine_pts: PackedVector2Array = PackedVector2Array()
	var points = 10
	for i in points:
		var vy = -215.0 + float(i) * 12.0
		var vx = 210.0 + sin(vy * 0.1) * 8.0
		vine_pts.append(Vector2(vx, vy))
	draw_polyline(vine_pts, Color(0.2, 0.45, 0.25, a), 3.0)
	for p in vine_pts:
		draw_circle(p + Vector2(2.0, 2.0), 3.5, Color(0.25, 0.55, 0.3, a))

func _draw_sign(a: float) -> void:
	var sign_rect = Rect2(-170.0, -100.0, 48.0, 24.0)
	draw_rect(sign_rect, Color(0.7, 0.6, 0.4, a))
	draw_rect(sign_rect, Color(0.1, 0.1, 0.1, a), false, 1.5)
	# Post
	draw_line(Vector2(-170.0, -100.0), Vector2(-155.0, -115.0), Color(0.1, 0.1, 0.1, a), 1.5)
	draw_line(Vector2(-122.0, -100.0), Vector2(-137.0, -115.0), Color(0.1, 0.1, 0.1, a), 1.5)
	# Text (Scribble)
	draw_line(Vector2(-160.0, -90.0), Vector2(-130.0, -90.0), Color(0.4, 0.1, 0.1, a), 2.0)
	draw_line(Vector2(-155.0, -82.0), Vector2(-135.0, -82.0), Color(0.4, 0.1, 0.1, a), 2.0)

func _draw_porch_light(a: float) -> void:
	var px: float = 120.0
	var py: float = -100.0
	draw_rect(Rect2(px-6.0, py, 12.0, 16.0), Color(0.2, 0.2, 0.2, a))
	
	var is_night: bool = _tm != null and bool(_tm.get("is_night"))
	if is_night:
		var flicker = 0.8 + sin(_time * 8.0) * 0.2
		draw_rect(Rect2(px-4.0, py+2.0, 8.0, 12.0), Color(1.0, 0.9, 0.4, a * flicker))
		# Outer glow
		draw_circle(Vector2(px, py+8.0), 30.0, Color(1.0, 0.9, 0.4, a * 0.15 * flicker))
	else:
		draw_rect(Rect2(px-4.0, py+2.0, 8.0, 12.0), Color(0.9, 0.9, 0.8, a * 0.5))

func _draw_mezzanine_railing(a: float) -> void:
	var WOOD_BEAM = Color(0.22, 0.15, 0.10, a)
	var WOOD_LINE = Color(0.18, 0.12, 0.08, a * 0.85)
	var OUTLINE = Color(0.18, 0.14, 0.12, a)

	var left_top_rail: Rect2 = Rect2(-185.0, -149.0, 321.0, 3.5)
	draw_rect(left_top_rail, WOOD_BEAM)
	draw_rect(left_top_rail, OUTLINE, false, 1.2)

	var bx: float = -180.0
	while bx < 132.0:
		draw_line(Vector2(bx, -140.0), Vector2(bx, -149.0), WOOD_LINE, 1.8)
		bx += 16.0
	draw_line(Vector2(136.0, -140.0), Vector2(136.0, -152.0), WOOD_BEAM, 3.5)
	draw_circle(Vector2(136.0, -152.0), 2.0, Color(0.85, 0.70, 0.30, a))

	var right_top_rail: Rect2 = Rect2(164.0, -149.0, 31.0, 3.5)
	draw_rect(right_top_rail, WOOD_BEAM)
	draw_rect(right_top_rail, OUTLINE, false, 1.2)
	draw_line(Vector2(164.0, -140.0), Vector2(164.0, -152.0), WOOD_BEAM, 3.5)
	draw_circle(Vector2(164.0, -152.0), 2.0, Color(0.85, 0.70, 0.30, a))
	draw_line(Vector2(180.0, -140.0), Vector2(180.0, -149.0), WOOD_LINE, 1.8)