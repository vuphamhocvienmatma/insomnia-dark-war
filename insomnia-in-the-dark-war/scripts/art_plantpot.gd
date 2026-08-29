extends Node2D

const OUTLINE := Color(0.13, 0.15, 0.18)
const WOOD_DARK := Color(0.35, 0.22, 0.17)
const LEAF := Color(0.3, 0.7, 0.3)
const FLOWER := Color(0.96, 0.56, 0.69)

var _state: String = "empty"

func set_state(s: String) -> void:
	_state = s
	queue_redraw()

func _draw() -> void:
	var pot := PackedVector2Array([Vector2(-6.0, -12.0), Vector2(6.0, -12.0), Vector2(4.0, 0.0), Vector2(-4.0, 0.0)])
	draw_polygon(pot, [WOOD_DARK, WOOD_DARK, WOOD_DARK, WOOD_DARK])
	var pot_closed := pot.duplicate()
	pot_closed.append(pot[0])
	draw_polyline(pot_closed, OUTLINE, 2.0)

	var progress: float = 0.0
	var p := get_parent()
	if p != null and "growth_progress" in p:
		progress = float(p.get("growth_progress"))

	if progress < 0.33:
		draw_rect(Rect2(-4.0, -12.0, 8.0, 4.0), Color(0.3, 0.22, 0.15, 1.0))
	elif progress < 0.66:
		draw_line(Vector2(0.0, -12.0), Vector2(0.0, -20.0), LEAF, 2.0)
	else:
		draw_line(Vector2(0.0, -12.0), Vector2(0.0, -26.0), LEAF, 2.0)
		draw_circle(Vector2(0.0, -28.0), 4.0, FLOWER)
		draw_polygon([Vector2(-4.0, -20.0), Vector2(-10.0, -22.0), Vector2(-4.0, -16.0)], [LEAF, LEAF, LEAF])
		draw_polygon([Vector2(4.0, -20.0), Vector2(10.0, -22.0), Vector2(4.0, -16.0)], [LEAF, LEAF, LEAF])

	var fill_w: float = 32.0 * progress
	draw_rect(Rect2(-16.0, 32.0, 32.0, 4.0), Color(0.2, 0.2, 0.2, 1.0))
	draw_rect(Rect2(-16.0, 32.0, fill_w, 4.0), Color(0.4, 0.9, 0.4, 1.0))
