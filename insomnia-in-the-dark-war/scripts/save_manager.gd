extends Node

const SAVE_PATH: String = "user://insomnia_save.json"

var _unlocked_ids: Array[String] = []


func unlock(id: String) -> void:
	if not _unlocked_ids.has(id):
		_unlocked_ids.append(id)


func has_unlocked(id: String) -> bool:
	return _unlocked_ids.has(id)

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
	save_data["eco_mode"] = GameState.eco_mode
	save_data["meal_buff"] = GameState.meal_buff
	save_data["active_cooking_buff"] = GameState.active_cooking_buff

	# Cabin decorations
	var cdm: Node = get_tree().root.find_child("CabinDecorationManager", true, false)
	if cdm != null:
		save_data["unlocked_decorations"] = cdm.get("unlocked_decorations")
		save_data["light_color_theme"] = cdm.get("light_color_theme")

	# Merchant store and dog visit state
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null and "merchant_modal" in hud and hud.get("merchant_modal") != null:
		var mm_node = hud.get("merchant_modal")
		if mm_node.has_method("get_save_data"):
			save_data["merchant_data"] = mm_node.call("get_save_data")

	# Level day count and weather
	var ls: Node = get_tree().root.find_child("LevelSetup", true, false)
	if ls != null and ls.has_method("get_save_data"):
		save_data["level_data"] = ls.call("get_save_data")

	var built_walls: Array = []
	for wall in get_tree().get_nodes_in_group("defensive_wall"):
		if wall.is_in_group("cabin_door"):
			continue
		if is_instance_valid(wall):
			built_walls.append({
				"pos_x": wall.global_position.x,
				"pos_y": wall.global_position.y,
				"rot": wall.global_rotation,
				"health": wall.current_health
			})
	save_data["built_walls"] = built_walls

	# Cabin door state
	var doors: Array = []
	for door in get_tree().get_nodes_in_group("cabin_door"):
		if is_instance_valid(door):
			doors.append({
				"is_open": door.get("is_open"),
				"reinforce_level": door.get("reinforce_level"),
				"hp": door.get("hp"),
				"max_hp": door.get("max_hp")
			})
	if not doors.is_empty():
		save_data["door_state"] = doors[0]

	# Mailbox sender affinity
	if MailboxManager != null and "sender_affinity" in MailboxManager:
		save_data["sender_affinity"] = MailboxManager.sender_affinity

	# Unlocked IDs
	save_data["unlocked_ids"] = _unlocked_ids.duplicate()

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

	var raw_data = json.get_data()
	if typeof(raw_data) != TYPE_DICTIONARY:
		print("Lỗi: Dữ liệu save không phải là Dictionary!")
		return false
	var save_data: Dictionary = raw_data as Dictionary

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

	if save_data.has("eco_mode"):
		GameState.set_eco_mode(bool(save_data["eco_mode"]))

	if save_data.has("meal_buff"):
		GameState.meal_buff = bool(save_data["meal_buff"])
	if save_data.has("active_cooking_buff"):
		GameState.active_cooking_buff = str(save_data["active_cooking_buff"])

	# Load unlocked IDs
	if save_data.has("unlocked_ids"):
		_unlocked_ids.clear()
		for uid in save_data["unlocked_ids"]:
			_unlocked_ids.append(str(uid))
	if GameState.meal_buff and GameState.active_cooking_buff != "":
		if GameState.active_cooking_buff == "solar":
			GameState.solar_charge_multiplier = 1.15
		elif GameState.active_cooking_buff == "speed":
			var p: Node2D = get_tree().get_first_node_in_group("player") as Node2D
			if p != null:
				p.set("speed", 135.0)
		elif GameState.active_cooking_buff == "lucky_cat":
			var c: Node = get_tree().get_first_node_in_group("companion_cat")
			if c != null:
				c.set("lucky_loot", true)

	# Restore cabin decorations
	var cdm: Node = get_tree().root.find_child("CabinDecorationManager", true, false)
	if cdm != null:
		if save_data.has("unlocked_decorations") and save_data["unlocked_decorations"] is Dictionary:
			cdm.set("unlocked_decorations", save_data["unlocked_decorations"])
		if save_data.has("light_color_theme"):
			cdm.set("light_color_theme", save_data["light_color_theme"])
		if cdm.has_method("calculate_cozy_score"):
			cdm.call("calculate_cozy_score")

	# Restore cabin door state
	if save_data.has("door_state"):
		var ds: Dictionary = save_data["door_state"]
		var doors: Array = get_tree().get_nodes_in_group("cabin_door")
		if not doors.is_empty():
			var door: Node = doors[0]
			if is_instance_valid(door):
				door.set("is_open", bool(ds.get("is_open", false)))
				door.set("reinforce_level", int(ds.get("reinforce_level", 1)))
				door.set("hp", float(ds.get("hp", 100.0)))
				door.set("max_hp", float(ds.get("max_hp", 100.0)))

	# Restore mailbox sender affinity
	if save_data.has("sender_affinity") and MailboxManager != null:
		var loaded_aff: Dictionary = save_data["sender_affinity"]
		for sender in loaded_aff:
			MailboxManager.sender_affinity[str(sender)] = int(loaded_aff[sender])

	# Restore level data (day count, weather)
	if save_data.has("level_data"):
		var ls: Node = get_tree().root.find_child("LevelSetup", true, false)
		if ls != null and ls.has_method("load_save_data"):
			ls.call("load_save_data", save_data["level_data"])

	# Restore merchant data
	if save_data.has("merchant_data"):
		var hud: Node = get_tree().get_first_node_in_group("hud")
		if hud != null and "merchant_modal" in hud and hud.get("merchant_modal") != null:
			var mm_node = hud.get("merchant_modal")
			if mm_node.has_method("load_save_data"):
				mm_node.call("load_save_data", save_data["merchant_data"])

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
				task["completed"] = bool(task_data.get("completed", false))
				tasks.append(task)
		JournalManager.daily_tasks = tasks
		JournalManager.tasks_updated.emit()

	print("📂 Đã load game thành công!")
	return true
