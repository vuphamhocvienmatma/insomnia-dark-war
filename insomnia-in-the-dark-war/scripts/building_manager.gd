extends Node2D

var holding_part_type: String = "Wall"
var active_socket: BuildSocket2D = null
var ghost_preview: Node2D = null

func _ready() -> void:
	ghost_preview = Node2D.new()
	ghost_preview.set_script(preload("res://scripts/art_wall.gd"))
	ghost_preview.modulate = Color(1, 1, 1, 0.4)
	ghost_preview.visible = false
	add_child(ghost_preview)

func _process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	var socket: BuildSocket2D = _find_closest_valid_socket(mouse_pos)
	var player := get_tree().get_first_node_in_group("player") as Node2D

	var player_near := false
	if player != null and socket != null:
		player_near = player.global_position.distance_to(socket.global_position) < 180.0

	if socket != null and player_near:
		active_socket = socket
		var pose := active_socket.get_snap_pose()
		ghost_preview.global_position = pose.position
		ghost_preview.global_rotation = pose.rotation
		ghost_preview.modulate = Color(0.35, 1.0, 0.45, 0.65)
		ghost_preview.visible = true
	else:
		active_socket = null
		ghost_preview.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click_build") and active_socket != null and ghost_preview.visible:
		var player := get_tree().get_first_node_in_group("player") as Node2D
		if player and player.global_position.distance_to(active_socket.global_position) < 180.0:
			if GameState and GameState.spend_scrap(1) == true:
				place_build_piece(active_socket)
				if JournalManager:
					JournalManager.track_progress("wall")
			else:
				var hud: Node = get_tree().get_first_node_in_group("hud")
				if hud != null and hud.has_method("show_toast"):
					hud.call("show_toast", "⚠️ Không đủ phế liệu! Cần 1 phế liệu để xây tường.", 2.5, true)
		else:
			print("Quá xa để xây dựng!")

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
