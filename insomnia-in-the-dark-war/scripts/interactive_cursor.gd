extends CanvasLayer

var current_action_type: String = ""
var current_action_title: String = ""
var current_hover_target: Node2D = null
var _pulse_time: float = 0.0

const CURSOR_COL: Color = Color(0.96, 0.85, 0.55, 1.0)
const GLOW_COL: Color = Color(1.0, 0.72, 0.28, 0.45)
const OUTLINE: Color = Color(0.18, 0.12, 0.08, 1.0)

var cursor_drawer: Node2D
var _player: Node2D = null
var _cat: Node2D = null
var _cabin: Node2D = null
var _hud: Node = null
var _bm: Node = null


func _ready() -> void:
	layer = 125
	process_mode = Node.PROCESS_MODE_ALWAYS
	cursor_drawer = Node2D.new()
	cursor_drawer.set_script(preload("res://scripts/art_cursor_drawer.gd"))
	add_child(cursor_drawer)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_cache_nodes()


func _cache_nodes() -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if _cat == null or not is_instance_valid(_cat):
		_cat = get_tree().get_first_node_in_group("companion_cat") as Node2D
	if _cabin == null or not is_instance_valid(_cabin):
		_cabin = get_tree().get_first_node_in_group("cabin_structure") as Node2D
	if _hud == null or not is_instance_valid(_hud):
		_hud = get_tree().get_first_node_in_group("hud")
	if _bm == null or not is_instance_valid(_bm):
		_bm = get_tree().root.find_child("BuildingManager", true, false)


func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(delta: float) -> void:
	_pulse_time += delta * 4.0
	_detect_hover_action()


func _detect_hover_action() -> void:
	var cam: Camera2D = get_tree().root.get_camera_2d()
	var w_pos: Vector2 = cam.get_global_mouse_position() if cam != null else Vector2.ZERO

	current_action_type = ""
	current_action_title = ""
	current_hover_target = null

	if _player == null or not is_instance_valid(_player):
		return

	# 1. Check Build Sockets (via BuildingManager - only when close to socket!)
	if _bm != null and is_instance_valid(_bm):
		var sock = _bm.get("active_socket")
		if sock != null and is_instance_valid(sock):
			var sock_node: Node2D = sock as Node2D
			if _player.global_position.distance_to(sock_node.global_position) < 180.0:
				current_action_type = "build"
				current_action_title = "🔨 [Click] Xây Tường Rào (-1 Phế liệu)"
				current_hover_target = sock_node
				return

	# 2. Check Companion Cat (checked before door to prevent door overlap)
	if _cat != null and is_instance_valid(_cat):
		if _player.global_position.distance_to(_cat.global_position) < 120.0:
			if _cat.global_position.distance_to(w_pos) < 26.0:
				current_action_type = "cat"
				current_action_title = "🐱 [Click] Vuốt ve mèo cưng"
				current_hover_target = _cat
				return

	# 3. Check Cabin Door at x = -195 (only inside door frame bounds)
	for door in get_tree().get_nodes_in_group("cabin_door"):
		if is_instance_valid(door) and door is Node2D:
			var d_node: Node2D = door as Node2D
			if absf(_player.global_position.x - (-195.0)) < 130.0:
				if absf(w_pos.x - (-195.0)) <= 15.0 and w_pos.y >= -52.0 and w_pos.y <= 2.0:
					current_action_type = "door"
					var is_open: bool = bool(d_node.get("is_open"))
					current_action_title = "🚪 [Click] " + ("Đóng cửa" if is_open else "Mở cửa") + " | [Chuột Phải] Gia cố"
					current_hover_target = d_node
					return

	# 4. Check Ladder at x = 150
	if absf(_player.global_position.x - 150.0) < 80.0:
		if absf(w_pos.x - 150.0) < 16.0 and w_pos.y >= -155.0 and w_pos.y <= 8.0:
			current_action_type = "ladder"
			var to_floor: String = "Lên gác lửng" if (_cabin != null and _cabin.get("current_floor") == "ground") else "Xuống tầng 1"
			current_action_title = "🪜 [Click] " + to_floor
			return

	# 5. Check Mailbox at x = -225
	for mb in get_tree().get_nodes_in_group("mailbox"):
		if is_instance_valid(mb) and mb is Node2D:
			var m_node: Node2D = mb as Node2D
			if _player.global_position.distance_to(m_node.global_position) < 120.0:
				if m_node.global_position.distance_to(w_pos) < 28.0:
					current_action_type = "mailbox"
					current_action_title = "✉️ [Click] Mở Hòm Thư"
					current_hover_target = m_node
					return

	# 6. Check Merchant Dog at x = -265
	for dog in get_tree().get_nodes_in_group("merchant_dog"):
		if is_instance_valid(dog) and dog is Node2D:
			var dog_node: Node2D = dog as Node2D
			if _player.global_position.distance_to(dog_node.global_position) < 120.0:
				if dog_node.global_position.distance_to(w_pos) < 28.0:
					current_action_type = "merchant"
					current_action_title = "🐶 [Click] Xem Hàng Buôn Lậu Của Chó Robot"
					current_hover_target = dog_node
					return

	# 7. Check Plant Pots
	for pot in get_tree().get_nodes_in_group("plant_pot"):
		if is_instance_valid(pot) and pot is Node2D:
			var p_node: Node2D = pot as Node2D
			if _player.global_position.distance_to(p_node.global_position) < 110.0:
				if p_node.global_position.distance_to(w_pos) < 24.0:
					current_action_type = "plant"
					current_action_title = "🌱 [Click] Chăm sóc / Thu hoạch cây"
					current_hover_target = p_node
					return

	# 8. Check Stove at x = 60
	for stove in get_tree().get_nodes_in_group("stove"):
		if is_instance_valid(stove) and stove is Node2D:
			var s_node: Node2D = stove as Node2D
			if _player.global_position.distance_to(s_node.global_position) < 100.0:
				if s_node.global_position.distance_to(w_pos) < 28.0:
					current_action_type = "stove"
					current_action_title = "🍳 [Click] Nấu Ăn Ấm Cúng"
					current_hover_target = s_node
					return


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if current_action_type == "door" and is_instance_valid(current_hover_target):
				if current_hover_target.has_method("toggle_door"):
					current_hover_target.call("toggle_door")
					get_viewport().set_input_as_handled()
			elif current_action_type == "ladder":
				if _cabin != null:
					if _cabin.get("current_floor") == "ground":
						_cabin.call("climb_up")
					else:
						_cabin.call("climb_down")
					get_viewport().set_input_as_handled()
			elif current_action_type == "mailbox":
				if _hud != null and _hud.has_method("open_mailbox_ui"):
					_hud.call("open_mailbox_ui")
					get_viewport().set_input_as_handled()
			elif current_action_type == "merchant":
				if _hud != null and _hud.has_method("open_merchant_modal"):
					_hud.call("open_merchant_modal")
					get_viewport().set_input_as_handled()
			elif current_action_type == "stove" and is_instance_valid(current_hover_target):
				if current_hover_target.has_method("interact"):
					current_hover_target.call("interact")
					get_viewport().set_input_as_handled()
			elif current_action_type == "plant" and is_instance_valid(current_hover_target):
				if current_hover_target.has_method("interact"):
					current_hover_target.call("interact")
					get_viewport().set_input_as_handled()
			elif current_action_type == "cat" and is_instance_valid(current_hover_target):
				if current_hover_target.has_method("interact"):
					current_hover_target.call("interact")
					get_viewport().set_input_as_handled()

		elif mb.button_index == MOUSE_BUTTON_RIGHT:
			if current_action_type == "door" and is_instance_valid(current_hover_target):
				if current_hover_target.has_method("reinforce_door"):
					current_hover_target.call("reinforce_door")
					get_viewport().set_input_as_handled()
