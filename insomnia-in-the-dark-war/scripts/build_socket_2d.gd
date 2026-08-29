class_name BuildSocket2D
extends Area2D

@export_enum("Floor", "Wall", "Door", "SolarGrid") var accept_type: String = "Wall"

var is_occupied: bool = false
var occupant_part: Node2D = null

func _ready() -> void:
	collision_layer = 2
	collision_mask = 0

func get_snap_pose() -> Dictionary:
	return {
		"position": global_position,
		"rotation": global_rotation
	}

func can_accept(part_type: String) -> bool:
	return !is_occupied and part_type == accept_type
