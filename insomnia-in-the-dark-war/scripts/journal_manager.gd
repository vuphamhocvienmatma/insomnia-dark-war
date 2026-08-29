extends Node

var daily_tasks: Array[Dictionary] = []

signal tasks_updated

func _ready() -> void:
	generate_daily_tasks()
	_try_connect_time_manager()

func _try_connect_time_manager() -> void:
	var tm = get_tree().get_first_node_in_group("time_manager")
	if tm != null:
		if not tm.phase_changed.is_connected(_on_phase_changed):
			tm.phase_changed.connect(_on_phase_changed)
	else:
		get_tree().create_timer(0.5).timeout.connect(_try_connect_time_manager)

func _on_phase_changed(is_night: bool) -> void:
	if not is_night:
		generate_daily_tasks()

func generate_daily_tasks() -> void:
	daily_tasks.clear()
	var task_pool := [
		{"desc": "Nhặt 5 Hạt giống", "type": "seed", "target": 5, "progress": 0},
		{"desc": "Xây 3 Vách rào", "type": "wall", "target": 3, "progress": 0},
		{"desc": "Bắn hạ 3 Zombie", "type": "zombie_kill", "target": 3, "progress": 0}
	]
	task_pool.shuffle()
	daily_tasks = task_pool.slice(0, 3)
	tasks_updated.emit()

func track_progress(task_type: String) -> void:
	for task in daily_tasks:
		if task["type"] == task_type and task["progress"] < task["target"]:
			task["progress"] += 1
			if task["progress"] == task["target"]:
				print("Hoàn thành nhiệm vụ: ", task["desc"])
			break
	tasks_updated.emit()
