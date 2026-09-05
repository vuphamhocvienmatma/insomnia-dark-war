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
const GROUND_PROPS_SCRIPT := preload("res://scripts/art_ground_props.gd")
const MAILBOX_SCENE := preload("res://scenes/mailbox.tscn")
const CABIN_DOOR_SCENE := preload("res://scenes/cabin_door.tscn")
const MERCHANT_DOG_SCENE := preload("res://scenes/merchant_dog.tscn")
const CURSOR_SCRIPT := preload("res://scripts/interactive_cursor.gd")

const GROUND_Y: float = 0.0

var _spawned_zombies: Array[Node2D] = []
var _night_sky: Node2D = null
var _weather: Node2D = null
var day_count: int = 1


func _ready() -> void:
	var cursor_layer: CanvasLayer = CanvasLayer.new()
	cursor_layer.set_script(CURSOR_SCRIPT)
	add_child(cursor_layer)

	var skyline := Node2D.new()
	skyline.set_script(SKYLINE_SCRIPT)
	add_child(skyline)

	var cabin_props := Node2D.new()
	cabin_props.set_script(CABIN_PROPS_SCRIPT)
	add_child(cabin_props)

	_spawn_cabin_door()
	_spawn_mailbox()
	_spawn_merchant_dog()
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
	var positions: Array[Vector2] = [Vector2(-130.0, -215.0), Vector2(130.0, -215.0)]
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
	var ground_props := Node2D.new()
	ground_props.set_script(GROUND_PROPS_SCRIPT)
	add_child(ground_props)

func _create_night_sky() -> void:
	_night_sky = Node2D.new()
	_night_sky.name = "NightSky"
	_night_sky.visible = false
	_night_sky.z_index = -9
	_night_sky.set_script(NIGHT_SKY_SCRIPT)
	add_child(_night_sky)

var current_night_mutation: String = ""
var current_weather: String = "sunny"


func _on_phase_changed(is_night: bool) -> void:
	if not is_night:
		day_count += 1
		_roll_daily_weather()
		_check_nightmare_night_announcement()
		update_merchant_dog_visibility()

	if _night_sky != null:
		_night_sky.visible = is_night
	if _weather != null:
		_weather.visible = is_night or current_weather != "sunny"
		if _weather.has_method("set_weather"):
			_weather.call("set_weather", current_weather)

	if is_night:
		if current_night_mutation == "solar_eclipse":
			var tm: Node = get_tree().get_first_node_in_group("time_manager")
			if tm != null and "current_solar_energy" in tm:
				tm.set("current_solar_energy", float(tm.get("current_solar_energy")) * 0.5)
		_respawn_zombie_wave()
	else:
		for zombie in get_tree().get_nodes_in_group("zombie"):
			if is_instance_valid(zombie):
				zombie.queue_free()
		_spawned_zombies.clear()


func _roll_daily_weather() -> void:
	var weathers: Array[String] = ["sunny", "drizzle", "heavy_rain", "thick_fog", "snowstorm", "meteor_shower"]
	current_weather = weathers[randi() % weathers.size()]
	
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_toast"):
		if current_weather == "drizzle":
			hud.call("show_toast", "🌧️ Mưa phùn: Sương giăng mỏng, thời tiết êm dịu.", 5.0, false)
		elif current_weather == "heavy_rain":
			hud.call("show_toast", "⛈️ Mưa rào: Mưa xối xả và sấm chớp giật đùng đùng!", 5.0, true)
		elif current_weather == "thick_fog":
			hud.call("show_toast", "🌫️ Sương mù dày: Tầm nhìn hạn chế, âm thanh tắc nghẽn.", 5.0, false)
		elif current_weather == "snowstorm":
			hud.call("show_toast", "❄️ Bão tuyết: Lạnh giá bao trùm, tuyết rơi trắng xóa.", 5.0, true)
		elif current_weather == "meteor_shower":
			hud.call("show_toast", "🌠 Mưa sao băng: Bầu trời rực rỡ, phế liệu hiếm rơi rụng!", 5.0, false)
		else:
			hud.call("show_toast", "🌤️ Nắng vàng êm: Bầu trời trong xanh ấm áp.", 5.0, false)

	if current_weather == "meteor_shower" and GameState != null:
		GameState.add_scrap(12)


func _check_nightmare_night_announcement() -> void:
	if day_count % 5 == 0:
		var mutations: Array[String] = ["zombie_speed_boost", "scrap_jackpot", "solar_eclipse", "dense_fog"]
		current_night_mutation = mutations[randi() % mutations.size()]
		var hud: Node = get_tree().get_first_node_in_group("hud")
		var m_desc: String = ""
		if current_night_mutation == "zombie_speed_boost":
			m_desc = "Zombie cuồng nộ tăng 30% tốc độ chạy!"
		elif current_night_mutation == "scrap_jackpot":
			m_desc = "Đàn zombie đông x1.5 nhưng rơi gấp đôi phế liệu!"
		elif current_night_mutation == "solar_eclipse":
			m_desc = "Bão từ làm sụt giảm 50% pin Solar!"
		elif current_night_mutation == "dense_fog":
			m_desc = "Sương mù dày đặc che khuất bầy zombie!"

		if hud != null and hud.has_method("show_toast"):
			hud.call("show_toast", "📻 [RADIO CẢNH BÁO] ĐÊM ÁC MỘNG NGÀY " + str(day_count) + ": " + m_desc, 6.0, true)
	else:
		current_night_mutation = ""


func _respawn_zombie_wave() -> void:
	var speed_multiplier: float = 1.0 + (float(day_count) * 0.05) if day_count <= 10 else 1.5
	var wave_size: int = 10 + int(GameState.scrap_count / 5.0) + (day_count * 2)
	if current_night_mutation == "scrap_jackpot":
		wave_size = int(float(wave_size) * 1.5)
	wave_size = mini(wave_size, 18)

	for i in wave_size:
		var side: float = -1.0 if (i % 2 == 0) else 1.0
		var x: float = side * randf_range(1100.0, 1350.0)
		var pos := Vector2(x, GROUND_Y)
		var zombie := ZOMBIE_SCENE.instantiate() as Node2D
		zombie.position = pos

		# Variety rolls
		var roll: float = randf()
		var z_type: String = "normal"
		if roll < 0.25:
			z_type = "runner"
		elif roll < 0.45:
			z_type = "thief"
		elif roll < 0.65 and day_count >= 2:
			z_type = "brute"
		else:
			z_type = "normal"

		add_child(zombie)
		if zombie.has_method("setup_type"):
			zombie.call("setup_type", z_type)

		if current_night_mutation == "zombie_speed_boost":
			zombie.set("speed", float(zombie.get("speed")) * 1.30)
		else:
			zombie.set("speed", float(zombie.get("speed")) * speed_multiplier)

		_spawn_zombies.append(zombie)


var _spawn_zombies: Array[Node2D] = []


func _spawn_mailbox() -> void:
	var m_box := MAILBOX_SCENE.instantiate() as Node2D
	m_box.position = Vector2(-225.0, 0.0)
	add_child(m_box)


func _spawn_cabin_door() -> void:
	var door := CABIN_DOOR_SCENE.instantiate() as Node2D
	door.position = Vector2(-195.0, 0.0)
	add_child(door)


func _spawn_merchant_dog() -> void:
	var dog := MERCHANT_DOG_SCENE.instantiate() as Node2D
	dog.position = Vector2(-265.0, 0.0)
	add_child(dog)
	update_merchant_dog_visibility()


func update_merchant_dog_visibility() -> void:
	var dog: Node2D = get_tree().get_first_node_in_group("merchant_dog") as Node2D
	if dog != null:
		var is_visiting: bool = (day_count == 1 or day_count % 3 == 0)
		dog.visible = is_visiting
		dog.set_process(is_visiting)
		dog.set_physics_process(is_visiting)


func get_save_data() -> Dictionary:
	return {
		"day_count": day_count,
		"current_weather": current_weather,
		"current_night_mutation": current_night_mutation
	}


func load_save_data(data: Dictionary) -> void:
	if data.has("day_count"):
		day_count = int(data["day_count"])
	if data.has("current_weather"):
		current_weather = str(data["current_weather"])
	if data.has("current_night_mutation"):
		current_night_mutation = str(data["current_night_mutation"])
	update_merchant_dog_visibility()
