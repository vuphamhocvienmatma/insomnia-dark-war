import re, os

path = 'scripts/art_weather.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add sandstorm and solar eclipse arrays
content = content.replace('var _window_drops: Array[Dictionary] = []', 'var _window_drops: Array[Dictionary] = []\nvar _sand_particles: Array[Dictionary] = []')
content = content.replace('for i in 15: _window_drops.append({"x": 0.0, "y": 0.0, "speed": 0.0})', 'for i in 15: _window_drops.append({"x": 0.0, "y": 0.0, "speed": 0.0})\n\tfor i in 200: _sand_particles.append({"x": 0.0, "y": 0.0, "speed": 0.0})')

# In _reset_particles
sandstorm_reset = '''	elif weather_type == "sandstorm":
		for i in 200:
			var s = _sand_particles[i]
			s.x = randf_range(-1500, 1500)
			s.y = randf_range(-600, 50)
			s.speed = randf_range(300.0, 500.0)'''
content = content.replace('elif weather_type == "snowstorm":', sandstorm_reset + '\n\telif weather_type == "snowstorm":')

# In _apply_post_process
sandstorm_pp = '''	elif weather_type == "sandstorm":
		t_c = Color(0.9, 0.6, 0.4)
		t_a = 0.4
		v_i = 0.5
		g_a = 0.3
		a_a = 0.5
	elif weather_type == "solar_eclipse":
		t_c = Color(0.2, 0.2, 0.3)
		t_a = 0.6
		v_i = 0.6
		g_a = 0.1
		a_a = 0.5'''
content = content.replace('elif weather_type == "thick_fog":', sandstorm_pp + '\n\telif weather_type == "thick_fog":')

# In _process
sandstorm_process = '''	elif weather_type == "sandstorm":
		for i in 200:
			var s = _sand_particles[i]
			s.x += s.speed * delta
			s.y += (s.speed * 0.1) * delta
			if s.x > 1500.0: s.x = randf_range(-1500, -500); s.y = randf_range(-600, 50)'''
content = content.replace('elif weather_type == "thick_fog":', sandstorm_process + '\n\telif weather_type == "thick_fog":')

# In _draw
sandstorm_draw = '''	elif weather_type == "sandstorm":
		draw_rect(Rect2(-2000, -1000, 4000, 2000), Color(0.8, 0.5, 0.3, 0.35))
		for i in 200:
			var s = _sand_particles[i]
			draw_line(Vector2(s.x, s.y), Vector2(s.x + 20.0, s.y + 2.0), Color(0.9, 0.7, 0.5, 0.6), 2.0)
	elif weather_type == "solar_eclipse":
		draw_circle(Vector2(-750, -320), 22.0, Color(0, 0, 0, 1.0))
		draw_arc(Vector2(-750, -320), 25.0, 0, TAU, 32, Color(1, 1, 1, 0.8), 2.0)
		draw_arc(Vector2(-750, -320), 30.0, 0, TAU, 32, Color(1, 1, 1, 0.4), 4.0)'''
content = content.replace('elif weather_type == "thick_fog":', sandstorm_draw + '\n\telif weather_type == "thick_fog":')

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated art_weather.gd")
