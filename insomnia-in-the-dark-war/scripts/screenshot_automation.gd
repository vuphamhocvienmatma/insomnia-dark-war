extends Node

# Screenshot Automation Script for Insomnia in the Dark War
# Sequentially transitions game states, time of day, weather, and UI, then captures snapshots.

const ARTIFACT_DIR: String = "C:/Users/ezral/.gemini/antigravity/brain/3ba5db99-5b91-49c2-af95-b3b63e398a6c/"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("[SCREENSHOT_AUTOMATION] Initialized. Starting automated showcase capture sequence...")
	if GameState:
		GameState.set_eco_mode(false)
	_suppress_initial_polaroids()
	_run_sequence()

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
			if c.name.begins_with("Polaroid") or (c is ColorRect and (c.size == Vector2(160, 190) or c.size == Vector2(150, 180))):
				c.queue_free()
		if ChillManager.coffee_ui:
			ChillManager.coffee_ui.hide()
		if ChillManager.guitar_ui:
			ChillManager.guitar_ui.hide()
		ChillManager.guitar_active = false
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		for c in hud.get_children():
			if c.name.begins_with("Polaroid"):
				c.queue_free()
	get_tree().paused = false

func _get_ls() -> Node:
	return get_tree().root.find_child("LevelSetup", true, false)

func _get_tm() -> Node:
	return get_tree().get_first_node_in_group("time_manager")

func _get_weather_node() -> Node:
	var ls = _get_ls()
	if ls and ls.get("_weather"):
		return ls.get("_weather")
	return null

func _close_all_ui() -> void:
	_clear_all_overlays()
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		if "mailbox_modal" in hud and hud.mailbox_modal:
			hud.mailbox_modal.visible = false
		if "merchant_modal" in hud and hud.merchant_modal:
			hud.merchant_modal.visible = false
		if "cooking_modal" in hud and hud.cooking_modal:
			hud.cooking_modal.visible = false
		if "toast_panel" in hud and hud.toast_panel:
			hud.toast_panel.visible = false

	var crafting_ui = get_tree().root.find_child("CraftingUI", true, false)
	if crafting_ui:
		var panel = crafting_ui.get_node_or_null("Panel")
		if panel:
			panel.visible = false

	var tut_ui = get_tree().root.find_child("TutorialUI", true, false)
	if tut_ui:
		tut_ui.visible = false

func _save_screenshot(shot_name: String) -> void:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null:
		print("[ERROR] Viewport image is null for ", shot_name)
		return

	# 1. Save to res://
	var res_path = "res://" + shot_name + ".png"
	img.save_png(res_path)

	# 2. Save to globalized project root path
	var global_proj_path = ProjectSettings.globalize_path(res_path)
	img.save_png(global_proj_path)

	# 3. Save copy to artifact directory for markdown embedding
	var artifact_path = ARTIFACT_DIR + shot_name + ".png"
	img.save_png(artifact_path)

	# 4. Save copy to assets/screenshots/
	var shots_dir_path = ProjectSettings.globalize_path("res://assets/screenshots/" + shot_name + ".png")
	img.save_png(shots_dir_path)

	print("[SAVED] Successfully captured: ", shot_name, " -> ", global_proj_path)

func _setup_camera_and_actors() -> void:
	var cam = get_tree().get_first_node_in_group("main_camera")
	if cam:
		cam.global_position = Vector2(0, -115)
		cam.zoom = Vector2(1.05, 1.05)

func _run_sequence() -> void:
	# Initial warm up to let nodes, shaders, and textures mount
	await get_tree().create_timer(1.2).timeout
	_setup_camera_and_actors()

	var hud = get_tree().get_first_node_in_group("hud")
	if hud and "toast_panel" in hud and hud.toast_panel:
		hud.toast_panel.visible = false

	var cat = get_tree().get_first_node_in_group("companion_cat")
	var player = get_tree().get_first_node_in_group("player")
	var tm = _get_tm()
	var ls = _get_ls()

	# ----------------------------------------------------
	# 1. Clear Day (Ngày nắng đẹp bình thường)
	# ----------------------------------------------------
	print("[STEP 1/7] Switching to Clear Day...")
	_close_all_ui()
	if tm:
		tm.set("is_night", false)
		var dur = float(tm.get("day_duration_seconds"))
		tm.set("time_elapsed", dur * 0.25)
		tm.set("current_mood", "golden")
		if tm.environmental_light:
			tm.environmental_light.color = tm.day_color

	if ls:
		ls.set("current_weather", "sunny")
		var w_node = _get_weather_node()
		if w_node and w_node.has_method("set_weather"):
			w_node.call("set_weather", "sunny")
		if ls.get("_night_sky"):
			ls.get("_night_sky").visible = false
		if ls.has_method("_update_ground_state_from_weather"):
			ls.call("_update_ground_state_from_weather")

	if player: player.global_position = Vector2(-30, 0)
	if cat:
		cat.set_physics_process(true)
		cat.global_position = Vector2(35, 0)
		var flbl = cat.get_node_or_null("Label")
		if flbl: flbl.text = "🐱 Phơi nắng, đuôi vẫy chậm"

	for cp in get_tree().get_nodes_in_group("cabin_props"):
		cp.queue_redraw()
	for al in get_tree().get_nodes_in_group("art_lighting"):
		al.queue_redraw()

	await get_tree().create_timer(1.6).timeout
	if hud and "toast_panel" in hud and hud.toast_panel: hud.toast_panel.visible = false
	_save_screenshot("clear_day")

	# ----------------------------------------------------
	# 2. Sunset (Hoàng hôn chiều tà với ánh nắng xiên)
	# ----------------------------------------------------
	print("[STEP 2/7] Switching to Sunset...")
	_close_all_ui()
	if tm:
		tm.set("is_night", false)
		var dur = float(tm.get("day_duration_seconds"))
		tm.set("time_elapsed", dur * 0.85) # deep sunset
		tm.set("current_mood", "dusk")
		if tm.environmental_light:
			tm.environmental_light.color = tm.sunset_color.lerp(Color(0.9, 0.4, 0.2, 1.0), 0.5)

	if ls:
		ls.set("current_weather", "sunny")
		var w_node = _get_weather_node()
		if w_node and w_node.has_method("set_weather"):
			w_node.call("set_weather", "sunny")
		if ls.get("_night_sky"):
			ls.get("_night_sky").visible = false

	if player: player.global_position = Vector2(50, 0)
	if cat:
		cat.set_physics_process(false)
		cat.global_position = Vector2(90, 0)
		var flbl = cat.get_node_or_null("Label")
		if flbl: flbl.text = "🐱 Ngắm hoàng hôn đỏ rực"

	for cp in get_tree().get_nodes_in_group("cabin_props"):
		cp.queue_redraw()
	for al in get_tree().get_nodes_in_group("art_lighting"):
		al.queue_redraw()

	await get_tree().create_timer(1.8).timeout
	if hud and "toast_panel" in hud and hud.toast_panel: hud.toast_panel.visible = false
	_save_screenshot("sunset")

	# ----------------------------------------------------
	# 3. Night Campfire (Đêm tối lúc lửa trại được thắp sáng)
	# ----------------------------------------------------
	print("[STEP 3/7] Switching to Night with Campfire...")
	_close_all_ui()
	if tm:
		tm.set("is_night", true)
		tm.set("time_elapsed", 15.0)
		tm.set("current_mood", "night")
		if tm.environmental_light:
			tm.environmental_light.color = Color(0.12, 0.16, 0.32, 1.0) # Deep dark night

	if ls:
		if ls.has_method("_on_phase_changed"):
			ls.call("_on_phase_changed", true)
		var ns = ls.get("_night_sky")
		if ns:
			ns.visible = true
			ns.queue_redraw()

	# Position player and cat right by the cozy stove/fireplace
	if player: player.global_position = Vector2(-48, 0)
	if cat:
		cat.set_physics_process(false)
		cat.global_position = Vector2(-75, 0)
		var flbl = cat.get_node_or_null("Label")
		if flbl: flbl.text = "🐱 Sưởi ấm bên lửa trại"

	# Glow up the stove light PointLight2D
	var stove_light = get_tree().root.find_child("StoveLight", true, false)
	if stove_light and stove_light is PointLight2D:
		stove_light.energy = 1.3
		stove_light.color = Color(1.0, 0.65, 0.22, 1.0)

	for al in get_tree().get_nodes_in_group("art_lighting"):
		al.queue_redraw()

	await get_tree().create_timer(1.8).timeout
	if hud and "toast_panel" in hud and hud.toast_panel: hud.toast_panel.visible = false
	_save_screenshot("night_campfire")

	# ----------------------------------------------------
	# 4. Rain (Thời tiết trời mưa)
	# ----------------------------------------------------
	print("[STEP 4/7] Switching to Rain...")
	_close_all_ui()
	if tm:
		tm.set("is_night", false)
		var dur = float(tm.get("day_duration_seconds"))
		tm.set("time_elapsed", dur * 0.35)
		if tm.environmental_light:
			tm.environmental_light.color = Color(0.48, 0.55, 0.66, 1.0) # Rainy overcast

	if ls:
		ls.set("current_weather", "heavy_rain")
		var w_node = _get_weather_node()
		if w_node:
			w_node.visible = true
			if w_node.has_method("set_weather"):
				w_node.call("set_weather", "heavy_rain")
		if ls.get("_night_sky"):
			ls.get("_night_sky").visible = false
		if ls.has_method("_update_ground_state_from_weather"):
			ls.call("_update_ground_state_from_weather")

	if player: player.global_position = Vector2(-20, 0)
	if cat:
		cat.set_physics_process(false)
		cat.global_position = Vector2(115, 0)
		var flbl = cat.get_node_or_null("Label")
		if flbl: flbl.text = "🐱 Trốn mưa dưới gầm bàn"

	await get_tree().create_timer(1.8).timeout
	if hud and "toast_panel" in hud and hud.toast_panel: hud.toast_panel.visible = false
	_save_screenshot("rain")

	# ----------------------------------------------------
	# 5. Sandstorm (Thời tiết bão cát)
	# ----------------------------------------------------
	print("[STEP 5/7] Switching to Sandstorm...")
	_close_all_ui()
	if tm:
		tm.set("is_night", false)
		var dur = float(tm.get("day_duration_seconds"))
		tm.set("time_elapsed", dur * 0.5)
		if tm.environmental_light:
			tm.environmental_light.color = Color(0.82, 0.62, 0.40, 1.0) # Dusty golden haze

	if ls:
		ls.set("current_weather", "sandstorm")
		var w_node = _get_weather_node()
		if w_node:
			w_node.visible = true
			if w_node.has_method("set_weather"):
				w_node.call("set_weather", "sandstorm")
		if ls.get("_night_sky"):
			ls.get("_night_sky").visible = false
		if ls.has_method("_update_ground_state_from_weather"):
			ls.call("_update_ground_state_from_weather")

	if player: player.global_position = Vector2(0, 0)
	if cat:
		cat.set_physics_process(false)
		cat.global_position = Vector2(40, 0)
		var flbl = cat.get_node_or_null("Label")
		if flbl: flbl.text = "🐱 Gió cát gầm rú bên ngoài"

	await get_tree().create_timer(1.8).timeout
	if hud and "toast_panel" in hud and hud.toast_panel: hud.toast_panel.visible = false
	_save_screenshot("sandstorm")

	# ----------------------------------------------------
	# 6. UI: Mailbox (Mở bảng Hòm Thư)
	# ----------------------------------------------------
	print("[STEP 6/7] Opening Mailbox UI...")
	# Return weather to peaceful sunny
	if tm:
		tm.set("is_night", false)
		var dur = float(tm.get("day_duration_seconds"))
		tm.set("time_elapsed", dur * 0.28)
		if tm.environmental_light:
			tm.environmental_light.color = tm.day_color

	if ls:
		ls.set("current_weather", "sunny")
		var w_node = _get_weather_node()
		if w_node and w_node.has_method("set_weather"):
			w_node.call("set_weather", "sunny")
		if ls.get("_night_sky"):
			ls.get("_night_sky").visible = false
		if ls.has_method("_update_ground_state_from_weather"):
			ls.call("_update_ground_state_from_weather")

	_close_all_ui()

	if hud and hud.has_method("open_mailbox_ui"):
		hud.call("open_mailbox_ui")

	var mb_modal = null
	if hud and "mailbox_modal" in hud:
		mb_modal = hud.mailbox_modal
	else:
		mb_modal = get_tree().root.find_child("MailboxUI", true, false)

	if mb_modal:
		mb_modal.visible = true
		mb_modal.modulate.a = 1.0
		if "_typewriter_tween" in mb_modal and mb_modal._typewriter_tween != null and mb_modal._typewriter_tween.is_valid():
			mb_modal._typewriter_tween.kill()
		if "content_lbl" in mb_modal and mb_modal.content_lbl != null:
			mb_modal.content_lbl.visible_characters = -1

	await get_tree().create_timer(1.6).timeout
	if hud and "toast_panel" in hud and hud.toast_panel: hud.toast_panel.visible = false
	_save_screenshot("ui_mailbox")
	_save_screenshot("mailbox")

	# ----------------------------------------------------
	# 7. UI: Crafting (Mở bảng Chế Tạo)
	# ----------------------------------------------------
	print("[STEP 7/7] Opening Crafting UI...")
	_close_all_ui()

	if GameState:
		GameState.scrap_count = 15
		GameState.seeds_count = 8
		GameState.water_count = 6
		GameState.scrap_changed.emit(GameState.scrap_count)
		GameState.seeds_changed.emit(GameState.seeds_count)
		GameState.water_changed.emit(GameState.water_count)

	var crafting_ui = get_tree().root.find_child("CraftingUI", true, false)
	if crafting_ui:
		var panel = crafting_ui.get_node_or_null("Panel")
		if panel:
			panel.visible = true
		if crafting_ui.has_method("_refresh"):
			crafting_ui.call("_refresh")

	await get_tree().create_timer(1.6).timeout
	if hud and "toast_panel" in hud and hud.toast_panel: hud.toast_panel.visible = false
	_save_screenshot("ui_crafting")
	_save_screenshot("crafting")

	# ----------------------------------------------------
	# Finish & Quit
	# ----------------------------------------------------
	print("==================================================")
	print("[SCREENSHOT_AUTOMATION] All 7 showcase shots captured successfully!")
	print("==================================================")
	_close_all_ui()
	await get_tree().create_timer(0.4).timeout
	get_tree().quit(0)
