extends Node2D

const GROUND_Y: float = 0.0
const MEZZANINE_Y: float = -140.0
const LADDER_X_MIN: float = 135.0
const LADDER_X_MAX: float = 165.0

var current_floor: String = "ground"

signal floor_changed(floor_name: String)


func _ready() -> void:
	add_to_group("cabin_structure")


func get_current_floor_y() -> float:
	return MEZZANINE_Y if current_floor == "mezzanine" else GROUND_Y


func can_climb_up(x: float) -> bool:
	return current_floor == "ground" and x >= LADDER_X_MIN and x <= LADDER_X_MAX


func can_climb_down(x: float) -> bool:
	return current_floor == "mezzanine" and x >= LADDER_X_MIN and x <= LADDER_X_MAX


func climb_up() -> void:
	current_floor = "mezzanine"
	floor_changed.emit(current_floor)


func climb_down() -> void:
	current_floor = "ground"
	floor_changed.emit(current_floor)
