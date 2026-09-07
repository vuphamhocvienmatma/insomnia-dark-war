extends Node2D

const OUTLINE: Color = Color(0.16, 0.10, 0.06, 1.0)
const ARROW_COL: Color = Color(0.96, 0.86, 0.60, 1.0)
const ARROW_SHADOW: Color = Color(0.72, 0.54, 0.30, 1.0)
const ACTION_GLOW: Color = Color(1.0, 0.80, 0.35, 1.0)
const TOOLTIP_BG: Color = Color(0.14, 0.10, 0.07, 0.92)
const TOOLTIP_BORDER: Color = Color(0.72, 0.55, 0.32, 1.0)


var _last_pos: Vector2 = Vector2(-999, -999)
var _pulse_timer: float = 0.0



var _click_timer: float = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_click_timer = 0.15
		# Âm thanh cạch ( giả lập bằng việc gọi play_sfx nếu có )
		var _am_placeholder = null
		if am and am.has_method("play_sfx"):
			AudioDirector.play_sfx("click_wood") # Assuming it exists, or just ui_click

func _process(delta: float) -> void:
	if _click_timer > 0.0:
		_click_timer -= delta
		queue_redraw()

	var m_pos: Vector2 = get_viewport().get_mouse_position()
	var parent: CanvasLayer = get_parent() as CanvasLayer
	var has_dynamic_target: bool = parent != null and (
		str(parent.get("current_action_type")) != "" or 
		parent.get("current_hover_target") != null
	)

	if has_dynamic_target:
		_pulse_timer += delta
		if _pulse_timer >= 0.033:
			_pulse_timer = 0.0
			queue_redraw()
	elif m_pos != _last_pos:
		_last_pos = m_pos
		queue_redraw()


func _draw() -> void:
	var parent: CanvasLayer = get_parent() as CanvasLayer
	if parent == null:
		return

	var m_pos: Vector2 = get_viewport().get_mouse_position()
	var action_type: String = str(parent.get("current_action_type"))
	var action_title: String = str(parent.get("current_action_title"))
	var pulse: float = float(parent.get("_pulse_time"))

	# --- Action Mode Cursor vs Default Cursor ---
	if action_type != "":
		# Glowing action ring at cursor tip
		var halo_rad: float = 12.0 + sin(pulse * 4.0) * 2.5
		var halo_col: Color = Color(1.0, 0.78, 0.30, 0.35 + sin(pulse * 4.0) * 0.15)
		draw_circle(m_pos, halo_rad, halo_col)

		
		# Action Pointer
		var click_squeeze = 1.0
		if _click_timer > 0.0:
			click_squeeze = 0.8
		var hw = 6.0 * click_squeeze
		var hl = 16.0 * click_squeeze
		var hand_pts: PackedVector2Array = PackedVector2Array([
			m_pos,
			m_pos + Vector2(-hw, hl),
			m_pos + Vector2(0, hl - 4.0),
			m_pos + Vector2(hw, hl)
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
		var head_pts: PackedVector2Array = PackedVector2Array([
			m_pos,
			m_pos + Vector2(0.0, 16.0),
			m_pos + Vector2(4.5, 12.5),
			m_pos + Vector2(12.0, 12.0)
		])
		var stem_pts: PackedVector2Array = PackedVector2Array([
			m_pos + Vector2(3.5, 11.5),
			m_pos + Vector2(7.5, 19.5),
			m_pos + Vector2(10.5, 18.0),
			m_pos + Vector2(6.5, 10.5)
		])
		draw_colored_polygon(PackedVector2Array([stem_pts[0], stem_pts[1], stem_pts[2]]), ARROW_COL)
		draw_colored_polygon(PackedVector2Array([stem_pts[0], stem_pts[2], stem_pts[3]]), ARROW_COL)
		draw_polyline(PackedVector2Array([stem_pts[0], stem_pts[1], stem_pts[2], stem_pts[3], stem_pts[0]]), OUTLINE, 1.3)
		draw_colored_polygon(PackedVector2Array([head_pts[0], head_pts[1], head_pts[2]]), ARROW_COL)
		draw_colored_polygon(PackedVector2Array([head_pts[0], head_pts[2], head_pts[3]]), ARROW_COL)
		draw_polyline(PackedVector2Array([head_pts[0], head_pts[1], head_pts[2], head_pts[3], head_pts[0]]), OUTLINE, 1.3)
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
