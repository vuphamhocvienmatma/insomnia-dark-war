extends Node2D

const OUTLINE: Color = Color(0.14, 0.12, 0.10, 1.0)
const STEEL: Color = Color(0.30, 0.32, 0.35, 1.0)
const STEEL_DARK: Color = Color(0.18, 0.20, 0.22, 1.0)
const STEEL_LIGHT: Color = Color(0.48, 0.52, 0.56, 1.0)
const AK_WOOD: Color = Color(0.56, 0.28, 0.16, 1.0)
const AK_WOOD_DARK: Color = Color(0.38, 0.18, 0.10, 1.0)
const BRASS: Color = Color(0.85, 0.70, 0.28, 1.0)
const SANDBAG: Color = Color(0.46, 0.44, 0.34, 1.0)
const SANDBAG_SHADOW: Color = Color(0.34, 0.32, 0.24, 1.0)


var _flash_timer: float = 0.0


func _process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta
		queue_redraw()


func trigger_muzzle_flash() -> void:
	_flash_timer = 0.08
	queue_redraw()


func _draw() -> void:
	# 0. Beveled timber wedge base conforming to roof slope (kê bệ gỗ nghiêng theo mái)
	var wedge_pts: PackedVector2Array = PackedVector2Array([
		Vector2(-20.0, 0.0),
		Vector2(20.0, 0.0),
		Vector2(20.0, 5.0),
		Vector2(-20.0, 12.0)
	])
	draw_colored_polygon(wedge_pts, Color(0.36, 0.22, 0.15, 1.0))
	_draw_polyline_loop(wedge_pts, OUTLINE)
	draw_line(Vector2(-18.0, 5.5), Vector2(18.0, 2.5), Color(0.22, 0.14, 0.09, 0.8), 1.0)

	# 1. Sandbag nest base (firmly grounding the weapon on the wedge)
	var bag_rect: Rect2 = Rect2(-18.0, -6.0, 36.0, 7.0)
	_draw_rounded_rect(bag_rect, SANDBAG, 2.5)
	_draw_rect_outline(bag_rect, OUTLINE, 1.2)
	# Second layered sandbag behind
	var bag2_rect: Rect2 = Rect2(-14.0, -10.0, 28.0, 5.0)
	_draw_rounded_rect(bag2_rect, SANDBAG_SHADOW, 2.0)
	_draw_rect_outline(bag2_rect, OUTLINE, 1.0)

	# 2. Steel bipod legs rooted into the sandbag
	draw_line(Vector2(14.0, -6.0), Vector2(10.0, -14.0), STEEL_DARK, 2.2)
	draw_line(Vector2(6.0, -6.0), Vector2(10.0, -14.0), STEEL_DARK, 2.2)
	draw_circle(Vector2(10.0, -14.0), 1.6, STEEL)

	# 3. AK-47 Assault Rifle Structure
	# Wooden Stock
	var stock_poly: PackedVector2Array = PackedVector2Array([
		Vector2(-12.0, -14.0),
		Vector2(-24.0, -11.0),
		Vector2(-24.0, -17.0),
		Vector2(-12.0, -16.0)
	])
	draw_colored_polygon(stock_poly, AK_WOOD)
	_draw_polyline_loop(stock_poly, OUTLINE)
	# Metal buttplate
	draw_line(Vector2(-24.0, -11.0), Vector2(-24.0, -17.0), STEEL_DARK, 2.0)

	# Wooden Pistol Grip
	var grip_poly: PackedVector2Array = PackedVector2Array([
		Vector2(-7.0, -12.0),
		Vector2(-10.0, -6.0),
		Vector2(-7.0, -6.0),
		Vector2(-4.0, -12.0)
	])
	draw_colored_polygon(grip_poly, AK_WOOD_DARK)
	_draw_polyline_loop(grip_poly, OUTLINE)

	# Steel Receiver & Dust Cover
	var receiver: Rect2 = Rect2(-12.0, -17.0, 18.0, 6.0)
	draw_rect(receiver, STEEL_DARK)
	_draw_rect_outline(receiver, OUTLINE, 1.2)
	# Bolt carrier & selector switch
	draw_line(Vector2(-5.0, -15.0), Vector2(1.0, -15.0), STEEL_LIGHT, 1.5)

	# Curved Banana 30-round steel magazine
	var mag_poly: PackedVector2Array = PackedVector2Array([
		Vector2(-1.0, -11.0),
		Vector2(2.0, -3.0),
		Vector2(6.0, -3.0),
		Vector2(4.0, -11.0)
	])
	draw_colored_polygon(mag_poly, STEEL_DARK)
	_draw_polyline_loop(mag_poly, OUTLINE)
	# Magazine horizontal reinforcement ribs
	draw_line(Vector2(0.5, -9.0), Vector2(4.5, -9.0), STEEL_LIGHT, 1.0)
	draw_line(Vector2(1.2, -6.0), Vector2(5.2, -6.0), STEEL_LIGHT, 1.0)

	# Wooden Handguard & Gas Tube
	var handguard: Rect2 = Rect2(6.0, -16.5, 11.0, 5.0)
	_draw_rounded_rect(handguard, AK_WOOD, 1.5)
	_draw_rect_outline(handguard, OUTLINE, 1.2)

	# Steel Gas Tube (upper)
	draw_line(Vector2(6.0, -17.0), Vector2(18.0, -17.0), STEEL, 2.0)

	# Steel Barrel extending forward
	draw_line(Vector2(17.0, -14.0), Vector2(28.0, -14.0), STEEL, 2.2)

	# Front Sight Post (triangle post)
	draw_line(Vector2(26.0, -14.0), Vector2(26.0, -18.5), STEEL_DARK, 1.8)
	draw_line(Vector2(25.0, -18.5), Vector2(27.0, -18.5), STEEL_DARK, 1.5)

	# Slant Muzzle Brake / Compensator
	draw_line(Vector2(28.0, -14.0), Vector2(30.0, -13.0), STEEL_DARK, 2.5)

	# 4. Spent brass shell casings on sandbag
	draw_rect(Rect2(-6.0, -7.5, 2.8, 1.2), BRASS)
	draw_rect(Rect2(-2.0, -6.5, 2.8, 1.2), BRASS)
	draw_rect(Rect2(2.0, -7.0, 2.8, 1.2), BRASS)

	# 5. Night Muzzle Flash & Fire Light Flare
	if _flash_timer > 0.0:
		var mx: float = 31.0
		var my: float = -13.5
		# Outer warm orange glow
		draw_circle(Vector2(mx, my), 9.0, Color(1.0, 0.55, 0.15, 0.45))
		# Starburst diamond
		var flash_poly: PackedVector2Array = PackedVector2Array([
			Vector2(mx, my - 8.0),
			Vector2(mx + 3.0, my - 2.0),
			Vector2(mx + 12.0, my),
			Vector2(mx + 3.0, my + 2.0),
			Vector2(mx, my + 8.0),
			Vector2(mx - 2.0, my + 2.0),
			Vector2(mx - 4.0, my),
			Vector2(mx - 2.0, my - 2.0)
		])
		draw_colored_polygon(flash_poly, Color(1.0, 0.92, 0.45, 0.95))
		# Inner brilliant white core
		draw_circle(Vector2(mx + 2.0, my), 3.0, Color(1.0, 1.0, 0.95, 1.0))


func _draw_polyline_loop(pts_array: PackedVector2Array, col: Color) -> void:
	var p: PackedVector2Array = pts_array.duplicate()
	p.append(pts_array[0])
	draw_polyline(p, col, 1.2)


func _draw_rounded_rect(r: Rect2, col: Color, radius: float) -> void:
	draw_rect(r, col)
	draw_circle(Vector2(r.position.x + radius, r.position.y + radius), radius, col)
	draw_circle(Vector2(r.position.x + r.size.x - radius, r.position.y + radius), radius, col)
	draw_circle(Vector2(r.position.x + radius, r.position.y + r.size.y - radius), radius, col)
	draw_circle(Vector2(r.position.x + r.size.x - radius, r.position.y + r.size.y - radius), radius, col)


func _draw_rect_outline(r: Rect2, col: Color, width: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, width)
