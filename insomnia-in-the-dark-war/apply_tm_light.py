import os
path = 'scripts/time_manager.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s1 = '''var current_solar_energy: float = 0.0'''
r1 = '''var sun_angle: Vector2 = Vector2.ZERO
var shadow_intensity: float = 1.0
var cloud_cover: float = 0.0
var _cloud_timer: float = 0.0

var current_solar_energy: float = 0.0'''
content = content.replace(s1, r1)

s2 = '''	if environmental_light != null:
		environmental_light.color = target_color'''
r2 = '''	# Cloud events
	if not is_night:
		_cloud_timer -= delta
		if _cloud_timer <= 0.0:
			if cloud_cover > 0.0:
				cloud_cover -= delta * 0.5
				if cloud_cover <= 0.0:
					cloud_cover = 0.0
					_cloud_timer = randf_range(60.0, 120.0)
			else:
				if randf() < 0.3:
					cloud_cover += delta * 0.5
					if cloud_cover >= 0.6:
						cloud_cover = 0.6
						_cloud_timer = randf_range(5.0, 15.0)
				else:
					_cloud_timer = randf_range(10.0, 30.0)
	
	# Compute Sun Angle and Shadow Intensity
	var ls = get_node_or_null("/root/LevelSetup")
	var w = "sunny"
	if ls: w = str(ls.get("current_weather", "sunny"))
	
	if is_night:
		var ratio = time_elapsed / night_duration_seconds
		sun_angle = Vector2(lerp(1.5, -1.5, ratio), 0.5)
		shadow_intensity = 0.6
	else:
		var ratio = time_elapsed / day_duration_seconds
		sun_angle = Vector2(lerp(-2.0, 2.0, ratio), 0.5)
		shadow_intensity = 1.0 - (cloud_cover * 0.8)
	
	if w == "heavy_rain" or w == "thick_fog" or w == "sandstorm":
		shadow_intensity = 0.0
	elif w == "drizzle" or w == "snowstorm":
		shadow_intensity *= 0.3

	if environmental_light != null:
		environmental_light.color = target_color.lerp(Color(0.5, 0.5, 0.5, 1.0), cloud_cover * 0.4)'''
content = content.replace(s2, r2)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated time_manager.gd for sun angle and clouds")
