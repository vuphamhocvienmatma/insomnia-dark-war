extends Node2D

const OUTLINE := Color(0.18, 0.14, 0.12, 1.0)
const CAST_IRON := Color(0.24, 0.25, 0.28, 1.0)
const CAST_IRON_LIGHT := Color(0.35, 0.36, 0.40, 1.0)
const FIRE_CORE := Color(1.0, 0.90, 0.40, 1.0)
const FIRE_AMBER := Color(0.96, 0.55, 0.15, 1.0)
const KETTLE := Color(0.55, 0.60, 0.65, 1.0)
const BRASS := Color(0.85, 0.68, 0.25, 1.0)

var _fire_time: float = 0.0


func _process(delta: float) -> void:
	_fire_time += delta * 7.0
	queue_redraw()


func _draw() -> void:
	# Stove legs
	draw_line(Vector2(-12.0, 0.0), Vector2(-10.0, -5.0), OUTLINE, 2.5)
	draw_line(Vector2(12.0, 0.0), Vector2(10.0, -5.0), OUTLINE, 2.5)
	
	# Chimney pipe leading up
	var pipe := Rect2(-4.0, -42.0, 8.0, 18.0)
	draw_rect(pipe, CAST_IRON)
	_draw_rect_outline(pipe, OUTLINE)
	draw_rect(Rect2(-5.0, -32.0, 10.0, 3.0), CAST_IRON_LIGHT)
	
	# Main cast-iron stove body
	var body := Rect2(-14.0, -24.0, 28.0, 20.0)
	_draw_rounded_rect(body, CAST_IRON, 3.0)
	_draw_rect_outline(body, OUTLINE)
	# Top cooking plate ledge
	draw_rect(Rect2(-16.0, -25.0, 32.0, 3.0), CAST_IRON_LIGHT)
	_draw_rect_outline(Rect2(-16.0, -25.0, 32.0, 3.0), OUTLINE)
	
	# Firebox door with flickering fire glow
	var door := Rect2(-7.0, -18.0, 14.0, 11.0)
	_draw_rounded_rect(door, Color(0.12, 0.10, 0.10, 1.0), 2.0)
	_draw_rect_outline(door, OUTLINE)
	
	# Flickering fire logs inside door
	var flicker: float = 0.8 + sin(_fire_time) * 0.2
	draw_circle(Vector2(0.0, -12.5), 4.5 * flicker, FIRE_AMBER)
	draw_circle(Vector2(0.0, -12.5), 2.5 * flicker, FIRE_CORE)
	# Door grate iron bars
	draw_line(Vector2(-3.0, -18.0), Vector2(-3.0, -7.0), OUTLINE, 1.2)
	draw_line(Vector2(3.0, -18.0), Vector2(3.0, -7.0), OUTLINE, 1.2)
	# Door brass latch
	draw_circle(Vector2(6.0, -13.0), 1.2, BRASS)
	
	# Cozy whistling camping kettle on top of the stove plate
	var kettle := Rect2(1.0, -32.0, 10.0, 7.0)
	_draw_rounded_rect(kettle, KETTLE, 2.0)
	_draw_rect_outline(kettle, OUTLINE)
	# Kettle spout
	draw_line(Vector2(11.0, -29.0), Vector2(14.0, -31.0), KETTLE, 2.0)
	# Kettle handle
	draw_arc(Vector2(6.0, -32.0), 4.0, -PI, 0.0, 8, OUTLINE, 1.5)


func _draw_rounded_rect(r: Rect2, col: Color, radius: float) -> void:
	draw_rect(r, col)
	draw_circle(Vector2(r.position.x + radius, r.position.y + radius), radius, col)
	draw_circle(Vector2(r.position.x + r.size.x - radius, r.position.y + radius), radius, col)
	draw_circle(Vector2(r.position.x + radius, r.position.y + r.size.y - radius), radius, col)
	draw_circle(Vector2(r.position.x + r.size.x - radius, r.position.y + r.size.y - radius), radius, col)


func _draw_rect_outline(r: Rect2, col: Color) -> void:
	var pts := PackedVector2Array([
		r.position,
		Vector2(r.position.x + r.size.x, r.position.y),
		Vector2(r.position.x + r.size.x, r.position.y + r.size.y),
		Vector2(r.position.x, r.position.y + r.size.y),
		r.position
	])
	draw_polyline(pts, col, 1.5)
