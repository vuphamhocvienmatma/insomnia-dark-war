extends Node2D

const GROUND_SURFACE: Color = Color(0.32, 0.26, 0.19, 1.0)
const GROUND_PATH: Color = Color(0.26, 0.20, 0.15, 1.0)
const CLIFF_EDGE: Color = Color(0.18, 0.14, 0.10, 1.0)
const DIRT_STRATA_A: Color = Color(0.22, 0.16, 0.12, 1.0)
const DIRT_STRATA_B: Color = Color(0.16, 0.12, 0.08, 1.0)
const ROCK_SUB: Color = Color(0.28, 0.24, 0.20, 1.0)
const ROOT_COL: Color = Color(0.38, 0.28, 0.18, 0.8)

const PEBBLE_A: Color = Color(0.44, 0.40, 0.34, 1.0)
const PEBBLE_B: Color = Color(0.32, 0.28, 0.24, 1.0)
const GRASS_A: Color = Color(0.38, 0.48, 0.26, 0.85)
const GRASS_B: Color = Color(0.48, 0.58, 0.32, 0.90)
const FLOWER_YELLOW: Color = Color(0.95, 0.82, 0.32, 1.0)
const FLOWER_WHITE: Color = Color(0.92, 0.92, 0.88, 1.0)
const SHADOW_TINT: Color = Color(0.0, 0.0, 0.0, 0.3)

var _items: Array[Dictionary] = []
var _sub_rocks: Array[Dictionary] = []
var _time: float = 0.0


func _ready() -> void:
	z_index = -7
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 99
	
	# Scatter 2.5D surface items across the walkable depth plane [y: -6 to 16]
	for i in 45:
		var side: float = -1.0 if (i % 2 == 0) else 1.0
		var x: float = side * rng.randf_range(230.0, 1180.0)
		var y: float = rng.randf_range(-4.0, 14.0)
		var item_type: int = rng.randi() % 3
		_items.append({
			"x": x,
			"y": y,
			"type": item_type,
			"size": rng.randf_range(3.0, 5.5),
			"phase": rng.randf_range(0.0, TAU)
		})

	# Subterranean organic rock strata & buried relics
	for i in 22:
		var rot: float = rng.randf_range(-0.35, 0.35)
		_sub_rocks.append({
			"x": rng.randf_range(-2800.0, 2800.0),
			"y": rng.randf_range(40.0, 240.0),
			"w": rng.randf_range(16.0, 42.0),
			"h": rng.randf_range(8.0, 18.0),
			"rot": rot
		})


func _process(delta: float) -> void:
	_time += delta * 2.2
	queue_redraw()


func _draw() -> void:
	_draw_25d_ground_plane()
	_draw_cutaway_cliff_face()
	_draw_surface_props()


func _draw_25d_ground_plane() -> void:
	# 2.5D Walkable Ground Plane: Widen across entire wasteland [-3200, 3200]
	draw_rect(Rect2(-3200.0, -6.0, 6400.0, 24.0), GROUND_SURFACE)
	
	# Angled path strips & perspective stepping stones
	for step_idx in 70:
		var sx: float = -2800.0 + float(step_idx) * 80.0
		# Don't draw under the cabin [-230, 230]
		if absf(sx) > 235.0:
			draw_line(Vector2(sx, 16.0), Vector2(sx + 12.0, -4.0), GROUND_PATH, 1.5)
			var stone_rect: Rect2 = Rect2(sx - 8.0, 2.0, 16.0, 6.0)
			draw_rect(stone_rect, Color(0.24, 0.19, 0.14, 0.6))


func _draw_cutaway_cliff_face() -> void:
	# Front Cutaway Cliff Drop across [-3200, 3200]
	draw_rect(Rect2(-3200.0, 18.0, 6400.0, 4.0), CLIFF_EDGE)
	draw_rect(Rect2(-3200.0, 22.0, 6400.0, 50.0), DIRT_STRATA_A)
	draw_rect(Rect2(-3200.0, 72.0, 6400.0, 230.0), DIRT_STRATA_B)

	# Organic, tilted subterranean rock boulders with dark outline (NO floating UI boxes!)
	for rock in _sub_rocks:
		var rx: float = float(rock["x"])
		var ry: float = float(rock["y"])
		var rw: float = float(rock["w"])
		var rh: float = float(rock["h"])
		var r_rot: float = float(rock.get("rot", 0.0))
		
		# Draw natural tilted polygonal boulder
		var half_w: float = rw * 0.5
		var half_h: float = rh * 0.5
		var pts: PackedVector2Array = PackedVector2Array([
			Vector2(rx - half_w, ry - half_h + r_rot * 10.0),
			Vector2(rx + half_w * 0.8, ry - half_h - r_rot * 8.0),
			Vector2(rx + half_w, ry + half_h + r_rot * 5.0),
			Vector2(rx - half_w * 0.7, ry + half_h - r_rot * 6.0)
		])
		draw_colored_polygon(pts, ROCK_SUB)
		pts.append(pts[0])
		draw_polyline(pts, Color(0.12, 0.09, 0.06, 0.9), 1.2)
		# Internal sediment vein
		draw_line(
			Vector2(rx - half_w * 0.6, ry),
			Vector2(rx + half_w * 0.5, ry + r_rot * 6.0),
			Color(0.38, 0.32, 0.26, 0.6),
			1.0
		)

	# Cross-section tree roots penetrating the soil across the wider terrain
	for root_x in [-1800.0, -1100.0, -600.0, -320.0, 420.0, 750.0, 1350.0, 2100.0]:
		draw_line(Vector2(root_x, 18.0), Vector2(root_x + 8.0, 45.0), ROOT_COL, 2.5)
		draw_line(Vector2(root_x + 8.0, 45.0), Vector2(root_x + 18.0, 85.0), ROOT_COL, 1.8)
		draw_line(Vector2(root_x + 8.0, 45.0), Vector2(root_x - 12.0, 75.0), ROOT_COL, 1.4)


func _draw_surface_props() -> void:
	for item in _items:
		var x: float = float(item["x"])
		var y: float = float(item["y"])
		var sz: float = float(item["size"])
		var ph: float = float(item["phase"])
		var t: int = int(item["type"])
		
		# 2.5D perspective oval contact shadow on ground
		draw_circle(Vector2(x + 1.0, y + 2.0), sz * 0.7, SHADOW_TINT)

		if t == 0:
			# 2.5D Pebble (highlight top, shadow bottom)
			draw_circle(Vector2(x, y), sz * 0.6, PEBBLE_A)
			draw_circle(Vector2(x - 0.6, y - 0.6), sz * 0.35, PEBBLE_B)
		elif t == 1:
			# 2.5D Swaying grass tuft rooted in perspective
			var sway: float = sin(_time + ph) * 2.0
			draw_line(Vector2(x - 2.0, y), Vector2(x - 4.0 + sway, y - sz * 1.5), GRASS_A, 1.3)
			draw_line(Vector2(x, y), Vector2(x + sway, y - sz * 1.8), GRASS_B, 1.5)
			draw_line(Vector2(x + 2.0, y), Vector2(x + 4.0 + sway, y - sz * 1.3), GRASS_A, 1.3)
		else:
			# 2.5D Tiny wildflower
			var sway: float = sin(_time + ph) * 1.5
			draw_line(Vector2(x, y), Vector2(x + sway, y - sz * 1.5), GRASS_A, 1.2)
			var flower_col: Color = FLOWER_YELLOW if (int(ph * 10.0) % 2 == 0) else FLOWER_WHITE
			draw_circle(Vector2(x + sway, y - sz * 1.5), 2.2, flower_col)
			draw_circle(Vector2(x + sway, y - sz * 1.5), 0.9, Color(0.9, 0.5, 0.2, 1.0))
