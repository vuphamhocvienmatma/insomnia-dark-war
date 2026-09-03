extends Node2D

const OUTLINE: Color = Color(0.16, 0.10, 0.06, 1.0)
const ARROW_COL: Color = Color(0.96, 0.86, 0.60, 1.0)
const ARROW_SHADOW: Color = Color(0.72, 0.54, 0.30, 1.0)
const ACTION_GLOW: Color = Color(1.0, 0.80, 0.35, 1.0)
const TOOLTIP_BG: Color = Color(0.14, 0.10, 0.07, 0.92)
const TOOLTIP_BORDER: Color = Color(0.72, 0.55, 0.32, 1.0)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var parent: CanvasLayer = get_parent() as CanvasLayer
	if parent == null:
		return

	var m_pos: Vector2 = get_viewport().get_mouse_position()
	var action_type: String = str(parent.get("current_action_type"))
	var action_title: String = str(parent.get("current_action_title"))
	var pulse: float = float(parent.get("_pulse_time"))

	# --- 1. Target World Highlight (if actionable target exists) ---
	var hover_target: Node2D = parent.get("current_hover_target") as Node2D
	if hover_target != null and is_instance_valid(hover_target):
		var cam: Camera2D = get_viewport().get_camera_2d()
		if cam != null:
			# Project target world position to viewport screen space
			var screen_pos: Vector2 = (hover_target.global_position - cam.global_position) * cam.zoom + (get_viewport_rect().size * 0.5)
			var ring_rad: float = 24.0 + sin(pulse * 3.0) * 3.0
			var alpha: float = 0.45 + sin(pulse * 3.0) * 0.25
			draw_arc(screen_pos + Vector2(0.0, -18.0), ring_rad, 0.0, TAU, 24, Color(1.0, 0.85, 0.40, alpha), 2.0)
			draw_circle(screen_pos + Vector2(0.0, -18.0), ring_rad * 0.7, Color(1.0, 0.80, 0.30, 0.12 * alpha))

	# --- 2. Action Mode Cursor vs Default Cursor ---
	if action_type != "":
		# Glowing action ring at cursor tip
		var halo_rad: float = 12.0 + sin(pulse * 4.0) * 2.5
		var halo_col: Color = Color(1.0, 0.78, 0.30, 0.35 + sin(pulse * 4.0) * 0.15)
		draw_circle(m_pos, halo_rad, halo_col)

		# Action Pointer Hand Cursor 👆
		var hand_pts: PackedVector2Array = PackedVector2Array([
			m_pos,
			m_pos + Vector2(0.0, 16.0),
			m_pos + Vector2(4.0, 14.0),
			m_pos + Vector2(8.0, 22.0),
			m_pos + Vector2(11.0, 21.0),
			m_pos + Vector2(7.0, 13.0),
			m_pos + Vector2(13.0, 13.0),
			m_pos + Vector2(11.0, 7.0),
			m_pos + Vector2(5.0, 6.0)
		])
		draw_colored_polygon(hand_pts, ACTION_GLOW)
		draw_polyline(hand_pts, OUTLINE, 1.5)

		# Action Tooltip Banner
		if action_title != "":
			var font: Font = ThemeDB.fallback_font
			var text_w: float = font.get_string_size(action_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
			var tip_w: float = text_w + 16.0
			var tip_rect: Rect2 = Rect2(m_pos.x + 16.0, m_pos.y - 12.0, tip_w, 22.0)
			
			# Clamp tooltip inside screen bounds
			var vp_size: Vector2 = get_viewport_rect().size
			if tip_rect.position.x + tip_w > vp_size.x - 8.0:
				tip_rect.position.x = m_pos.x - tip_w - 12.0

			draw_rect(tip_rect, TOOLTIP_BG)
			_draw_rect_outline(tip_rect, TOOLTIP_BORDER)
			draw_string(font, Vector2(tip_rect.position.x + 8.0, tip_rect.position.y + 15.0), action_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.98, 0.90, 0.70, 1.0))

	else:
		# Default Sleek Lofi Brass Arrow Cursor
		var arrow_pts: PackedVector2Array = PackedVector2Array([
			m_pos,
			m_pos + Vector2(0.0, 17.0),
			m_pos + Vector2(4.5, 13.5),
			m_pos + Vector2(8.5, 21.0),
			m_pos + Vector2(11.5, 19.5),
			m_pos + Vector2(7.5, 12.0),
			m_pos + Vector2(13.5, 12.0)
		])
		draw_colored_polygon(arrow_pts, ARROW_COL)
		draw_polyline(arrow_pts, OUTLINE, 1.3)
		# Inner bevel highlight
		draw_line(m_pos + Vector2(1.0, 2.0), m_pos + Vector2(1.0, 14.0), Color(1.0, 1.0, 1.0, 0.6), 1.0)


func _draw_rect_outline(r: Rect2, col: Color) -> void:
	var pts: PackedVector2Array = PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, 1.2)
