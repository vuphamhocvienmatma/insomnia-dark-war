extends Node

var daily_tasks: Array[Dictionary] = []

signal tasks_updated
signal task_completed(task_desc: String)

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
		{"desc": "Nhặt 5 Hạt giống", "type": "seed", "target": 5, "progress": 0, "completed": false},
		{"desc": "Xây 3 Vách rào", "type": "wall", "target": 3, "progress": 0, "completed": false},
		{"desc": "Bắn hạ 3 Zombie", "type": "zombie_kill", "target": 3, "progress": 0, "completed": false}
	]
	task_pool.shuffle()
	daily_tasks.assign(task_pool.slice(0, 3))
	tasks_updated.emit()

func track_progress(task_type: String) -> void:
	for task in daily_tasks:
		if str(task.get("type", "")) != task_type:
			continue

		var progress: int = int(task.get("progress", 0))
		var target: int = int(task.get("target", 0))
		var completed: bool = bool(task.get("completed", false))

		if progress >= target:
			break

		progress += 1
		task["progress"] = progress

		if progress >= target and not completed:
			task["completed"] = true
			task_completed.emit(str(task.get("desc", "")))
			GameState.add_scrap(5)
			GameState.add_seeds(2)
			print("🎉 Hoàn thành nhiệm vụ: ", str(task.get("desc", "")), "! Thưởng 5 phế liệu + 2 hạt giống.")
		break
	tasks_updated.emit()
