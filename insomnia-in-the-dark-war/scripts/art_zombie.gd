extends Node2D

const OUTLINE := Color(0.12, 0.10, 0.10)
const SKIN := Color(0.55, 0.70, 0.55)
const BODY := Color(0.30, 0.28, 0.25)
const PANTS := Color(0.20, 0.18, 0.16)
const EYE := Color(0.9, 0.2, 0.1)

var _sway: float = 0.0
var _sway_offset: float = 0.0


func _process(delta: float) -> void:
	_sway += delta * 3.0
	_sway_offset = sin(_sway) * 4.0
	var pn := get_parent() as Node2D
	if pn != null:
		pn.rotation = sin(_sway) * 0.1
	queue_redraw()


func _draw() -> void:
	_draw_body()
	_draw_pants()
	_draw_head()
	_draw_arm()

func _draw_body() -> void:
	var body := Rect2(-7.0, -20.0, 14.0, 12.0)
	draw_rect(body, BODY)
	_draw_rect_outline(body, OUTLINE)

func _draw_pants() -> void:
	var pants := Rect2(-6.0, -8.0, 12.0, 8.0)
	draw_rect(pants, PANTS)
	_draw_rect_outline(pants, OUTLINE)

func _draw_head() -> void:
	var head_pos := Vector2(_sway_offset, -26.0)
	draw_circle(head_pos, 7.0, SKIN)
	_draw_circle_outline(head_pos, 7.0, OUTLINE)
	draw_circle(Vector2(-2.0, -26.0), 1.5, EYE)
	draw_circle(Vector2(3.0, -26.0), 1.5, EYE)

func _draw_arm() -> void:
	var arm := Rect2(8.0, -18.0, 3.0, 12.0)
	draw_rect(arm, SKIN)
	_draw_rect_outline(arm, OUTLINE)

func _draw_rect_outline(r: Rect2, col: Color) -> void:
	var pts := PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, 2.0)

func _draw_circle_outline(c: Vector2, rad: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 16:
		var a := TAU * float(i) / 16.0
		pts.append(c + Vector2(cos(a), sin(a)) * rad)
	draw_polyline(pts, col, 2.0)
