extends Node2D

const OUTLINE: Color = Color(0.14, 0.10, 0.08, 1.0)
const POST_COL: Color = Color(0.46, 0.32, 0.22, 1.0)
const MAILBOX_BODY: Color = Color(0.38, 0.42, 0.46, 1.0)
const MAILBOX_LID: Color = Color(0.28, 0.32, 0.36, 1.0)
const FLAG_RED: Color = Color(0.88, 0.22, 0.18, 1.0)
const BRASS: Color = Color(0.88, 0.72, 0.30, 1.0)

var has_unread_mail: bool = false
var _anim_time: float = 0.0
var _mm: Node = null
var _icon_node: Node2D
var _arc_pts: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	for i in 17:
		var a: float = -PI + float(i) * PI / 16.0
		_arc_pts.append(Vector2(cos(a) * 11.0, -36.0 + sin(a) * 5.0))
	_arc_pts.append(Vector2(11.0, -36.0))
	_arc_pts.append(Vector2(-11.0, -36.0))
	_mm = get_tree().get_first_node_in_group("mailbox_manager")
	if _mm:
		_mm.mail_received.connect(_on_mail_updated)
		_mm.mail_read.connect(_on_mail_updated)
	_icon_node = Node2D.new()
	_icon_node.draw.connect(_draw_bouncing_icon)
	add_child(_icon_node)
	_on_mail_updated({}) # Initial check

func _on_mail_updated(_letter: Dictionary) -> void:
	if _mm and _mm.has_method("has_unread"):
		has_unread_mail = bool(_mm.call("has_unread"))
		queue_redraw()
		if _icon_node: _icon_node.queue_redraw()

func _process(delta: float) -> void:
	if has_unread_mail:
		_anim_time += delta * 3.0
		_icon_node.queue_redraw()


func _draw() -> void:
	# 1. Contact Shadow on ground
	draw_ellipse(Vector2(0.0, 1.0), 9.0, 3.5, Color(0.0, 0.0, 0.0, 0.35))

	# 2. Rustic Wooden Post stuck into ground (x = 0, y from 0 to -24)
	var post_rect: Rect2 = Rect2(-3.5, -24.0, 7.0, 24.0)
	draw_rect(post_rect, POST_COL)
	_draw_rect_outline(post_rect, OUTLINE)
	draw_line(Vector2(-1.0, -22.0), Vector2(-1.0, -2.0), Color(0.32, 0.22, 0.14, 0.8), 1.0)

	# 3. Curved Sheet-Metal Mailbox Body
	var body_rect: Rect2 = Rect2(-11.0, -36.0, 22.0, 13.0)
	draw_rect(body_rect, MAILBOX_BODY)
	_draw_rect_outline(body_rect, OUTLINE)

	# Curved arched top roof of the mailbox
	draw_colored_polygon(_arc_pts, MAILBOX_LID)
	draw_polyline(_arc_pts, OUTLINE, 1.2)

	# Front mail slot flap & brass pull handle
	draw_line(Vector2(-8.0, -30.0), Vector2(8.0, -30.0), OUTLINE, 1.5)
	draw_circle(Vector2(0.0, -27.0), 1.5, BRASS)

	# 4. Red Postal Flag 🚩
	if has_unread_mail:
		# Flag is UP
		draw_line(Vector2(9.0, -30.0), Vector2(9.0, -44.0), OUTLINE, 1.8)
		var flag_pts: PackedVector2Array = PackedVector2Array([
			Vector2(9.0, -44.0),
			Vector2(18.0, -41.0),
			Vector2(9.0, -38.0)
		])
		draw_colored_polygon(flag_pts, FLAG_RED)
		draw_polyline(flag_pts, OUTLINE, 1.0)
		

	else:
		# Flag is DOWN
		draw_line(Vector2(9.0, -30.0), Vector2(18.0, -30.0), OUTLINE, 1.8)
		var flag_down: PackedVector2Array = PackedVector2Array([
			Vector2(18.0, -30.0),
			Vector2(18.0, -35.0),
			Vector2(14.0, -30.0)
		])
		draw_colored_polygon(flag_down, FLAG_RED)


func _draw_bouncing_icon() -> void:
	if not has_unread_mail: return
	var bob: float = sin(_anim_time) * 2.5
	var icon_y: float = -52.0 + bob
	var badge: Rect2 = Rect2(-7.0, icon_y - 4.0, 14.0, 9.0)
	_icon_node.draw_rect(badge, Color(0.98, 0.94, 0.82, 0.95))
	var pts: PackedVector2Array = PackedVector2Array([
		badge.position,
		Vector2(badge.position.x + badge.size.x, badge.position.y),
		Vector2(badge.position.x + badge.size.x, badge.position.y + badge.size.y),
		Vector2(badge.position.x, badge.position.y + badge.size.y),
		badge.position
	])
	_icon_node.draw_polyline(pts, OUTLINE, 1.2)
	_icon_node.draw_line(Vector2(-6.0, icon_y - 3.0), Vector2(0.0, icon_y + 1.0), Color(0.70, 0.50, 0.30), 1.0)
	_icon_node.draw_line(Vector2(6.0, icon_y - 3.0), Vector2(0.0, icon_y + 1.0), Color(0.70, 0.50, 0.30), 1.0)

func _draw_rect_outline(r: Rect2, col: Color) -> void:
	var pts: PackedVector2Array = PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, 1.2)
