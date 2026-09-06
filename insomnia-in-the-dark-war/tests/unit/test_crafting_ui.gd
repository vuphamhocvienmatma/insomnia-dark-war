extends Node

signal test_done

var _t: Node
var _ui: Node

func _ready() -> void:
	_t = preload("res://tests/helpers/test_assert.gd").new()
	add_child(_t)
	_t.begin("CraftingUI")
	
	_ui = preload("res://scenes/crafting_ui.tscn").instantiate()
	add_child(_ui)
	
	run_all()
	_t.done()
	test_done.emit()

func run_all() -> void:
	GameState.seeds_count = 2
	GameState.water_count = 1
	var meal_recipe = _ui.RECIPES[0]
	_t.check(_ui.can_afford(meal_recipe), "CR-01: can_afford meal")
	
	GameState.seeds_count = 1
	GameState.water_count = 1
	_t.check(not _ui.can_afford(meal_recipe), "CR-02: cannot afford meal")
	
	GameState.scrap_count = 3
	var battery_recipe = _ui.RECIPES[1]
	_t.check(_ui.can_afford(battery_recipe), "CR-03: can_afford battery")
	
	GameState.seeds_count = 2
	GameState.water_count = 1
	_ui.spend(meal_recipe)
	_t.check(GameState.seeds_count == 0 and GameState.water_count == 0, "CR-04: spend resources")
	
	GameState.seeds_count = 2
	GameState.water_count = 1
	_ui._craft_i(0)
	_t.check(GameState.meal_buff == true, "CR-05: craft meal applies buff")
	
	var old_solar = GameState.solar_charge_multiplier
	GameState.scrap_count = 3
	var tm = load("res://scripts/time_manager.gd").new()
	tm.add_to_group("time_manager")
	_ui.add_child(tm)
	var old_max = tm.max_solar_storage
	_ui._craft_i(1)
	_t.check(tm.max_solar_storage > old_max, "CR-06: craft battery increases max_solar_storage")
	
	GameState.scrap_count = 2
	GameState.seeds_count = 1
	var cat = Node.new()
	cat.add_to_group("companion_cat")
	_ui.add_child(cat)
	_ui._craft_i(2)
	_t.check(_ui.cat_toy_done == true, "CR-07: craft cat_toy")
	
	_t.check(_ui.panel.visible == false, "CR-08: panel hidden by default")
	
	var ev = InputEventAction.new()
	ev.action = "toggle_crafting"
	ev.pressed = true
	_ui._unhandled_input(ev)
	_t.check(_ui.panel.visible == true, "CR-09: toggle_crafting shows panel")
	
	_t.check(_ui.RECIPES[0].id == "meal" and _ui.RECIPES[1].id == "battery" and _ui.RECIPES[2].id == "cat_toy", "CR-10: 3 recipes")
