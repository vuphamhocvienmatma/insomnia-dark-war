extends Node2D

const SOCKET_SCRIPT := preload("res://scripts/build_socket_2d.gd")
const SOCKET_ART := preload("res://scripts/art_socket.gd")
const TURRET_SCENE := preload("res://scenes/auto_turret.tscn")
const SCRAP_SCENE := preload("res://scenes/scrap_item.tscn")
const ZOMBIE_SCENE := preload("res://scenes/zombie.tscn")
const RELIC_SCENE := preload("res://scenes/relic_item.tscn")
const NIGHT_SKY_SCRIPT := preload("res://scripts/art_night_sky.gd")

const GROUND_Y: float = 0.0

var _spawned_zombies: Array[Node2D] = []
var _night_sky: Node2D = null

func _ready() -> void:
	_spawn_sockets()
	_spawn_turrets()
	_spawn_scrap_field()
	_spawn_relics()
	_create_night_sky()

	if SaveManager:
		SaveManager.load_game()

	var tm := get_tree().get_first_node_in_group("time_manager")
	if tm != null:
		tm.phase_changed.connect(_on_phase_changed)

func _spawn_sockets() -> void:
	var socket_x: Array[float] = [-232.0, 232.0]
	var socket_y: Array[float] = [-40.0, -100.0, -160.0]
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

			var art_node := Node2D.new()
			art_node.set_script(SOCKET_ART)
			socket.add_child(art_node)

func _spawn_turrets() -> void:
	var positions: Array[Vector2] = [Vector2(-120.0, -240.0), Vector2(120.0, -240.0)]
	for pos in positions:
		var turret := TURRET_SCENE.instantiate() as Node2D
		turret.position = pos
		add_child(turret)

func _spawn_scrap_field() -> void:
	var scrap_count: int = 40
	var types: Array[String] = ["scrap", "seed", "water"]
	for i in scrap_count:
		var x: float
		if randf() < 0.5:
			x = randf_range(-1200.0, -320.0)
		else:
			x = randf_range(320.0, 1200.0)
		var pos := Vector2(x, GROUND_Y)
		var scrap := SCRAP_SCENE.instantiate() as Node2D
		scrap.position = pos
		scrap.set("item_type", types[randi() % types.size()])
		add_child(scrap)

func _spawn_relics() -> void:
	var relic_x: Array[float] = [-900.0, 700.0, 1000.0]
	var relic_types: Array[String] = ["buff_turret", "buff_plant", "buff_solar"]
	for i in 3:
		var pos := Vector2(relic_x[i], GROUND_Y)
		var relic := RELIC_SCENE.instantiate() as Node2D
		relic.position = pos
		relic.set("relic_type", relic_types[i])
		add_child(relic)

func _create_night_sky() -> void:
	_night_sky = Node2D.new()
	_night_sky.name = "NightSky"
	_night_sky.visible = false
	_night_sky.z_index = -8
	_night_sky.set_script(NIGHT_SKY_SCRIPT)
	add_child(_night_sky)

func _on_phase_changed(is_night: bool) -> void:
	if _night_sky != null:
		_night_sky.visible = is_night

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
		var side: float = -1.0 if (i % 2 == 0) else 1.0
		var x: float = side * 1200.0
		var pos := Vector2(x, GROUND_Y)
		var zombie := ZOMBIE_SCENE.instantiate() as Node2D
		zombie.position = pos
		add_child(zombie)
		_spawned_zombies.append(zombie)
