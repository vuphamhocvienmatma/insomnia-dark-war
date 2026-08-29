extends Node2D

const SOCKET_SCRIPT := preload("res://scripts/build_socket_2d.gd")
const TURRET_SCENE := preload("res://scenes/auto_turret.tscn")
const SCRAP_SCENE := preload("res://scenes/scrap_item.tscn")
const ZOMBIE_SCENE := preload("res://scenes/zombie.tscn")
const RELIC_SCENE := preload("res://scenes/relic_item.tscn")

var _spawned_zombies: Array[Node2D] = []

func _ready() -> void:
	_spawn_socket_ring()
	_spawn_turrets()
	_spawn_scrap_field()
	# (Đã xóa _spawn_zombie_ambush - zombie chỉ spawn theo đêm)

	if SaveManager:
		SaveManager.load_game()

	var tm = get_tree().get_first_node_in_group("time_manager")
	if tm != null:
		tm.phase_changed.connect(_on_phase_changed)

func _spawn_socket_ring() -> void:
	var ring_radius: float = 400.0
	var socket_count: int = 24
	for i in socket_count:
		var angle := (TAU * float(i)) / float(socket_count)
		var pos := Vector2(cos(angle), sin(angle)) * ring_radius

		var socket := Area2D.new()
		socket.set_script(SOCKET_SCRIPT)
		socket.add_to_group("critical_socket")
		socket.position = pos
		add_child(socket)

		var shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 24.0
		shape.shape = circle
		socket.add_child(shape)

		var sprite := Sprite2D.new()
		sprite.texture = load("res://icon.svg")
		sprite.scale = Vector2(0.15, 0.15)
		sprite.modulate = Color(0.3, 0.8, 1.0, 0.6)
		socket.add_child(sprite)

func _spawn_turrets() -> void:
	var ring_radius: float = 400.0
	var angles := [0.0, PI / 2.0, PI, (3.0 * PI) / 2.0]
	for angle in angles:
		var pos := Vector2(cos(angle), sin(angle)) * ring_radius
		var turret := TURRET_SCENE.instantiate() as Node2D
		turret.position = pos
		add_child(turret)

func _spawn_scrap_field() -> void:
	var scrap_count: int = 40
	var types := ["scrap", "seed", "water"]
	for i in scrap_count:
		var angle := randf() * TAU
		var dist := randf_range(600.0, 1000.0)
		var pos := Vector2(cos(angle), sin(angle)) * dist

		var scrap := SCRAP_SCENE.instantiate() as Node2D
		scrap.position = pos
		scrap.set("item_type", types[randi() % types.size()])
		add_child(scrap)

	var relic_count: int = 3
	var relic_types := ["buff_turret", "buff_plant", "buff_solar"]
	for i in relic_count:
		var angle := randf() * TAU
		var dist := randf_range(850.0, 950.0)  # Randomize thay vì cố định 900.0
		var pos := Vector2(cos(angle), sin(angle)) * dist

		var relic := RELIC_SCENE.instantiate() as Node2D
		relic.position = pos
		relic.set("relic_type", relic_types[randi() % relic_types.size()])
		add_child(relic)

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
		var angle := randf() * TAU
		var pos := Vector2(cos(angle), sin(angle)) * 1100.0

		var zombie := ZOMBIE_SCENE.instantiate() as Node2D
		zombie.position = pos
		add_child(zombie)
		_spawned_zombies.append(zombie)
