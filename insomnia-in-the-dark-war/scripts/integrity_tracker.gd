extends Node

signal fort_breached
signal fort_secured

var critical_sockets: Array[BuildSocket2D] = []
var is_breached: bool = false

func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(check_perimeter_integrity)
	add_child(timer)

func check_perimeter_integrity() -> void:
	if critical_sockets.is_empty():
		critical_sockets.assign(get_tree().get_nodes_in_group("critical_socket"))

	var open_blind_spots := 0
	for socket in critical_sockets:
		if is_instance_valid(socket) and not socket.is_occupied:
			open_blind_spots += 1

	if open_blind_spots > 0 and not is_breached:
		is_breached = true
		fort_breached.emit()
		print("CẢNH BÁO: Phát hiện góc chết hàng rào!")
		# Track breach bất kể ngày hay đêm
		GameState.breach_last_night = true
	elif open_blind_spots == 0 and is_breached:
		is_breached = false
		fort_secured.emit()
		print("Pháo đài đã được trám kín. An toàn!")
		# Reset breach flag khi hàng rào kín
		GameState.breach_last_night = false
		var tm = get_tree().get_first_node_in_group("time_manager")
		if tm != null and not tm.is_night:
			GameState.rest_well()
