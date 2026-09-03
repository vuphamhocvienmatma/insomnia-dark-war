extends Area2D

const BUNKER_W: float = 190.0
const BUNKER_H: float = 86.0
const TIMBER_DARK: Color = Color(0.24, 0.16, 0.11, 1.0)
const TIMBER_LIGHT: Color = Color(0.34, 0.24, 0.17, 1.0)
const STEEL: Color = Color(0.38, 0.40, 0.44, 1.0)
const STEEL_LIGHT: Color = Color(0.52, 0.55, 0.60, 1.0)
const STEEL_DARK: Color = Color(0.22, 0.24, 0.26, 1.0)
const SANDBAG: Color = Color(0.48, 0.46, 0.35, 1.0)
const SANDBAG_SHADOW: Color = Color(0.35, 0.33, 0.25, 1.0)
const CAUTION_YELLOW: Color = Color(0.92, 0.75, 0.25, 1.0)
const GLOW: Color = Color(1.0, 0.82, 0.45, 0.65)
const OUTLINE: Color = Color(0.16, 0.12, 0.09, 1.0)
const SAFE_TINT: Color = Color(0.45, 0.75, 0.55, 0.08)


func _ready() -> void:
	add_to_group("safe_zone")
	monitoring = true
	monitorable = true

	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(BUNKER_W, BUNKER_H)
	shape.shape = rect
	add_child(shape)

	body_entered.connect(_on_body_entered)
	queue_redraw()


func _draw() -> void:
	# 2.5D perspective drop shadow under the bunker
	var shadow_poly: PackedVector2Array = PackedVector2Array([
		Vector2(-110.0, 25.0),
		Vector2(-85.0, 42.0),
		Vector2(95.0, 42.0),
		Vector2(105.0, 32.0),
		Vector2(-70.0, 20.0)
	])
	draw_colored_polygon(shadow_poly, Color(0.0, 0.0, 0.0, 0.35))

	# Subtle ground safe zone floor
	draw_rect(Rect2(-BUNKER_W * 0.5, -BUNKER_H * 0.5, BUNKER_W, BUNKER_H), SAFE_TINT)

	# 2.5D Left Perspective Side Wall
	var left_side: PackedVector2Array = PackedVector2Array([
		Vector2(-85.0, -45.0),
		Vector2(-105.0, -58.0),
		Vector2(-105.0, 25.0),
		Vector2(-85.0, 40.0)
	])
	draw_colored_polygon(left_side, TIMBER_DARK * 0.75)
	draw_polyline(left_side, OUTLINE, 2.0)
	# Side log lines
	for s_idx in 4:
		var sy1: float = -45.0 + float(s_idx) * 20.0
		var sy2: float = -58.0 + float(s_idx) * 20.0
		draw_line(Vector2(-85.0, sy1), Vector2(-105.0, sy2), OUTLINE, 1.2)

	# Main fortified bunker front wall [-85, 85] x [-45, 40]
	var bunker_rect: Rect2 = Rect2(-85.0, -45.0, 170.0, 85.0)
	draw_rect(bunker_rect, TIMBER_DARK)
	_draw_rect_outline(bunker_rect, OUTLINE, 2.5)
	
	# Horizontal timber logs
	for log_idx in 5:
		var ly: float = -45.0 + float(log_idx) * 17.0
		var log_col: Color = TIMBER_LIGHT if (log_idx % 2 == 0) else TIMBER_DARK
		draw_rect(Rect2(-85.0, ly, 170.0, 16.0), log_col)
		draw_line(Vector2(-85.0, ly), Vector2(85.0, ly), OUTLINE, 1.2)
		draw_circle(Vector2(-78.0, ly + 8.0), 1.6, STEEL)
		draw_circle(Vector2(78.0, ly + 8.0), 1.6, STEEL)

	# 2.5D Corrugated metal slanted roof with 3D top surface
	var roof_top: PackedVector2Array = PackedVector2Array([
		Vector2(-85.0, -45.0),
		Vector2(0.0, -62.0),
		Vector2(85.0, -45.0),
		Vector2(65.0, -58.0),
		Vector2(-20.0, -75.0),
		Vector2(-105.0, -58.0)
	])
	draw_colored_polygon(roof_top, STEEL_LIGHT)
	draw_polyline(roof_top, OUTLINE, 2.0)

	var roof_front: PackedVector2Array = PackedVector2Array([
		Vector2(-85.0, -45.0),
		Vector2(0.0, -62.0),
		Vector2(85.0, -45.0),
		Vector2(88.0, -42.0),
		Vector2(0.0, -58.0),
		Vector2(-88.0, -42.0)
	])
	draw_colored_polygon(roof_front, STEEL)
	draw_polyline(roof_front, OUTLINE, 2.0)

	# Heavy reinforced steel vault door
	var door: Rect2 = Rect2(-24.0, -8.0, 48.0, 48.0)
	_draw_soft_rect(door, STEEL_DARK, 4.0)
	_draw_rect_outline(door, OUTLINE, 2.0)
	
	# Hazard diagonal stripes on door frame
	draw_line(Vector2(-22.0, 36.0), Vector2(-12.0, 40.0), CAUTION_YELLOW, 2.5)
	draw_line(Vector2(-8.0, 36.0), Vector2(2.0, 40.0), CAUTION_YELLOW, 2.5)
	draw_line(Vector2(6.0, 36.0), Vector2(16.0, 40.0), CAUTION_YELLOW, 2.5)
	
	# Steel door reinforced viewport
	var glass_port: Rect2 = Rect2(-10.0, 2.0, 20.0, 10.0)
	draw_rect(glass_port, Color(0.40, 0.65, 0.80, 0.85))
	_draw_rect_outline(glass_port, OUTLINE, 1.5)
	draw_line(Vector2(0.0, 2.0), Vector2(0.0, 12.0), OUTLINE, 1.2)

	# Over-door warning lantern
	draw_circle(Vector2(0.0, -20.0), 10.0, GLOW)
	draw_circle(Vector2(0.0, -20.0), 4.0, Color(1.0, 0.90, 0.65, 1.0))
	draw_rect(Rect2(-6.0, -26.0, 12.0, 4.0), STEEL_DARK)

	# Stacked sandbags on the left and right flanks
	for sx in [-75.0, -55.0, 55.0, 75.0]:
		_draw_soft_rect(Rect2(sx - 12.0, 26.0, 24.0, 12.0), SANDBAG, 3.0)
		_draw_rect_outline(Rect2(sx - 12.0, 26.0, 24.0, 12.0), OUTLINE, 1.2)
		_draw_soft_rect(Rect2(sx - 10.0, 16.0, 20.0, 11.0), SANDBAG_SHADOW, 3.0)
		_draw_rect_outline(Rect2(sx - 10.0, 16.0, 20.0, 11.0), OUTLINE, 1.2)


func _draw_soft_rect(r: Rect2, col: Color, radius: float) -> void:
	draw_rect(Rect2(r.position.x + radius, r.position.y, r.size.x - radius * 2.0, r.size.y), col)
	draw_rect(Rect2(r.position.x, r.position.y + radius, r.size.x, r.size.y - radius * 2.0), col)
	draw_circle(r.position + Vector2(radius, radius), radius, col)
	draw_circle(r.position + Vector2(r.size.x - radius, radius), radius, col)
	draw_circle(r.position + Vector2(radius, r.size.y - radius), radius, col)
	draw_circle(r.position + Vector2(r.size.x - radius, r.size.y - radius), radius, col)


func _draw_rect_outline(r: Rect2, col: Color, width: float) -> void:
	var pts := PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, width)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Bạn bước vào hầm trú ẩn an toàn.")
	elif body.is_in_group("zombie"):
		print("Zombie bị đẩy lùi khỏi hầm trú ẩn.")
