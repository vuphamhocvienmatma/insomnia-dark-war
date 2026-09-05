extends Node

const PALETTE: Array[Color] = [
	Color("#1D3557"), # 0: Night Blue
	Color("#457B9D"), # 1: Twilight Blue
	Color("#A8DADC"), # 2: Pale Blue
	Color("#F1FAEE"), # 3: White/Mint
	Color("#E63946"), # 4: Neon Red (Zombie eyes)
	Color("#F4A261"), # 5: Pastel Yellow/Orange (Sun)
	Color("#E76F51"), # 6: Crimson (Sunset)
	Color("#264653"), # 7: Deep Green/Teal
	Color("#2A1A1F"), # 8: Dark Wood
	Color("#4A3020"), # 9: Medium Wood
	Color("#7A4F30"), # 10: Light Wood
	Color("#BFA58A"), # 11: Sand/Paper
	Color("#F4D03F"), # 12: Bright Yellow
	Color("#58D68D")  # 13: Green (Plants)
]

signal scrap_changed(new_amount: int)
signal seeds_changed(new_amount: int)
signal water_changed(new_amount: int)
signal tired_changed(is_tired: bool)
signal relic_collected(type: String)
signal eco_mode_changed(enabled: bool)

var scrap_count: int = 0
var seeds_count: int = 0
var water_count: int = 0
var breach_last_night: bool = false
var is_tired: bool = false
var relics_found: Array[String] = []
var eco_mode: bool = false

func _ready() -> void:
	# Default eco_mode to true on Web export for maximum smoothness on low-end browsers
	if OS.has_feature("web"):
		eco_mode = true

func set_eco_mode(enabled: bool) -> void:
	eco_mode = enabled
	eco_mode_changed.emit(eco_mode)

var turret_damage_multiplier: float = 1.0
var plant_harvest_bonus: int = 0
var solar_charge_multiplier: float = 1.0
var meal_buff: bool = false
var active_cooking_buff: String = ""
var stats: Dictionary = {"zombies_killed": 0, "days_survived": 0, "walls_built": 0, "plants_harvested": 0}

func add_scrap(amount: int = 1) -> void:
	scrap_count += amount
	scrap_changed.emit(scrap_count)

func spend_scrap(amount: int) -> bool:
	if scrap_count < amount:
		return false
	scrap_count -= amount
	scrap_changed.emit(scrap_count)
	return true

func add_seeds(amount: int = 1) -> void:
	seeds_count += amount
	seeds_changed.emit(seeds_count)

func spend_seeds(amount: int) -> bool:
	if seeds_count < amount:
		return false
	seeds_count -= amount
	seeds_changed.emit(seeds_count)
	return true

func add_water(amount: int = 1) -> void:
	water_count += amount
	water_changed.emit(water_count)

func spend_water(amount: int) -> bool:
	if water_count < amount:
		return false
	water_count -= amount
	water_changed.emit(water_count)
	return true

func start_new_day() -> void:
	stats["days_survived"] += 1
	var saved_meal: bool = meal_buff
	var saved_breach: bool = breach_last_night
	is_tired = saved_breach and not saved_meal
	breach_last_night = false
	meal_buff = false
	tired_changed.emit(is_tired)
	if is_tired:
		print("Đêm qua mất ngủ... hôm nay đi chậm hơn một chút.")
	elif saved_breach and saved_meal:
		print("Bữa ăn ấm bụng đã giúp bạn ngủ ngon dù hàng rào bị hở!")

	# Permanent Relic: Golden Fishing Rod bonus each morning
	if relics_found.has("golden_fishing_rod"):
		add_scrap(1)
		add_water(1)
		var hud: Node = get_tree().get_first_node_in_group("hud")
		if hud != null and hud.has_method("show_toast"):
			hud.call("show_toast", "🎣 Cần Câu Vàng Bác Sáu vớt được: +1 Phế liệu, +1 Nước!", 4.0, false)

func track_stat(name: String) -> void:
	stats[name] += 1

func rest_well() -> void:
	if is_tired == true:
		is_tired = false
		tired_changed.emit(false)
		print("Hàng rào kín kẽ, tối nay sẽ ngủ ngon!")

func add_relic(type: String) -> void:
	if relics_found.has(type):
		print("Di vật này đã được kích hoạt rồi.")
		return
	relics_found.append(type)
	if type == "buff_turret":
		turret_damage_multiplier = 1.5
	elif type == "buff_plant":
		plant_harvest_bonus = 2
	elif type == "buff_solar":
		solar_charge_multiplier = 1.5
	relic_collected.emit(type)
