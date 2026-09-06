extends Node

signal test_done

var _t: Node

func _ready() -> void:
	_t = preload("res://tests/helpers/test_assert.gd").new()
	add_child(_t)
	_t.begin("SaveManager")
	run_all()
	_t.done()
	test_done.emit()

func run_all() -> void:
	GameState.scrap_count = 7
	GameState.seeds_count = 3
	GameState.water_count = 5
	GameState.relics_found = ["buff_turret"]
	GameState.eco_mode = true
	SaveManager.unlock("item_a")
	SaveManager.unlock("bp_radio")
	
	SaveManager.save_game()
	_t.check(FileAccess.file_exists(SaveManager.SAVE_PATH), "SM-01: save_game creates file")
	
	var file := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	_t.check(json.parse(content) == OK, "SM-02: valid JSON")
	
	GameState.scrap_count = 0
	GameState.seeds_count = 0
	GameState.water_count = 0
	GameState.relics_found.clear()
	GameState.eco_mode = false
	SaveManager._unlocked_ids.clear()
	
	var ok = SaveManager.load_game()
	_t.check(GameState.scrap_count == 7, "SM-03: load scrap")
	_t.check(GameState.seeds_count == 3, "SM-04: load seeds")
	_t.check(GameState.water_count == 5, "SM-05: load water")
	_t.check(GameState.relics_found.has("buff_turret"), "SM-06: load relics")
	_t.check(GameState.eco_mode == true, "SM-07: load eco_mode")
	_t.check(SaveManager.has_unlocked("item_a"), "SM-09: has_unlocked true")
	_t.check(not SaveManager.has_unlocked("item_b"), "SM-10: has_unlocked false")
	_t.check(SaveManager.has_unlocked("bp_radio"), "SM-11: saved unlocked_ids")
	
	DirAccess.remove_absolute(SaveManager.SAVE_PATH)
	var ok2 = SaveManager.load_game()
	_t.check(not ok2, "SM-08: load_game returns false if no file")
