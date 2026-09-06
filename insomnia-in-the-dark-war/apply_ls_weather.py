import os

path = 'scripts/level_setup.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s1 = '''var _spawned_zombies: Array[Node2D] = []
var _night_sky: Node2D = null
var _weather: Node2D = null'''
r1 = '''var _spawned_zombies: Array[Node2D] = []
var _night_sky: Node2D = null
var _weather: Node2D = null
var _ground_props: Node2D = null'''
content = content.replace(s1, r1)

s2 = '''func _spawn_ground_details() -> void:
	var ground_props := Node2D.new()
	ground_props.set_script(GROUND_PROPS_SCRIPT)
	add_child(ground_props)'''
r2 = '''func _spawn_ground_details() -> void:
	var ground_props := Node2D.new()
	ground_props.set_script(GROUND_PROPS_SCRIPT)
	add_child(ground_props)
	_ground_props = ground_props'''
content = content.replace(s2, r2)

s3 = '''func _roll_daily_weather() -> void:
	var weathers: Array[String] = ["sunny", "drizzle", "heavy_rain", "thick_fog", "snowstorm", "meteor_shower"]
	current_weather = weathers[randi() % weathers.size()]'''
r3 = '''func _roll_daily_weather() -> void:
	var weathers: Array[String] = ["sunny", "drizzle", "heavy_rain", "thick_fog", "snowstorm", "meteor_shower", "sandstorm"]
	current_weather = weathers[randi() % weathers.size()]
	
	_update_ground_state_from_weather()'''
content = content.replace(s3, r3)

s4 = '''		if _weather.has_method("set_weather"):
			_weather.call("set_weather", current_weather)'''
r4 = '''		if _weather.has_method("set_weather"):
			_weather.call("set_weather", current_weather)
	_update_ground_state_from_weather()'''
content = content.replace(s4, r4)

s5 = '''func _on_phase_changed(is_night: bool) -> void:'''
r5 = '''func _update_ground_state_from_weather() -> void:
	if _ground_props and _ground_props.has_method("set_state"):
		var st = "dry"
		if current_weather == "drizzle" or current_weather == "heavy_rain": st = "wet"
		elif current_weather == "snowstorm": st = "snowy"
		elif current_weather == "sandstorm": st = "sandy"
		if current_night_mutation == "scorched_earth" or current_night_mutation == "solar_eclipse":
			st = "scorched"
		_ground_props.call("set_state", st)

func _on_phase_changed(is_night: bool) -> void:'''
content = content.replace(s5, r5)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated level_setup to sync weather to ground state")
