import re, os

path = 'scripts/art_ground_props.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

new_struct = '''
var _layer3: Node2D
var _camera: Node2D

func _ready() -> void:
	z_index = -7
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 99
	
	var flora_items: Array[Dictionary] = []

	# Scatter 2.5D surface items across the walkable depth plane [y: -6 to 16]
	for i in 45:
		var side: float = -1.0 if (i % 2 == 0) else 1.0
		var x: float = side * rng.randf_range(230.0, 1180.0)
		var y: float = rng.randf_range(-4.0, 14.0)
		var item_type: int = rng.randi() % 3
		var dict: Dictionary = {
			"x": x,
			"y": y,
			"type": item_type,
			"size": rng.randf_range(3.0, 5.5),
			"phase": rng.randf_range(0.0, TAU)
		}
		if item_type == 0:
			_pebbles.append(dict)
		else:
			flora_items.append(dict)

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

	_flora_node = FloraAmbient.new()
	_flora_node.set("flora_items", flora_items)
	add_child(_flora_node)

	_layer3 = Node2D.new()
	_layer3.draw.connect(_draw_layer3)
	add_child(_layer3)
	move_child(_layer3, 0) # Draw layer 3 behind foreground
	
	_camera = get_tree().get_first_node_in_group("main_camera")
	queue_redraw()

func _process(_delta: float) -> void:
	if _camera == null:
		_camera = get_tree().get_first_node_in_group("main_camera")
	if _camera != null:
		_layer3.position.x = _camera.global_position.x * 0.6

func _draw_layer3() -> void:
	# Layer 3: Midground Sand Dunes and Rails
	_layer3.draw_rect(Rect2(-4000.0, -120.0, 8000.0, 114.0), Color(0.25, 0.18, 0.12, 1.0))
	# Draw some dunes
	var rng = RandomNumberGenerator.new()
	rng.seed = 44
	var dx = -4000.0
	while dx < 4000.0:
		var w = rng.randf_range(200.0, 600.0)
		var h = rng.randf_range(30.0, 80.0)
		# A simple triangle for dune
		var pts = PackedVector2Array([
			Vector2(dx, -6.0),
			Vector2(dx + w*0.5, -6.0 - h),
			Vector2(dx + w, -6.0)
		])
		_layer3.draw_colored_polygon(pts, Color(0.28, 0.20, 0.14, 1.0))
		_layer3.draw_polyline(pts, Color(0.20, 0.14, 0.10, 1.0), 2.0)
		
		# Maybe a broken sign or rail
		if rng.randf() < 0.3:
			_layer3.draw_line(Vector2(dx + w*0.3, -6.0), Vector2(dx + w*0.3, -40.0), Color(0.1, 0.1, 0.1, 1.0), 3.0)
			_layer3.draw_rect(Rect2(dx + w*0.3 - 10.0, -40.0, 20.0, 12.0), Color(0.4, 0.3, 0.2, 1.0))
		
		dx += w * 0.8
'''
content = re.sub(r'func _ready\(\) -> void:.*?(?=func _draw\(\) -> void:)', new_struct, content, flags=re.DOTALL)
with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated art_ground_props.gd")
