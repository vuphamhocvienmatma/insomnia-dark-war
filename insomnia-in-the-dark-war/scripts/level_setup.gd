extends Node2D

const SOCKET_SCRIPT := preload("res://scripts/build_socket_2d.gd")
const TURRET_SCENE := preload("res://scenes/auto_turret.tscn")
const SCRAP_SCENE := preload("res://scenes/scrap_item.tscn")
const ZOMBIE_SCENE := preload("res://scenes/zombie.tscn")
const RELIC_SCENE := preload("res://scenes/relic_item.tscn")

const GROUND_Y: float = 0.0

var _spawned_zombies: Array[Node2D] = []

func _ready() -> void:
	_spawn_wall_columns()
	_spawn_turrets()
	_spawn_scrap_field()
	_spawn_sky_details()
	_spawn_ground_details()

	if SaveManager:
		SaveManager.load_game()

	var tm = get_tree().get_first_node_in_group("time_manager")
	if tm != null:
		tm.phase_changed.connect(_on_phase_changed)

func _spawn_wall_columns() -> void:
	var socket_x := [-220.0, 220.0]
	var socket_y := [-20.0, -80.0, -140.0]
	for x in socket_x:
		for y in socket_y:
			var socket := Area2D.new()
			socket.set_script(SOCKET_SCRIPT)
			socket.add_to_group("critical_socket")
			socket.position = Vector2(x, y)
			add_child(socket)

			var shape := CollisionShape2D.new()
			var circle := CircleShape2D.new()
			circle.radius = 24.0
			shape.shape = circle
			socket.add_child(shape)

			var sprite := Sprite2D.new()
			sprite.texture = load("res://icon.svg")
			sprite.scale = Vector2(0.25, 0.25)
			sprite.modulate = Color(0.3, 0.8, 1.0, 0.9)
			socket.add_child(sprite)

func _spawn_turrets() -> void:
	var positions := [Vector2(-140.0, -250.0), Vector2(140.0, -250.0)]
	for pos in positions:
		var turret := TURRET_SCENE.instantiate() as Node2D
		turret.position = pos
		add_child(turret)
		var collider := turret.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if collider != null and collider.shape is CircleShape2D:
			(collider.shape as CircleShape2D).radius = 300.0
		_boost_sprite(turret)

func _spawn_scrap_field() -> void:
	var scrap_count: int = 40
	var types := ["scrap", "seed", "water"]
	for i in scrap_count:
		var x: float
		if randf() < 0.5:
			x = randf_range(-1100.0, -300.0)
		else:
			x = randf_range(300.0, 1100.0)
		var pos := Vector2(x, GROUND_Y)
		var scrap := SCRAP_SCENE.instantiate() as Node2D
		scrap.position = pos
		scrap.set("item_type", types[randi() % types.size()])
		add_child(scrap)
		_boost_sprite(scrap)

	var relic_count: int = 3
	var relic_types := ["buff_turret", "buff_plant", "buff_solar"]
	for i in relic_count:
		var x := randf_range(900.0, 1100.0) * (1.0 if randf() < 0.5 else -1.0)
		var pos := Vector2(x, GROUND_Y)
		var relic := RELIC_SCENE.instantiate() as Node2D
		relic.position = pos
		relic.set("relic_type", relic_types[randi() % relic_types.size()])
		add_child(relic)
		_boost_sprite(relic)

func _spawn_sky_details() -> void:
	var moon := ColorRect.new()
	moon.size = Vector2(48.0, 48.0)
	moon.position = Vector2(-700.0, -520.0)
	moon.color = Color(0.91, 0.91, 0.94, 1.0)
	moon.z_index = -9
	add_child(moon)

	for i in 10:
		var star := ColorRect.new()
		star.size = Vector2(4.0, 4.0)
		star.position = Vector2(randf_range(-1100.0, 1100.0), randf_range(-650.0, -300.0))
		star.color = Color(1.0, 1.0, 1.0, 0.7)
		star.z_index = -9
		add_child(star)

func _spawn_ground_details() -> void:
	for i in 14:
		var rock := ColorRect.new()
		var s := randf_range(8.0, 20.0)
		rock.size = Vector2(s, s)
		var side := -1.0 if randf() < 0.5 else 1.0
		rock.position = Vector2(side * randf_range(250.0, 1150.0), randf_range(8.0, 90.0))
		if randf() < 0.5:
			rock.color = Color(0.13, 0.13, 0.13, 1.0)
		else:
			rock.color = Color(0.22, 0.22, 0.22, 1.0)
		rock.z_index = -8
		add_child(rock)

func _on_phase_changed(is_night: bool) -> void:
	if is_night:
		_respawn_zombie_wave()
	else:
		for zombie in get_tree().get_nodes_in_group("zombie"):
			if is_instance_valid(zombie):
				zombie.queue_free()
		_spawned_zombies.clear()

func _respawn_zombie_wave() -> void:
	var wave_size: int = 10 + int(GameState.scrap_count / 5.0)
	for i in wave_size:
		var x := 1200.0 * (1.0 if randf() < 0.5 else -1.0)
		var pos := Vector2(x, GROUND_Y)
		var zombie := ZOMBIE_SCENE.instantiate() as Node2D
		zombie.position = pos
		add_child(zombie)
		_spawned_zombies.append(zombie)

func _boost_sprite(node: Node2D) -> void:
	var sprite := node.get_node_or_null("Sprite2D") as Sprite2D
	if sprite != null and sprite.scale.x < 0.2:
		sprite.scale = Vector2(0.5, 0.5)
