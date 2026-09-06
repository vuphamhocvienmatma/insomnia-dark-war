extends Node

signal test_done

var _t: Node

func _ready() -> void:
	_t = preload("res://tests/helpers/test_assert.gd").new()
	add_child(_t)
	_t.begin("GameState")
	run_all()
	_t.done()
	test_done.emit()

func _reset() -> void:
	GameState.scrap_count = 0
	GameState.seeds_count = 0
	GameState.water_count = 0
	GameState.is_tired = false
	GameState.breach_last_night = false
	GameState.meal_buff = false
	GameState.relics_found = []
	GameState.turret_damage_multiplier = 1.0
	GameState.plant_harvest_bonus = 0
	GameState.solar_charge_multiplier = 1.0
	GameState.stats = {"zombies_killed": 0, "days_survived": 0, "walls_built": 0, "plants_harvested": 0}

func run_all() -> void:
	_reset()
	GameState.add_scrap(5)
	_t.check(GameState.scrap_count == 5, "GS-01: add_scrap")
	
	_reset()
	GameState.scrap_count = 10
	var ok = GameState.spend_scrap(4)
	_t.check(ok, "GS-03: spend_scrap success")
	_t.check(GameState.scrap_count == 6, "GS-03: scrap count decreased")
	
	_reset()
	GameState.scrap_count = 2
	ok = GameState.spend_scrap(5)
	_t.check(not ok, "GS-04: spend_scrap fail")
	
	_reset()
	GameState.add_seeds(2)
	_t.check(GameState.seeds_count == 2, "GS-05: add_seeds")
	
	_reset()
	GameState.add_water(3)
	_t.check(GameState.water_count == 3, "GS-06: add_water")
	
	_reset()
	GameState.breach_last_night = false
	GameState.meal_buff = false
	GameState.start_new_day()
	_t.check(not GameState.is_tired, "GS-07: new day not tired")
	
	_reset()
	GameState.breach_last_night = true
	GameState.meal_buff = false
	GameState.start_new_day()
	_t.check(GameState.is_tired, "GS-08: new day tired")
	
	_reset()
	GameState.breach_last_night = true
	GameState.meal_buff = true
	GameState.start_new_day()
	_t.check(not GameState.is_tired, "GS-09: new day meal saves")
	
	_reset()
	GameState.breach_last_night = true
	GameState.meal_buff = true
	GameState.start_new_day()
	_t.check(not GameState.breach_last_night, "GS-10: flags reset")
	_t.check(not GameState.meal_buff, "GS-10: flags reset")
	
	_reset()
	GameState.add_relic("buff_turret")
	_t.check(GameState.turret_damage_multiplier == 1.5, "GS-11: relic buff_turret")
	
	_reset()
	GameState.add_relic("buff_plant")
	_t.check(GameState.plant_harvest_bonus == 2, "GS-12: relic buff_plant")
	
	_reset()
	GameState.add_relic("buff_solar")
	_t.check(GameState.solar_charge_multiplier == 1.5, "GS-13: relic buff_solar")
	
	_reset()
	GameState.add_relic("buff_turret")
	GameState.add_relic("buff_turret")
	_t.check(GameState.relics_found.size() == 1, "GS-14: duplicate relic rejected")
	
	_reset()
	GameState.add_relic("golden_fishing_rod")
	var old_s = GameState.scrap_count
	GameState.start_new_day()
	_t.check(GameState.scrap_count == old_s + 1, "GS-15: golden_fishing_rod bonus")
	
	_reset()
	GameState.set_eco_mode(true)
	_t.check(GameState.eco_mode, "GS-16: eco_mode")
	
	_reset()
	GameState.start_new_day()
	_t.check(GameState.stats["days_survived"] == 1, "GS-17: days_survived")
	
	_reset()
	_t.check(GameState.stats.has("zombies_killed"), "GS-18: stats init")
	
	_reset()
	GameState.is_tired = true
	GameState.rest_well()
	_t.check(not GameState.is_tired, "GS-19: rest_well")
	
	_reset()
	GameState.track_stat("zombies_killed")
	_t.check(GameState.stats["zombies_killed"] == 1, "GS-20: track_stat")
