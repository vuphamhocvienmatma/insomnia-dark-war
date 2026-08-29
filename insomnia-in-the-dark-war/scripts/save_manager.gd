extends Node

const SAVE_PATH: String = "user://insomnia_save.json"

func save_game() -> void:
	var save_data: Dictionary = {}

	save_data["scrap"] = GameState.scrap_count
	save_data["seeds"] = GameState.seeds_count
	save_data["water"] = GameState.water_count
	save_data["relics"] = GameState.relics_found
	save_data["breach_last_night"] = GameState.breach_last_night
	save_data["is_tired"] = GameState.is_tired
	save_data["turret_damage_multiplier"] = GameState.turret_damage_multiplier
	save_data["plant_harvest_bonus"] = GameState.plant_harvest_bonus
	save_data["solar_charge_multiplier"] = GameState.solar_charge_multiplier

	var built_walls: Array = []
	for wall in get_tree().get_nodes_in_group("defensive_wall"):
		if is_instance_valid(wall):
			built_walls.append({
				"pos_x": wall.global_position.x,
				"pos_y": wall.global_position.y,
				"rot": wall.global_rotation,
				"health": wall.current_health
			})
	save_data["built_walls"] = built_walls

	if JournalManager != null:
		save_data["daily_tasks"] = JournalManager.daily_tasks

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("💾 Đã lưu game thành công!")

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Không tìm thấy file save, bắt đầu game mới.")
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		print("Lỗi parse JSON!")
		return false

	var save_data: Dictionary = json.get_data()

	GameState.scrap_count = int(save_data.get("scrap", 0))
	GameState.seeds_count = int(save_data.get("seeds", 0))
	GameState.water_count = int(save_data.get("water", 0))

	var loaded_relics: Array = save_data.get("relics", [])
	GameState.relics_found.clear()
	for relic in loaded_relics:
		GameState.relics_found.append(str(relic))

	GameState.breach_last_night = bool(save_data.get("breach_last_night", false))
	GameState.is_tired = bool(save_data.get("is_tired", false))
	GameState.turret_damage_multiplier = float(save_data.get("turret_damage_multiplier", 1.0))
	GameState.plant_harvest_bonus = int(save_data.get("plant_harvest_bonus", 0))
	GameState.solar_charge_multiplier = float(save_data.get("solar_charge_multiplier", 1.0))

	for relic in GameState.relics_found:
		if relic == "buff_turret":
			GameState.turret_damage_multiplier = max(GameState.turret_damage_multiplier, 1.5)
		elif relic == "buff_plant":
			GameState.plant_harvest_bonus = max(GameState.plant_harvest_bonus, 2)
		elif relic == "buff_solar":
			GameState.solar_charge_multiplier = max(GameState.solar_charge_multiplier, 1.5)

	GameState.scrap_changed.emit(GameState.scrap_count)
	GameState.seeds_changed.emit(GameState.seeds_count)
	GameState.water_changed.emit(GameState.water_count)
	GameState.tired_changed.emit(GameState.is_tired)

	var wall_scene := preload("res://scenes/wall_piece.tscn")
	var walls_data: Array = save_data.get("built_walls", [])
	for w_data in walls_data:
		var wall := wall_scene.instantiate() as Node2D
		get_tree().current_scene.add_child(wall)
		wall.global_position = Vector2(float(w_data["pos_x"]), float(w_data["pos_y"]))
		wall.global_rotation = float(w_data["rot"])
		wall.set("current_health", float(w_data["health"]))
		var closest_socket: BuildSocket2D = null
		var min_dist: float = 9999.0
		for socket in get_tree().get_nodes_in_group("critical_socket"):
			var dist: float = socket.global_position.distance_to(wall.global_position)
			if dist < min_dist:
				min_dist = dist
				closest_socket = socket
		if closest_socket and min_dist < 30.0:
			closest_socket.is_occupied = true
			closest_socket.occupant_part = wall

	if JournalManager != null and save_data.has("daily_tasks"):
		var loaded_tasks: Array = save_data.get("daily_tasks", [])
		var tasks: Array[Dictionary] = []
		for task_data in loaded_tasks:
			if task_data is Dictionary:
				var task: Dictionary = {}
				task["progress"] = int(task_data.get("progress", 0))
				task["target"] = int(task_data.get("target", 0))
				task["desc"] = str(task_data.get("desc", ""))
				task["type"] = str(task_data.get("type", ""))
				tasks.append(task)
		JournalManager.daily_tasks = tasks
		JournalManager.tasks_updated.emit()

	print("📂 Đã load game thành công!")
	return true
