extends CanvasLayer

var tm: Node = null

# 1. Sound Garden
var sound_garden_active: bool = false
var weather_timer: float = 0.0

# 2. Fireflies
var fireflies_caught: int = 0
var max_fireflies: int = 12
var fireflies_list: Array[Control] = []

# 3. Coffee
var coffee_ui: Panel = null
var coffee_step: int = 0

# 4. Postcards & Polaroids
var postcards_collected: int = 0
var polaroids_taken: Array[String] = []

# 5. Radio
var radio_ui: Label = null
var radio_active: bool = false

# 6. Cat
var tomorrow_weather: String = "sunny"
var cat_forecast_label: Label = null
var yesterday_weather: String = "sunny"

# 7. Stargazing
var stargazing_ui: Panel = null
var stargaze_count: int = 0
var is_stargazing: bool = false
var stargaze_cam: Camera2D = null

# 8. Aquarium
var aquarium_ui: Panel = null
var fish_count: int = 0

# Guitar Minigame
var guitar_area: Area2D = null
var guitar_ui: Panel = null
var guitar_notes: Array[Dictionary] = []
var guitar_active: bool = false
var guitar_timer: float = 0.0

# Wild Animals
var animals_list: Array[Control] = []

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)
	
	_create_coffee_ui()
	_create_stargazing_ui()
	_create_aquarium_ui()
	_create_radio_ui()
	_create_guitar_ui()
	
	await get_tree().create_timer(0.5).timeout
	tm = get_tree().get_first_node_in_group("time_manager")
	if tm:
		if tm.has_signal("phase_changed"):
			tm.phase_changed.connect(_on_phase_changed)
			
	_roll_tomorrow_weather()
	_update_cat_forecast()
	
	# Setup Guitar Interaction Area
	guitar_area = Area2D.new()
	var cs = CollisionShape2D.new()
	var rs = RectangleShape2D.new()
	rs.size = Vector2(40, 40)
	cs.shape = rs
	guitar_area.add_child(cs)
	guitar_area.position = Vector2(-125, -140) # Mezzanine
	var level = get_node_or_null("/root/LevelSetup")
	if level: level.add_child(guitar_area)

func _process(delta: float) -> void:
	if not is_instance_valid(tm): return
	var is_night: bool = false
	if "is_night" in tm: is_night = tm.is_night
	var time_elapsed: float = 0.0
	if "time_elapsed" in tm: time_elapsed = tm.time_elapsed
		
	# 1. Sound Garden
	if GameState.seeds_count > 0:
		weather_timer -= delta
		if weather_timer <= 0:
			weather_timer = randf_range(15.0, 25.0)
			_play_sound_garden()
			
	# 2. Fireflies
	if is_night and randf() < 0.005 and fireflies_list.size() < 5:
		_spawn_firefly()
		
	# Update fireflies
	for i in range(fireflies_list.size() - 1, -1, -1):
		var f = fireflies_list[i]
		if is_instance_valid(f):
			f.position += Vector2(sin(Time.get_ticks_msec() * 0.001 + f.get_instance_id()) * 50 * delta, -20 * delta)
			if f.position.y < -300:
				f.queue_free()
				fireflies_list.remove_at(i)
		else:
			fireflies_list.remove_at(i)
			
	# Radio Schedule Update
	_update_radio_schedule(is_night, time_elapsed)
	
	# Wild Animals Spawn
	_update_wild_animals(is_night, delta)
	
	# Guitar Minigame Input & Logic
	_update_guitar_minigame(delta)
	
	# Check interactions
	_check_guitar_interaction()
	
	# Polaroid Check Continuous
	_check_continuous_polaroids()

func _update_radio_schedule(is_night: bool, time_elapsed: float) -> void:
	if not CabinDecorationManager.has_radio(): return
	var total_dur = tm.get("night_duration_seconds") if is_night else tm.get("day_duration_seconds")
	var ratio = time_elapsed / max(float(total_dur), 1.0)
	# Map ratio to 24h format: Day (6-18) = 12h, Night (18-6) = 12h
	var h = 0.0
	if not is_night: h = 6.0 + ratio * 12.0
	else: h = 18.0 + ratio * 12.0
	if h >= 24.0: h -= 24.0
	
	var r_text = ""
	if h >= 6.0 and h < 8.0: r_text = "📻 6:00 - Chào Bình Minh: Thời tiết hnay..."
	elif h >= 12.0 and h < 14.0: r_text = "📻 12:00 - Giờ Ăn Trưa: *Lofi beats & ads*"
	elif h >= 18.0 and h < 20.0: r_text = "📻 18:00 - Chiều Tà: Nhạc jazz thư giãn..."
	elif h >= 22.0 or h < 0.0: r_text = "📻 22:00 - Đêm Khuya: Truyện ma đêm muộn..."
	elif h >= 2.0 and h < 4.0: r_text = "📻 2:00 - Tần Số Ma: *Tín hiệu méo mó...*"
	
	if r_text != "":
		if not radio_active:
			radio_ui.modulate.a = 0.0
			radio_ui.show()
			radio_active = true
			var tw = create_tween()
			tw.tween_property(radio_ui, "modulate:a", 1.0, 2.0).set_ease(Tween.EASE_OUT)
		radio_ui.text = r_text
	else:
		if radio_active:
			radio_active = false
			var tw = create_tween()
			tw.tween_property(radio_ui, "modulate:a", 0.0, 2.0).set_ease(Tween.EASE_IN)
			tw.tween_callback(radio_ui.hide)

func _check_guitar_interaction() -> void:
	var p = get_tree().get_first_node_in_group("player")
	if not p or not is_instance_valid(guitar_area): return
	
	var dist = p.global_position.distance_to(guitar_area.global_position)
	if dist < 40.0 and Input.is_action_just_pressed("interact") and not guitar_active:
		_start_guitar_minigame()

func _start_guitar_minigame() -> void:
	guitar_active = true
	guitar_ui.modulate.a = 0.0
	guitar_ui.show()
	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(guitar_ui, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_OUT)
	guitar_notes.clear()
	guitar_timer = 0.0
	get_tree().paused = true

func _update_guitar_minigame(delta: float) -> void:
	if not guitar_active: return
	guitar_timer += delta
	
	if randf() < 0.02 and guitar_timer < 18.0:
		guitar_notes.append({"lane": randi() % 4, "y": 0.0})
		
	var to_remove = []
	for i in range(guitar_notes.size()):
		var n = guitar_notes[i]
		n.y += 150.0 * delta
		if n.y > 200.0:
			to_remove.append(i)
			
	for i in range(to_remove.size() -1, -1, -1):
		guitar_notes.remove_at(to_remove[i])
		
	guitar_ui.queue_redraw()
	
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		_catch_note()
		
	if guitar_timer >= 22.0:
		guitar_active = false
		get_tree().paused = false
		var tw = create_tween()
		tw.tween_property(guitar_ui, "modulate:a", 0.0, 1.5).set_ease(Tween.EASE_IN)
		tw.tween_callback(guitar_ui.hide)
		var hud = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_toast"): hud.call("show_toast", "🎵 Đã chơi một bản Acoustic thư giãn. +5% Tốc độ!", 5.0, true)
		var p = get_tree().get_first_node_in_group("player")
		if p: p.set("speed", float(p.get("speed")) * 1.05)

func _catch_note() -> void:
	for i in range(guitar_notes.size()):
		var n = guitar_notes[i]
		if n.y > 140.0 and n.y < 180.0:
			guitar_notes.remove_at(i)
			var hud = get_tree().get_first_node_in_group("hud")
			if hud and hud.has_method("show_toast"): hud.call("show_toast", "🎵 Note Perfect!", 0.5, false)
			return

func _draw_guitar_notes() -> void:
	# Draw strings
	for i in 4:
		var x = 50 + i * 50
		guitar_ui.draw_line(Vector2(x, 0), Vector2(x, 200), Color(1, 1, 1, 0.1), 2.0)
		
	# Draw falling notes
	for n in guitar_notes:
		var x = 50 + n.lane * 50
		guitar_ui.draw_circle(Vector2(x, n.y), 15.0, Color(1.0, 0.8, 0.4, 0.9))
		guitar_ui.draw_arc(Vector2(x, n.y), 15.0, 0, TAU, 16, Color(1, 1, 1, 0.8), 2.0)
		
	# Draw targets
	for i in 4:
		var x = 50 + i * 50
		guitar_ui.draw_arc(Vector2(x, 160.0), 20.0, 0, TAU, 16, Color(1.0, 0.9, 0.6, 0.6), 2.5)

func _create_guitar_ui() -> void:
	guitar_ui = Panel.new()
	guitar_ui.size = Vector2(260, 210)
	guitar_ui.position = Vector2(446, 219)
	guitar_ui.hide()
	guitar_ui.draw.connect(_draw_guitar_notes)
	add_child(guitar_ui)
	
	var lbl = Label.new()
	lbl.text = "🎸 GẢY ĐÀN LOFI (Phím A-S-D-F)\nThư giãn đón hoàng hôn..."
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.position = Vector2(0, -45)
	lbl.size = Vector2(260, 40)
	guitar_ui.add_child(lbl)

# Wild Animals
func _update_wild_animals(is_night: bool, delta: float) -> void:
	var w = "sunny"
	if get_node_or_null("/root/LevelSetup"): w = get_node("/root/LevelSetup").get("current_weather")
	
	if randf() < 0.002 and animals_list.size() < 3:
		var a = Label.new()
		a.add_theme_font_size_override("font_size", 20)
		
		if is_night and randf() < 0.5:
			a.text = "🦉" # Owl
			a.position = Vector2(randf_range(-100, 100), randf_range(-250, -200))
		elif not is_night and randf() < 0.5:
			a.text = "🐰" # Rabbit
			a.position = Vector2(randf_range(-500, 500), 0)
		elif not is_night:
			a.text = "🐦" # Sparrow
			a.position = Vector2(randf_range(-300, 300), -50)
			
		if w == "heavy_rain" or w == "drizzle":
			a.text = "🐢" # Desert Turtle
			a.position = Vector2(randf_range(-500, 500), 0)
			
		if get_node_or_null("/root/LevelSetup"):
			get_node("/root/LevelSetup").add_child(a)
			animals_list.append(a)
			
	# Animate animals (Polish: add hop/float based on animal type)
	var time_sec = Time.get_ticks_msec() * 0.001
	for i in range(animals_list.size() - 1, -1, -1):
		var a = animals_list[i]
		if is_instance_valid(a):
			if a.text == "🐰":
				a.position.x += 15.0 * delta
				a.position.y += sin(time_sec * 12.0) * 1.5 # Hop
			elif a.text == "🐢":
				a.position.x += 2.0 * delta
				a.position.y += sin(time_sec * 2.0) * 0.2  # Slow lumber
			elif a.text == "🦉" or a.text == "🐦":
				a.position.y += sin(time_sec * 3.0 + a.get_instance_id()) * 0.3 # Gentle float
				
			if a.position.x > 1000:
				a.queue_free()
				animals_list.remove_at(i)
		else:
			animals_list.remove_at(i)

# Polaroids
func _take_polaroid(id: String, desc: String) -> void:
	if polaroids_taken.has(id): return
	polaroids_taken.append(id)
	
	var p = ColorRect.new()
	p.name = "Polaroid_Frame"
	p.color = Color(0.96, 0.94, 0.88) # vintage paper
	p.size = Vector2(160, 190)
	p.position = Vector2(100, -220) # slide from top
	p.rotation = randf_range(-0.06, 0.06)
	
	var p_img = ColorRect.new()
	p_img.color = Color(0.22, 0.25, 0.32)
	p_img.size = Vector2(140, 125)
	p_img.position = Vector2(10, 10)
	p.add_child(p_img)

	var p_scene = Label.new()
	p_scene.text = "☀️ 🐱 🌿"
	p_scene.add_theme_font_size_override("font_size", 26)
	p_scene.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p_scene.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	p_scene.size = Vector2(140, 125)
	p_img.add_child(p_scene)
	
	var lbl = Label.new()
	lbl.text = desc
	lbl.add_theme_color_override("font_color", Color(0.15, 0.15, 0.15, 0.9))
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.size = Vector2(140, 42)
	lbl.position = Vector2(10, 140)
	p.add_child(lbl)
	
	add_child(p)
	
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(p, "position:y", 100.0, 1.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(p, "rotation", randf_range(-0.08, 0.08), 1.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.chain().tween_interval(4.5)
	tw.chain().tween_property(p, "position:y", -200.0, 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_callback(p.queue_free)
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_toast"):
		hud.call("show_toast", "📸 Đã chụp: " + desc, 3.0, false)

func _check_continuous_polaroids() -> void:
	var w = "sunny"
	if get_node_or_null("/root/LevelSetup"): w = get_node("/root/LevelSetup").get("current_weather")
	
	if w == "meteor_shower" and tm and tm.get("is_night"):
		_take_polaroid("meteor", "Ngày... Mưa sao băng. Tôi ước gì có ai đó ngắm cùng.")
	if w == "sunny" and tm and not tm.get("is_night"):
		_take_polaroid("cat_sun", "Ngày nắng đẹp. Mèo phơi nắng thật lười nhác.")
		
	if GameState.stats.get("plants_harvested", 0) > 0:
		_take_polaroid("first_flower", "Mầm sống đầu tiên nảy mầm giữa vùng đất chết.")

func _on_phase_changed(is_night: bool) -> void:
	var w = "sunny"
	if get_node_or_null("/root/LevelSetup"): w = get_node("/root/LevelSetup").get("current_weather")
	
	if not is_night:
		# Polaroid Check
		if yesterday_weather == "heavy_rain" and w == "sunny":
			_take_polaroid("after_storm", "Bình minh đầu tiên sau cơn bão rát mặt.")
		if not GameState.breach_last_night:
			_take_polaroid("safe_night", "Một đêm bình yên không bóng dáng quái vật.")
			
		yesterday_weather = w
		_start_coffee_ritual()
		_update_cat_forecast()
		_roll_tomorrow_weather()
	else:
		_update_cat_forecast()
		if is_stargazing: _stop_stargazing()

func _play_sound_garden() -> void:
	var hud: Node = get_tree().get_first_node_in_group("hud")
	var w = "sunny"
	if get_node_or_null("/root/LevelSetup"): w = get_node("/root/LevelSetup").get("current_weather")
	var msg = "🪴 Vườn Âm Thanh: Nhịp điệu Lofi trong trẻo..."
	if w == "heavy_rain": msg = "🪴 Vườn Âm Thanh: Mưa rơi tạo beat trầm buồn..."
	elif w == "snowstorm": msg = "🪴 Vườn Âm Thanh: Nhạc nền pha tiếng chuông lanh canh..."
	elif w == "meteor_shower": msg = "🪴 Vườn Âm Thanh: Arpeggio lấp lánh như sao băng~"
	if hud and hud.has_method("show_toast"): hud.call("show_toast", msg, 4.0, false)

func _spawn_firefly() -> void:
	var btn = Button.new()
	btn.modulate = Color("ffeb99")
	btn.text = "✨"
	btn.flat = true
	btn.position = Vector2(randf_range(200, 1000), randf_range(200, 500))
	btn.pressed.connect(_on_firefly_caught.bind(btn))
	add_child(btn)
	fireflies_list.append(btn)

func _on_firefly_caught(btn: Button) -> void:
	btn.queue_free()
	fireflies_caught += 1

func _roll_tomorrow_weather() -> void:
	tomorrow_weather = ["sunny", "drizzle", "heavy_rain", "thick_fog", "snowstorm", "meteor_shower"][randi()%6]

func _update_cat_forecast() -> void:
	var cat_node = get_tree().get_first_node_in_group("companion_cat")
	if not cat_node: return
	if not is_instance_valid(cat_forecast_label):
		cat_forecast_label = Label.new(); cat_node.add_child(cat_forecast_label); cat_forecast_label.position = Vector2(-40, -50)
	var w = tomorrow_weather
	if get_node_or_null("/root/LevelSetup"): w = get_node("/root/LevelSetup").get("current_weather")
	if w == "sunny": cat_forecast_label.text = "🐱 Phơi nắng, đuôi vẫy chậm"
	elif w == "drizzle": cat_forecast_label.text = "🐱 Nhìn ra ngoài cửa sổ"
	elif w == "heavy_rain": cat_forecast_label.text = "🐱 Trốn dưới gầm bàn!"
	elif w == "thick_fog": cat_forecast_label.text = "🐱 Ngửi ngửi sương mù"
	elif w == "snowstorm": cat_forecast_label.text = "🐱 Rúc vào lò sưởi"
	elif w == "meteor_shower": cat_forecast_label.text = "🐱 Ngồi ngắm sao băng"
	else: cat_forecast_label.text = ""

func _create_coffee_ui() -> void:
	coffee_ui = Panel.new()
	coffee_ui.size = Vector2(380, 160)
	coffee_ui.position = Vector2(386, 244)
	coffee_ui.hide()
	add_child(coffee_ui)
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(20, 20)
	vbox.size = Vector2(340, 120)
	vbox.add_theme_constant_override("separation", 15)
	coffee_ui.add_child(vbox)
	var lbl = Label.new()
	lbl.text = "☕ NGHI THỨC CÀ PHÊ SÁNG ♨️"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 16)
	vbox.add_child(lbl)
	var btn = Button.new()
	btn.text = "Bước 1: Xay hạt cà phê thơm lừng"
	btn.custom_minimum_size = Vector2(300, 42)
	btn.pressed.connect(_on_coffee_btn_pressed.bind(btn))
	vbox.add_child(btn)

func _start_coffee_ritual() -> void:
	coffee_step = 0
	get_tree().paused = true
	coffee_ui.modulate.a = 0.0
	coffee_ui.show()
	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(coffee_ui, "modulate:a", 1.0, 1.5).set_ease(Tween.EASE_OUT)
	
	var btn = coffee_ui.get_child(0).get_child(1)
	btn.disabled = false
	btn.text = "Bước 1: Xay hạt"

func _on_coffee_btn_pressed(btn: Button) -> void:
	coffee_step += 1
	if coffee_step == 1: btn.text = "Bước 2: Đun nước"
	elif coffee_step == 2: btn.text = "Bước 3: Rót tách"
	elif coffee_step == 3:
		btn.text = "Nhâm nhi..."
		btn.disabled = true
		await get_tree().create_timer(2.0).timeout
		var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(coffee_ui, "modulate:a", 0.0, 1.5).set_ease(Tween.EASE_IN)
		tw.tween_callback(func():
			coffee_ui.hide()
			get_tree().paused = false
			GameState.active_cooking_buff = "coffee"
		)

func _create_radio_ui() -> void:
	radio_ui = Label.new()
	radio_ui.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	radio_ui.position = Vector2(800, 50)
	radio_ui.add_theme_color_override("font_color", Color("aaffaa"))
	radio_ui.hide()
	add_child(radio_ui)

func _create_stargazing_ui() -> void:
	stargazing_ui = Panel.new()
	stargazing_ui.size = Vector2(250, 80)
	stargazing_ui.position = Vector2(20, 20)
	var btn = Button.new()
	btn.text = "🪑 Lên Gác Ngắm Sao"
	btn.position = Vector2(10, 10)
	btn.pressed.connect(_on_stargaze)
	stargazing_ui.add_child(btn)
	add_child(stargazing_ui)

func _on_stargaze() -> void:
	if not tm or not tm.get("is_night"): return
	is_stargazing = true
	stargazing_ui.hide()
	
	stargaze_cam = Camera2D.new()
	stargaze_cam.zoom = Vector2(1.0, 1.0)
	add_child(stargaze_cam)
	stargaze_cam.make_current()
	
	var tw = create_tween()
	tw.tween_property(stargaze_cam, "zoom", Vector2(0.5, 0.5), 3.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _stop_stargazing() -> void:
	is_stargazing = false
	if is_instance_valid(stargaze_cam):
		var tw = create_tween()
		tw.tween_property(stargaze_cam, "zoom", Vector2(1.0, 1.0), 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tw.tween_callback(func():
			stargaze_cam.queue_free()
			stargazing_ui.show()
		)
	else:
		stargazing_ui.show()

func _create_aquarium_ui() -> void:
	var btn = Button.new()
	btn.text = "🐠 Câu Cá Cát"
	btn.position = Vector2(20, 120)
	btn.pressed.connect(_on_fish)
	add_child(btn)
	aquarium_ui = Panel.new()
	aquarium_ui.size = Vector2(150, 100)
	aquarium_ui.position = Vector2(20, 160)
	var lbl = Label.new()
	lbl.text = "Bể Cá Sa Mạc: 0"
	lbl.name = "FishLbl"
	aquarium_ui.add_child(lbl)
	add_child(aquarium_ui)

func _on_fish() -> void:
	if GameState.relics_found.has("golden_fishing_rod"):
		fish_count += 1
		aquarium_ui.get_node("FishLbl").text = "Bể Cá Sa Mạc: " + str(fish_count)
