extends Node

signal scrap_changed(new_amount: int)
signal seeds_changed(new_amount: int)
signal water_changed(new_amount: int)
signal tired_changed(is_tired: bool)

var scrap_count: int = 0
var seeds_count: int = 0
var water_count: int = 0
var breach_last_night: bool = false
var is_tired: bool = false

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
	is_tired = breach_last_night
	breach_last_night = false
	tired_changed.emit(is_tired)
	if is_tired:
		print("Đêm qua mất ngủ... hôm nay đi chậm hơn một chút.")

func rest_well() -> void:
	if is_tired == true:
		is_tired = false
		tired_changed.emit(false)
		print("Hàng rào kín kẽ, tối nay sẽ ngủ ngon!")
