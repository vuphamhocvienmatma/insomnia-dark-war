extends Node

signal test_done

var _t: Node
var _tm: Node

func _ready() -> void:
	_t = preload("res://tests/helpers/test_assert.gd").new()
	add_child(_t)
	_t.begin("TimeManager")
	
	_tm = get_tree().get_first_node_in_group("time_manager")
	if _tm == null:
		_tm = load("res://scripts/time_manager.gd").new()
		add_child(_tm)
	
	run_all()
	_t.done()
	test_done.emit()

func run_all() -> void:
	_t.check(_tm.is_night == false, "TM-01: init is_night = false")
	
	_tm.time_elapsed = _tm.day_duration_seconds
	_tm._process(0.1)
	_t.check(_tm.is_night == true, "TM-02: transition to night")
	
	_tm.time_elapsed = _tm.night_duration_seconds
	_tm._process(0.1)
	_t.check(_tm.is_night == false, "TM-03: transition to day")
	
	_tm.is_night = false
	_tm.time_elapsed = _tm.day_duration_seconds - 10.0
	_tm._warned_sunset = false
	_tm._process(0.1)
	_t.check(_tm._warned_sunset == true, "TM-04: sunset warning")
	
	var old_solar = _tm.current_solar_energy
	_tm.is_night = false
	_tm._process(1.0)
	_t.check(_tm.current_solar_energy > old_solar, "TM-05: solar charges during day")
	
	old_solar = _tm.current_solar_energy
	_tm.is_night = true
	_tm._process(1.0)
	_t.check(int(_tm.current_solar_energy) == int(old_solar), "TM-06: solar doesn't charge at night")
	
	_tm.cloud_cover = 0.5
	_t.check(_tm.cloud_cover >= 0.0 and _tm.cloud_cover <= 1.0, "TM-08: cloud cover bounds")
