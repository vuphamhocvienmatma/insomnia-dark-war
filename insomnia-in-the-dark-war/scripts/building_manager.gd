extends Node2D

var holding_part_type: String = "Wall"
var active_socket: BuildSocket2D = null
var ghost_preview: Sprite2D = null

func _ready() -> void:
	ghost_preview = Sprite2D.new()
	ghost_preview.texture = load("res://icon.svg")
	ghost_preview.scale = Vector2(0.25, 0.5)
	ghost_preview.modulate = Color(1, 1, 1, 0.4)
	add_child(ghost_preview)

func _process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	active_socket = _find_closest_valid_socket(mouse_pos)

	if active_socket != null:
		var pose := active_socket.get_snap_pose()
		ghost_preview.global_position = pose.position
		ghost_preview.global_rotation = pose.rotation
		ghost_preview.modulate = Color(0, 1, 0, 0.5)
	else:
		ghost_preview.global_position = mouse_pos
		ghost_preview.global_rotation = 0.0
		ghost_preview.modulate = Color(1, 1, 1, 0.4)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click_build") and active_socket != null:
		if GameState.spend_scrap(1) == true:
			place_build_piece(active_socket)
			JournalManager.track_progress("wall")
		else:
			print("Hết phế liệu!")

func place_build_piece(socket: BuildSocket2D) -> void:
	var new_piece: Node2D = load("res://scenes/wall_piece.tscn").instantiate() as Node2D
	get_parent().add_child(new_piece)

	var pose := socket.get_snap_pose()
	new_piece.global_position = pose.position
	new_piece.global_rotation = pose.rotation

	socket.is_occupied = true
	socket.occupant_part = new_piece
	active_socket = null

func _find_closest_valid_socket(pos: Vector2) -> BuildSocket2D:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 2
	query.collide_with_areas = true

	var results := space_state.intersect_point(query)
	for res in results:
		var area := res.collider as BuildSocket2D
		if area and area.can_accept(holding_part_type):
			return area
	return null
