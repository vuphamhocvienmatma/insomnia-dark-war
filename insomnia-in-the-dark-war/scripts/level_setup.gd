extends Node2D

const SOCKET_SCRIPT := preload("res://scripts/build_socket_2d.gd")
const SOCKET_ART := preload("res://scripts/art_socket.gd")
const TURRET_SCENE := preload("res://scenes/auto_turret.tscn")
const SCRAP_SCENE := preload("res://scenes/scrap_item.tscn")
const ZOMBIE_SCENE := preload("res://scenes/zombie.tscn")
const RELIC_SCENE := preload("res://scenes/relic_item.tscn")
const NIGHT_SKY_SCRIPT := preload("res://scripts/art_night_sky.gd")
const SKYLINE_SCRIPT := preload("res://scripts/art_skyline.gd")
const CABIN_PROPS_SCRIPT := preload("res://scripts/art_cabin_props.gd")
const WEATHER_SCRIPT := preload("res://scripts/art_weather.gd")

const GROUND_Y: float = 0.0

var _spawned_zombies: Array[Node2D] = []
var _night_sky: Node2D = null
var _weather: Node2D = null
var day_count: int = 1

func _ready() -> void:
	var skyline := Node2D.new()
	skyline.set_script(SKYLINE_SCRIPT)
	add_child(skyline)

	var cabin_props := Node2D.new()
	cabin_props.set_script(CABIN_PROPS_SCRIPT)
	add_child(cabin_props)

	_spawn_sockets()
	_spawn_turrets()
	_spawn_scrap_field()
	_spawn_relics()
	_spawn_ground_details()
	_create_night_sky()
	var weather := Node2D.new()
	weather.name = "Weather"
	weather.set_script(WEATHER_SCRIPT)
	add_child(weather)
	_weather = weather

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
	var scrap_count: int = 26
	var types: Array[String] = ["scrap", "seed", "water"]
	for i in scrap_count:
		var x: float
		if randf() < 0.5:
			x = randf_range(-1150.0, -420.0)
		else:
			x = randf_range(420.0, 1150.0)
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

func _spawn_ground_details() -> void:
	for i in 8:
		var rock := ColorRect.new()
		var s := randf_range(4.0, 8.0)
		rock.size = Vector2(s, s)
		var side := -1.0 if randf() < 0.5 else 1.0
		rock.position = Vector2(side * randf_range(500.0, 1150.0), randf_range(2.0, 10.0))
		if randf() < 0.5:
			rock.color = Color(0.36, 0.31, 0.26, 1.0)
		else:
			rock.color = Color(0.44, 0.39, 0.33, 1.0)
		rock.z_index = -8
		add_child(rock)

func _create_night_sky() -> void:
	_night_sky = Node2D.new()
	_night_sky.name = "NightSky"
	_night_sky.visible = false
	_night_sky.z_index = -9
	_night_sky.set_script(NIGHT_SKY_SCRIPT)
	add_child(_night_sky)

func _on_phase_changed(is_night: bool) -> void:
	if not is_night:
		day_count += 1
	if _night_sky != null:
		_night_sky.visible = is_night
	if _weather != null:
		_weather.visible = is_night

	if is_night:
		_respawn_zombie_wave()
	else:
		for zombie in get_tree().get_nodes_in_group("zombie"):
			if is_instance_valid(zombie):
				zombie.queue_free()
		_spawned_zombies.clear()

func _respawn_zombie_wave() -> void:
	var speed_multiplier: float = 1.0 + (float(day_count) * 0.05) if day_count <= 10 else 1.5
	var wave_size: int = 10 + int(GameState.scrap_count / 5.0) + (day_count * 2)
	for i in wave_size:
		var side: float = -1.0 if (i % 2 == 0) else 1.0
		var x: float = side * 1200.0
		var pos := Vector2(x, GROUND_Y)
		var zombie := ZOMBIE_SCENE.instantiate() as Node2D
		zombie.position = pos
		zombie.set("speed", 30.0 * speed_multiplier)
		add_child(zombie)
		_spawned_zombies.append(zombie)
