extends Node

signal scrap_changed(new_amount: int)
signal seeds_changed(new_amount: int)
signal water_changed(new_amount: int)
signal tired_changed(is_tired: bool)
signal relic_collected(type: String)

var scrap_count: int = 0
var seeds_count: int = 0
var water_count: int = 0
var breach_last_night: bool = false
var is_tired: bool = false
var relics_found: Array[String] = []

var turret_damage_multiplier: float = 1.0
var plant_harvest_bonus: int = 0
var solar_charge_multiplier: float = 1.0
var meal_buff: bool = false
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
