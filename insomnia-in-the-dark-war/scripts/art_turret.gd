extends Node2D

const OUTLINE: Color = Color(0.14, 0.12, 0.10, 1.0)
const STEEL: Color = Color(0.38, 0.40, 0.44, 1.0)
const STEEL_DARK: Color = Color(0.24, 0.26, 0.28, 1.0)
const STEEL_LIGHT: Color = Color(0.55, 0.58, 0.62, 1.0)
const AMMO_OD: Color = Color(0.35, 0.38, 0.28, 1.0)
const BRASS: Color = Color(0.88, 0.72, 0.30, 1.0)
const OPTIC_RED: Color = Color(1.0, 0.25, 0.20, 1.0)


func _draw() -> void:
	# Heavy steel tripod mounting base
	draw_line(Vector2(-14.0, 0.0), Vector2(-6.0, -8.0), STEEL_DARK, 3.5)
	draw_line(Vector2(14.0, 0.0), Vector2(6.0, -8.0), STEEL_DARK, 3.5)
	draw_line(Vector2(0.0, 0.0), Vector2(0.0, -9.0), STEEL_DARK, 4.0)
	
	# Base mounting plate
	var mount: Rect2 = Rect2(-10.0, -10.0, 20.0, 5.0)
	draw_rect(mount, STEEL)
	_draw_rect_outline(mount, OUTLINE, 1.5)
	
	# Turret swivel housing
	var body: Rect2 = Rect2(-9.0, -22.0, 18.0, 13.0)
	_draw_rounded_rect(body, STEEL_DARK, 2.5)
	_draw_rect_outline(body, OUTLINE, 1.5)
	
	# Top armor plating
	draw_rect(Rect2(-10.0, -23.0, 20.0, 3.0), STEEL_LIGHT)
	_draw_rect_outline(Rect2(-10.0, -23.0, 20.0, 3.0), OUTLINE, 1.2)
	
	# Green ammo canister box on the side
	var ammo_box: Rect2 = Rect2(-16.0, -18.0, 8.0, 10.0)
	draw_rect(ammo_box, AMMO_OD)
	_draw_rect_outline(ammo_box, OUTLINE, 1.2)
	# Linked brass ammo belt feeding in
	draw_circle(Vector2(-8.0, -14.0), 1.6, BRASS)
	draw_circle(Vector2(-6.5, -15.0), 1.6, BRASS)
	
	# Heavy dual machine gun barrels
	var b1: Rect2 = Rect2(8.0, -21.0, 16.0, 3.5)
	var b2: Rect2 = Rect2(8.0, -15.0, 16.0, 3.5)
	draw_rect(b1, STEEL)
	_draw_rect_outline(b1, OUTLINE, 1.2)
	draw_rect(b2, STEEL)
	_draw_rect_outline(b2, OUTLINE, 1.2)
	# Perforated muzzle brakes
	draw_rect(Rect2(22.0, -22.0, 4.0, 5.5), STEEL_DARK)
	draw_rect(Rect2(22.0, -16.0, 4.0, 5.5), STEEL_DARK)
	
	# Targeting optical sensor lens with glowing red laser eye
	draw_circle(Vector2(2.0, -16.0), 3.0, STEEL_DARK)
	draw_circle(Vector2(2.0, -16.0), 1.8, OPTIC_RED)
	draw_circle(Vector2(1.5, -16.5), 0.7, Color(1.0, 0.9, 0.9, 1.0))


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
