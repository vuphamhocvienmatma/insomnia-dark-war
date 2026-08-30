extends Area2D

const BUNKER_W: float = 190.0
const BUNKER_H: float = 86.0
const EARTH := Color(0.42, 0.36, 0.30, 1.0)
const EARTH_SOFT := Color(0.55, 0.49, 0.41, 1.0)
const DOOR := Color(0.28, 0.23, 0.20, 1.0)
const GLOW := Color(1.0, 0.82, 0.45, 0.65)
const OUTLINE := Color(0.22, 0.18, 0.15, 1.0)
const SAFE_TINT := Color(0.45, 0.75, 0.55, 0.16)


func _ready() -> void:
	add_to_group("safe_zone")
	monitoring = true
	monitorable = true

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(BUNKER_W, BUNKER_H)
	shape.shape = rect
	add_child(shape)

	body_entered.connect(_on_body_entered)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-BUNKER_W * 0.5, -BUNKER_H * 0.5, BUNKER_W, BUNKER_H), SAFE_TINT)

	var arch := PackedVector2Array([
		Vector2(-95.0, 25.0),
		Vector2(-85.0, -10.0),
		Vector2(-55.0, -38.0),
		Vector2(0.0, -48.0),
		Vector2(55.0, -38.0),
		Vector2(85.0, -10.0),
		Vector2(95.0, 25.0),
		Vector2(95.0, 40.0),
		Vector2(-95.0, 40.0)
	])
	draw_polygon(arch, [EARTH, EARTH, EARTH_SOFT, EARTH_SOFT, EARTH_SOFT, EARTH, EARTH, EARTH, EARTH])
	var closed := arch.duplicate()
	closed.append(arch[0])
	draw_polyline(closed, OUTLINE, 3.0)

	var door := Rect2(-24.0, -5.0, 48.0, 47.0)
	_draw_soft_rect(door, DOOR, 8.0)
	_draw_rect_outline(door, OUTLINE, 2.0)

	draw_circle(Vector2(0.0, -18.0), 8.0, GLOW)
	draw_circle(Vector2(0.0, -18.0), 3.0, Color(1.0, 0.88, 0.55, 1.0))

	# Mái hiên sọc trên cửa hầm
	var awning_colors := [Color(0.85, 0.30, 0.28, 1.0), Color(0.95, 0.93, 0.88, 1.0)]
	for i in 6:
		var ax: float = -36.0 + float(i) * 12.0
		var col: Color = awning_colors[i % 2]
		_draw_soft_rect(Rect2(ax, -52.0, 12.0, 8.0), col, 2.0)

	# Cỏ nhỏ
	for x in [-70.0, -50.0, 52.0, 74.0]:
		draw_line(Vector2(x, 40.0), Vector2(x + 4.0, 32.0), Color(0.35, 0.55, 0.32, 1.0), 2.0)


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
