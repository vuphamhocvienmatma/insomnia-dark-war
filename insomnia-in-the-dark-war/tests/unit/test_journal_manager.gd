extends Node

signal test_done

var _t: Node

func _ready() -> void:
	_t = preload("res://tests/helpers/test_assert.gd").new()
	add_child(_t)
	_t.begin("JournalManager")
	run_all()
	_t.done()
	test_done.emit()

func run_all() -> void:
	JournalManager.generate_daily_tasks()
	_t.check(JournalManager.daily_tasks.size() == 3, "JM-01: generate 3 tasks")
	
	var has_keys = true
	for task in JournalManager.daily_tasks:
		if not (task.has("desc") and task.has("type") and task.has("target") and task.has("progress") and task.has("completed")):
			has_keys = false
	_t.check(has_keys, "JM-02: tasks have required keys")
	
	JournalManager.daily_tasks = [
		{"desc": "Test seed", "type": "seed", "target": 5, "progress": 0, "completed": false}
	]
	
	JournalManager.track_progress("seed")
	JournalManager.track_progress("seed")
	JournalManager.track_progress("seed")
	_t.check(JournalManager.daily_tasks[0].progress == 3, "JM-04: track_progress increments")
	
	var old_scrap = GameState.scrap_count
	JournalManager.track_progress("seed")
	JournalManager.track_progress("seed")
	_t.check(JournalManager.daily_tasks[0].completed, "JM-05: task completed when target reached")
	_t.check(GameState.scrap_count == old_scrap + 5, "JM-07: +5 scrap reward")
	
	JournalManager.track_progress("seed")
	_t.check(JournalManager.daily_tasks[0].progress == 5, "JM-09: progress does not exceed target")
	
	JournalManager._on_phase_changed(false)
	_t.check(JournalManager.daily_tasks[0].progress == 0, "JM-10: reset on new day")
