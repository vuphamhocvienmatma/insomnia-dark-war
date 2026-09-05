extends Node

var current_step: int = 0
var step_timer: float = 0.0
var _anim_rabbit: Label = null
var _anim_sparrow: Label = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("[SCREENSHOT_AUTOMATOR] Started. Running 7 aesthetic captures...")
	_suppress_initial_polaroids()

func _suppress_initial_polaroids() -> void:
	if ChillManager:
		ChillManager.polaroids_taken.append("cat_sun")
		ChillManager.polaroids_taken.append("meteor")
		ChillManager.polaroids_taken.append("first_flower")
		ChillManager.polaroids_taken.append("after_storm")
		ChillManager.polaroids_taken.append("safe_night")
		_clear_all_overlays()

func _clear_all_overlays() -> void:
	if ChillManager:
		for c in ChillManager.get_children():
			if c is ColorRect and (c.name.begins_with("Polaroid") or c.size == Vector2(160, 190) or c.size == Vector2(150, 180)):
				c.queue_free()
		if ChillManager.coffee_ui:
			ChillManager.coffee_ui.hide()
		if ChillManager.guitar_ui:
			ChillManager.guitar_ui.hide()
		ChillManager.guitar_active = false
	get_tree().paused = false

func _process(delta: float) -> void:
	step_timer += delta
	match current_step:
		0:
			# Wait for initial game scene ready
			if step_timer >= 1.5:
				_clear_all_overlays()
				_setup_shot_1()
				current_step = 1
				step_timer = 0.0
		1:
			# Capture Shot 1: Dynamic Sunlight
			if step_timer >= 1.5:
				_clear_all_overlays()
				_save_screenshot("01_dynamic_sunlight.png")
				_setup_shot_2()
				current_step = 2
				step_timer = 0.0
		2:
			# Capture Shot 2: Heavy Storm & Swaying Lantern
			if step_timer >= 1.4:
				_clear_all_overlays()
				var weather_node = _get_weather_node()
				if weather_node:
					weather_node.set("_lightning_flash", 0.90)
					weather_node.queue_redraw()
			if step_timer >= 1.5:
				_save_screenshot("02_heavy_storm.png")
				_setup_shot_3()
				current_step = 3
				step_timer = 0.0
		3:
			# Capture Shot 3: Polaroid Moment
			if step_timer >= 1.6:
				_save_screenshot("03_polaroid_moment.png")
				_setup_shot_4()
				current_step = 4
				step_timer = 0.0
		4:
			# Capture Shot 4: Lofi Guitar Minigame
			if step_timer >= 1.5:
				_save_screenshot("04_lofi_guitar.png")
				_setup_shot_5()
				current_step = 5
				step_timer = 0.0
		5:
			# Capture Shot 5: Wild Animals
			if step_timer >= 1.5:
				_save_screenshot("05_wild_animals.png")
				_setup_shot_6()
				current_step = 6
				step_timer = 0.0
		6:
			# Capture Shot 6: Stargazing (wait for 3s camera zoom)
			if step_timer >= 3.6:
				_save_screenshot("06_stargazing.png")
				_setup_shot_7()
				current_step = 7
				step_timer = 0.0
		7:
			# Capture Shot 7: Coffee Ritual
			if step_timer >= 1.5:
				_save_screenshot("07_coffee_ritual.png")
				_finish_all_captures()
				current_step = 8

func _get_ls() -> Node:
	return get_tree().root.find_child("LevelSetup", true, false)

func _get_tm() -> Node:
	return get_tree().get_first_node_in_group("time_manager")

func _get_weather_node() -> Node:
	var ls = _get_ls()
	if ls and ls.get("_weather"):
		return ls.get("_weather")
	return null

func _setup_shot_1() -> void:
	print("[SCREENSHOT_AUTOMATOR] Setting up Shot 1: Dynamic Sunlight...")
	_clear_all_overlays()
	var tm = _get_tm()
	if tm:
		tm.set("is_night", false)
		var dur = float(tm.get("day_duration_seconds"))
		tm.set("time_elapsed", dur * 0.28)
	
	var ls = _get_ls()
	if ls:
		ls.set("current_weather", "sunny")
		var w_node = _get_weather_node()
		if w_node and w_node.has_method("set_weather"):
			w_node.call("set_weather", "sunny")
		if ls.get("_night_sky"):
			ls.get("_night_sky").visible = false

	# Position player and cat cozy inside cabin
	var player = get_tree().get_first_node_in_group("player")
	if player: player.global_position = Vector2(-30, 0)
	var cat = get_tree().get_first_node_in_group("companion_cat")
	if cat:
		cat.global_position = Vector2(30, 0)
		var flbl = cat.get_node_or_null("Label")
		if flbl: flbl.text = "🐱 Phơi nắng, đuôi vẫy chậm"
	if ChillManager and is_instance_valid(ChillManager.cat_forecast_label):
		ChillManager.cat_forecast_label.text = "🐱 Phơi nắng, đuôi vẫy chậm"

	# Focus camera on cabin
	var cam = get_tree().get_first_node_in_group("main_camera")
	if cam:
		cam.global_position = Vector2(0, -115)
		cam.zoom = Vector2(1.1, 1.1)

	for cp in get_tree().get_nodes_in_group("cabin_props"):
		cp.queue_redraw()

func _setup_shot_2() -> void:
	print("[SCREENSHOT_AUTOMATOR] Setting up Shot 2: Heavy Storm & Swaying Lantern...")
	_clear_all_overlays()
	var ls = _get_ls()
	if ls:
		ls.set("current_weather", "heavy_rain")
		var w_node = _get_weather_node()
		if w_node:
			w_node.visible = true
			if w_node.has_method("set_weather"):
				w_node.call("set_weather", "heavy_rain")

	# Cat hiding under table (workbench is at x = 115)
	var cat = get_tree().get_first_node_in_group("companion_cat")
	if cat:
		cat.global_position = Vector2(115, 0)
		var flbl = cat.get_node_or_null("Label")
		if flbl:
			flbl.text = "🐱 Trốn dưới gầm bàn!"
	if ChillManager and is_instance_valid(ChillManager.cat_forecast_label):
		ChillManager.cat_forecast_label.text = "🐱 Trốn dưới gầm bàn!"

	# Player standing by window
	var player = get_tree().get_first_node_in_group("player")
	if player: player.global_position = Vector2(-90, 0)

	var cam = get_tree().get_first_node_in_group("main_camera")
	if cam:
		cam.global_position = Vector2(0, -115)
		cam.zoom = Vector2(1.05, 1.05)

func _setup_shot_3() -> void:
	print("[SCREENSHOT_AUTOMATOR] Setting up Shot 3: Polaroid Moment...")
	_clear_all_overlays()
	var ls = _get_ls()
	if ls:
		ls.set("current_weather", "sunny")
		var w_node = _get_weather_node()
		if w_node and w_node.has_method("set_weather"):
			w_node.call("set_weather", "sunny")

	# Reset cat text and position
	var cat = get_tree().get_first_node_in_group("companion_cat")
	if cat:
		cat.global_position = Vector2(30, 0)
		var flbl = cat.get_node_or_null("Label")
		if flbl: flbl.text = "🐱 Phơi nắng, đuôi vẫy chậm"
	if ChillManager and is_instance_valid(ChillManager.cat_forecast_label):
		ChillManager.cat_forecast_label.text = "🐱 Phơi nắng, đuôi vẫy chậm"

	var player = get_tree().get_first_node_in_group("player")
	if player: player.global_position = Vector2(-30, 0)

	var cam = get_tree().get_first_node_in_group("main_camera")
	if cam:
		cam.global_position = Vector2(0, -115)
		cam.zoom = Vector2(1.05, 1.05)

	if ChillManager:
		ChillManager.polaroids_taken.erase("shot3_polaroid")
		ChillManager.call("_take_polaroid", "shot3_polaroid", "Ngày nắng đẹp. Mèo phơi nắng thật lười nhác.")

func _setup_shot_4() -> void:
	print("[SCREENSHOT_AUTOMATOR] Setting up Shot 4: Lofi Guitar Minigame...")
	_clear_all_overlays()
	var tm = _get_tm()
	if tm:
		var dur = float(tm.get("day_duration_seconds"))
		tm.set("time_elapsed", dur * 0.82) # Sunset golden hour

	# Reset cat
	var cat = get_tree().get_first_node_in_group("companion_cat")
	if cat:
		cat.global_position = Vector2(80, 0)
		var flbl = cat.get_node_or_null("Label")
		if flbl: flbl.text = "🐱 Lắng nghe tiếng đàn..."
	if ChillManager and is_instance_valid(ChillManager.cat_forecast_label):
		ChillManager.cat_forecast_label.text = "🐱 Lắng nghe tiếng đàn..."

	var player = get_tree().get_first_node_in_group("player")
	if player: player.global_position = Vector2(-20, 0)

	var cam = get_tree().get_first_node_in_group("main_camera")
	if cam:
		cam.global_position = Vector2(0, -115)
		cam.zoom = Vector2(1.05, 1.05)

	if ChillManager:
		ChillManager.call("_start_guitar_minigame")
		ChillManager.guitar_notes = [
			{"lane": 0, "y": 70.0},
			{"lane": 1, "y": 125.0},
			{"lane": 2, "y": 55.0},
			{"lane": 3, "y": 150.0}
		]
		if ChillManager.guitar_ui:
			ChillManager.guitar_ui.modulate.a = 1.0
			ChillManager.guitar_ui.show()
			ChillManager.guitar_ui.queue_redraw()

func _setup_shot_5() -> void:
	print("[SCREENSHOT_AUTOMATOR] Setting up Shot 5: Wild Animals...")
	_clear_all_overlays()
	var ls = _get_ls()
	if ls:
		ls.set("current_weather", "sunny")
		var w_node = _get_weather_node()
		if w_node and w_node.has_method("set_weather"):
			w_node.call("set_weather", "sunny")

		_anim_rabbit = Label.new()
		_anim_rabbit.add_theme_font_size_override("font_size", 34)
		_anim_rabbit.text = "🐰 Thỏ cát"
		_anim_rabbit.z_index = 10
		_anim_rabbit.position = Vector2(320, -32)
		ls.add_child(_anim_rabbit)

		_anim_sparrow = Label.new()
		_anim_sparrow.add_theme_font_size_override("font_size", 28)
		_anim_sparrow.text = "🐦 Chim sẻ"
		_anim_sparrow.z_index = 10
		_anim_sparrow.position = Vector2(-360, -35)
		ls.add_child(_anim_sparrow)

	var player = get_tree().get_first_node_in_group("player")
	if player: player.global_position = Vector2(180, 0) # porch looking outside
	var cat = get_tree().get_first_node_in_group("companion_cat")
	if cat:
		cat.global_position = Vector2(140, 0)
		var flbl = cat.get_node_or_null("Label")
		if flbl: flbl.text = "🐱 Ngắm thỏ hoang"
	if ChillManager and is_instance_valid(ChillManager.cat_forecast_label):
		ChillManager.cat_forecast_label.text = "🐱 Ngắm thỏ hoang"

	var cam = get_tree().get_first_node_in_group("main_camera")
	if cam:
		cam.global_position = Vector2(0, -110)
		cam.zoom = Vector2(0.95, 0.95)

func _setup_shot_6() -> void:
	print("[SCREENSHOT_AUTOMATOR] Setting up Shot 6: Stargazing...")
	_clear_all_overlays()
	if is_instance_valid(_anim_rabbit): _anim_rabbit.queue_free()
	if is_instance_valid(_anim_sparrow): _anim_sparrow.queue_free()

	var tm = _get_tm()
	if tm:
		tm.set("is_night", true)
		tm.set("time_elapsed", 15.0)

	var ls = _get_ls()
	if ls:
		if ls.has_method("_on_phase_changed"):
			ls.call("_on_phase_changed", true)
		var ns = ls.get("_night_sky")
		if ns:
			ns.visible = true
			ns.set("_shooting_stars", [
				{
					"start": Vector2(-120.0, -280.0),
					"progress": 0.5,
					"length": 160.0,
					"speed": 0.0
				}
			])
			ns.queue_redraw()

		for z in get_tree().get_nodes_in_group("zombie"):
			z.visible = false

	var cat = get_tree().get_first_node_in_group("companion_cat")
	if cat:
		var flbl = cat.get_node_or_null("Label")
		if flbl: flbl.text = "🐱 Ngắm sao băng..."
	if ChillManager and is_instance_valid(ChillManager.cat_forecast_label):
		ChillManager.cat_forecast_label.text = "🐱 Ngắm sao băng..."

	if ChillManager:
		ChillManager.call("_on_stargaze")

func _setup_shot_7() -> void:
	print("[SCREENSHOT_AUTOMATOR] Setting up Shot 7: Coffee Ritual...")
	_clear_all_overlays()
	if ChillManager:
		if is_instance_valid(ChillManager.stargaze_cam):
			ChillManager.stargaze_cam.queue_free()
			ChillManager.stargaze_cam = null
		ChillManager.is_stargazing = false

	var tm = _get_tm()
	if tm:
		tm.set("is_night", false)
		tm.set("time_elapsed", 2.0)

	var ls = _get_ls()
	if ls:
		if ls.has_method("_on_phase_changed"):
			ls.call("_on_phase_changed", false)
		if ls.get("_night_sky"): ls.get("_night_sky").visible = false
		ls.set("current_weather", "sunny")
		var w_node = _get_weather_node()
		if w_node and w_node.has_method("set_weather"):
			w_node.call("set_weather", "sunny")

	var player = get_tree().get_first_node_in_group("player")
	if player: player.global_position = Vector2(-70, 0)

	var cat = get_tree().get_first_node_in_group("companion_cat")
	if cat:
		cat.global_position = Vector2(10, 0)
		var flbl = cat.get_node_or_null("Label")
		if flbl: flbl.text = "🐱 Ngửi mùi cà phê thơm"
	if ChillManager and is_instance_valid(ChillManager.cat_forecast_label):
		ChillManager.cat_forecast_label.text = "🐱 Ngửi mùi cà phê thơm"

	var cam = get_tree().get_first_node_in_group("main_camera")
	if cam:
		cam.make_current()
		cam.global_position = Vector2(0, -115)
		cam.zoom = Vector2(1.05, 1.05)

	if ChillManager:
		ChillManager.call("_start_coffee_ritual")
		if ChillManager.coffee_ui:
			ChillManager.coffee_ui.modulate.a = 1.0
			ChillManager.coffee_ui.show()

func _save_screenshot(filename: String) -> void:
	var img = get_viewport().get_texture().get_image()
	if img == null:
		print("[ERROR] Failed to get viewport image for: ", filename)
		return

	var path1 = "res://assets/screenshots/" + filename
	var abs_path1 = ProjectSettings.globalize_path(path1)
	img.save_png(abs_path1)

	var abs_path2 = ProjectSettings.globalize_path("res://../assets/screenshots/" + filename)
	img.save_png(abs_path2)

	print("[SAVED] Screenshot: ", filename, " (Size: ", img.get_width(), "x", img.get_height(), ")")

func _finish_all_captures() -> void:
	print("==================================================")
	print("[SCREENSHOT_AUTOMATOR] All 7 aesthetic screenshots captured!")
	print("==================================================")
	_clear_all_overlays()
	get_tree().quit(0)
