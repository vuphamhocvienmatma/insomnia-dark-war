extends Node2D

const OUTLINE: Color = Color(0.14, 0.10, 0.08, 1.0)
const WOOD_DARK: Color = Color(0.38, 0.26, 0.18, 1.0)
const WOOD_PLANK: Color = Color(0.52, 0.38, 0.26, 1.0)
const IRON_STRAP: Color = Color(0.32, 0.35, 0.38, 1.0)
const STEEL_PLATE: Color = Color(0.48, 0.52, 0.56, 1.0)
const BRASS: Color = Color(0.88, 0.72, 0.30, 1.0)
const RIVET: Color = Color(0.85, 0.85, 0.88, 1.0)
const INNER_WALL: Color = Color(0.15, 0.10, 0.07, 1.0)

var _swing: float = 0.0

func _ready() -> void:
	queue_redraw()

func set_swing(val: float) -> void:
	_swing = val

func _draw() -> void:
	var door_node: Node = get_parent()
	var level: int = door_node.get("reinforce_level") if (door_node != null and "reinforce_level" in door_node) else 1
	var hp: float = float(door_node.get("hp")) if (door_node != null and "hp" in door_node) else 100.0
	var m_hp: float = maxf(float(door_node.get("max_hp")), 1.0) if (door_node != null and "max_hp" in door_node) else 100.0
	var hp_ratio: float = hp / m_hp

	# 0. Solid Wall Backing (To attach door to the house and fill the gap)
	var backing: Rect2 = Rect2(-24.0, -58.0, 38.0, 58.0)
	draw_rect(backing, INNER_WALL)

	# 1. Doorway Frame
	var left_jamb: Rect2 = Rect2(-11.0, -52.0, 3.5, 52.0)
	var right_jamb: Rect2 = Rect2(7.5, -52.0, 3.5, 52.0)
	var lintel: Rect2 = Rect2(-13.0, -55.0, 26.0, 4.0)

	draw_rect(left_jamb, WOOD_DARK)
	_draw_rect_outline(left_jamb, OUTLINE)
	draw_rect(right_jamb, WOOD_DARK)
	_draw_rect_outline(right_jamb, OUTLINE)
	draw_rect(lintel, WOOD_DARK)
	_draw_rect_outline(lintel, OUTLINE)

	# Depth Bevel
	var depth_rect = Rect2(-7.5, -51.0, 15.0, 51.0)
	draw_rect(depth_rect, Color(0.08, 0.05, 0.03, 0.9))
	draw_line(Vector2(-7.5, -51.0), Vector2(-7.5, 0.0), WOOD_DARK.darkened(0.4), 2.0)
	draw_line(Vector2(-7.5, -51.0), Vector2(7.5, -51.0), WOOD_DARK.darkened(0.4), 2.0)

	if _swing > 0.0:
		var p1 = Vector2(-7.5, -51.0)
		var p4 = Vector2(-7.5, 0.0)
		var swing_x = lerpf(-7.5, -24.0, _swing)
		var swing_y_top = lerpf(-51.0, -46.0, _swing)
		var swing_y_bot = lerpf(0.0, -4.0, _swing)
		
		var p2 = Vector2(swing_x, swing_y_top)
		var p3 = Vector2(swing_x, swing_y_bot)
		
		var leaf_pts: PackedVector2Array = PackedVector2Array([p1, p2, p3, p4])
		draw_colored_polygon(leaf_pts, WOOD_PLANK)
		draw_polyline(leaf_pts, OUTLINE, 1.2)
		
		var handle_x = lerpf(4.5, -20.0, _swing)
		var handle_y = lerpf(-24.0, -26.0, _swing)
		draw_circle(Vector2(handle_x, handle_y), 1.5, BRASS)
		return

	# 3. CLOSED DOOR STATE
	var door_rect: Rect2 = Rect2(-7.5, -51.0, 15.0, 51.0)
	draw_rect(door_rect, WOOD_PLANK)
	_draw_rect_outline(door_rect, OUTLINE)

	draw_line(Vector2(-2.5, -51.0), Vector2(-2.5, 0.0), OUTLINE, 1.0)
	draw_line(Vector2(2.5, -51.0), Vector2(2.5, 0.0), OUTLINE, 1.0)

	draw_circle(Vector2(4.5, -24.0), 2.2, BRASS)
	draw_line(Vector2(4.5, -24.0), Vector2(6.5, -24.0), OUTLINE, 1.5)
	draw_circle(Vector2(4.5, -24.0), 0.8, OUTLINE)

	if level >= 2:
		var top_strap: Rect2 = Rect2(-7.5, -42.0, 15.0, 4.0)
		var bot_strap: Rect2 = Rect2(-7.5, -12.0, 15.0, 4.0)
		draw_rect(top_strap, IRON_STRAP)
		_draw_rect_outline(top_strap, OUTLINE)
		draw_rect(bot_strap, IRON_STRAP)
		_draw_rect_outline(bot_strap, OUTLINE)

		for rx in [-5.0, 0.0, 5.0]:
			draw_circle(Vector2(rx, -40.0), 1.2, RIVET)
			draw_circle(Vector2(rx, -10.0), 1.2, RIVET)

		draw_line(Vector2(-6.0, -38.0), Vector2(5.0, -14.0), WOOD_DARK, 2.5)

	if level >= 3:
		var armor: Rect2 = Rect2(-6.5, -34.0, 13.0, 18.0)
		draw_rect(armor, STEEL_PLATE)
		_draw_rect_outline(armor, OUTLINE)
		
		draw_line(Vector2(-7.0, -25.0), Vector2(6.0, -25.0), Color(0.85, 0.65, 0.20, 1.0), 2.5)
		draw_circle(Vector2(-4.0, -31.0), 1.3, RIVET)
		draw_circle(Vector2(4.0, -31.0), 1.3, RIVET)
		draw_circle(Vector2(-4.0, -19.0), 1.3, RIVET)
		draw_circle(Vector2(4.0, -19.0), 1.3, RIVET)

	if hp_ratio < 0.65:
		draw_line(Vector2(-4.0, -30.0), Vector2(1.0, -20.0), Color(0.1, 0.05, 0.05, 0.8), 1.2)
	if hp_ratio < 0.35:
		draw_line(Vector2(2.0, -45.0), Vector2(-3.0, -35.0), Color(0.1, 0.05, 0.05, 0.9), 1.5)

func _draw_rect_outline(r: Rect2, col: Color) -> void:
	var pts: PackedVector2Array = PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, 1.0)