extends CanvasLayer

@onready var label: Label = $Label
@onready var seeds_label: Label = $SeedsLabel
@onready var water_label: Label = $WaterLabel
@onready var tired_label: Label = $TiredLabel
@onready var task1_label: Label = $Task1Label
@onready var task2_label: Label = $Task2Label
@onready var task3_label: Label = $Task3Label

var stats_visible: bool = false
var stats_panel: Panel
var scrap_line: Label
var seeds_line: Label
var water_line: Label
var tired_line: Label

# Dropdown Objectives & Guide System
var journal_btn: Button
var journal_panel: Panel
var journal_open: bool = false
var dropdown_task_labels: Array[Label] = []

# Clock & Solar Widget
var clock_panel: Panel
var time_arc_label: Label
var solar_bar: ProgressBar
var solar_text: Label

# Screen Warning Vignette & Toast System
var vignette_rect: ColorRect
var toast_panel: Panel
var toast_label: Label
var toast_tween: Tween
var zoom_lbl: Label
var mailbox_modal: Panel
var fps_label: Label

const WOOD: Color = Color(0.76, 0.62, 0.46, 0.96)
const BORDER: Color = Color(0.34, 0.24, 0.16, 1.0)
const TEXT_COLOR: Color = Color(0.20, 0.14, 0.10, 1.0)
const DONE_COLOR: Color = Color(0.55, 0.92, 0.62, 1.0)
const TODO_COLOR: Color = Color(0.96, 0.92, 0.85, 1.0)
const HEADER_COLOR: Color = Color(0.96, 0.84, 0.55, 1.0)
const GUIDE_COLOR: Color = Color(0.85, 0.80, 0.74, 1.0)


func _ready() -> void:
	add_to_group("hud")
	fps_label = Label.new()
	fps_label.add_theme_font_size_override("font_size", 11)
	fps_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.5))
	fps_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	fps_label.offset_left = -60.0
	fps_label.offset_top = 10.0
	fps_label.offset_right = -10.0
	fps_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(fps_label)
	stats_panel = Panel.new()
	stats_panel.position = Vector2(16, 16)
	stats_panel.size = Vector2(230, 150)
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = WOOD
	sb.border_color = BORDER
	sb.set_corner_radius_all(18)
	sb.set_content_margin_all(12)
	# Optim: static box, drop expensive dynamic shadow
	# sb.shadow_color = Color(0, 0, 0, 0.22)
	# sb.shadow_size = 8
	stats_panel.add_theme_stylebox_override("panel", sb)
	add_child(stats_panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 6)
	stats_panel.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Túi đồ nhỏ [T]"
	title.add_theme_font_size_override("font_size", 17)
	title.add_theme_color_override("font_color", TEXT_COLOR)
	vbox.add_child(title)

	scrap_line = Label.new()
	seeds_line = Label.new()
	water_line = Label.new()
	tired_line = Label.new()
	for ln in [scrap_line, seeds_line, water_line, tired_line]:
		ln.add_theme_font_size_override("font_size", 17)
		ln.add_theme_color_override("font_color", TEXT_COLOR)
		vbox.add_child(ln)

	stats_panel.visible = false
	label.visible = false
	seeds_label.visible = false
	water_label.visible = false

	# Hide old naked task labels in bottom right corner
	task1_label.visible = false
	task2_label.visible = false
	task3_label.visible = false

	_setup_journal_dropdown()
	_setup_clock_and_solar_widget()
	_setup_vignette_and_toasts()
	_setup_zoom_controls()
	_setup_eco_toggle_button()
	_setup_mailbox_modal()

	_cached_tm = get_tree().get_first_node_in_group("time_manager")
	_cached_cam = get_tree().get_first_node_in_group("main_camera")
	if _cached_tm != null:
		_tm_connected = true
		if _cached_tm.has_signal("sunset_warning"):
			_cached_tm.sunset_warning.connect(_on_sunset_warning)
		if _cached_tm.has_signal("phase_changed"):
			_cached_tm.phase_changed.connect(_on_phase_changed)
		if _cached_tm.has_signal("solar_changed"):
			_cached_tm.solar_changed.connect(_on_solar_changed)

	GameState.scrap_changed.connect(_on_scrap_changed)
	GameState.seeds_changed.connect(_on_seeds_changed)
	GameState.water_changed.connect(_on_water_changed)
	GameState.tired_changed.connect(_on_tired_changed)
	GameState.eco_mode_changed.connect(_on_eco_mode_changed)
	_apply_eco_mode(GameState.eco_mode)
	JournalManager.tasks_updated.connect(_on_tasks_updated)

	if MailboxManager != null:
		MailboxManager.mail_received.connect(func(_l: Dictionary) -> void:
			show_toast("📬 Có thư mới trong hòm thư trước nhà!", 4.0, false)
		)
		MailboxManager.surprise_gift_unlocked.connect(func(sender: String, title: String, _rewards: String) -> void:
			show_toast("🎉 " + sender + " vừa gửi món quà bất ngờ: " + title + "!", 5.0, false)
		)

	# Day 1 Auto Hints (3 gentle toasts on day start)
	get_tree().create_timer(1.5).timeout.connect(func() -> void:
		show_toast("🖐️ Phím [E]: Nhặt phế liệu & thu hoạch hạt giống", 3.8)
	)
	get_tree().create_timer(6.5).timeout.connect(func() -> void:
		show_toast("🎯 Chuột trái: Bắn súng phòng thủ bảo vệ căn cứ", 3.8)
	)
	get_tree().create_timer(11.5).timeout.connect(func() -> void:
		show_toast("🔨 Phím [C]: Chế tạo rào chắn & công sự", 3.8)
	)

	_refresh_stats()
	_update_tasks()


func _setup_journal_dropdown() -> void:
	# 1. Dropdown Toggle Button in bottom-right corner
	journal_btn = Button.new()
	journal_btn.anchor_left = 1.0
	journal_btn.anchor_top = 1.0
	journal_btn.anchor_right = 1.0
	journal_btn.anchor_bottom = 1.0
	journal_btn.offset_left = -320.0
	journal_btn.offset_top = -46.0
	journal_btn.offset_right = -16.0
	journal_btn.offset_bottom = -12.0
	journal_btn.text = "📋 Nhiệm Vụ & Hướng Dẫn  ▲"

	var btn_normal: StyleBoxFlat = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.22, 0.16, 0.12, 0.92)
	btn_normal.border_color = Color(0.55, 0.42, 0.30, 1.0)
	btn_normal.set_border_width_all(1)
	btn_normal.set_corner_radius_all(10)
	btn_normal.set_content_margin_all(8)
	btn_normal.shadow_color = Color(0, 0, 0, 0.35)
	btn_normal.shadow_size = 6
	btn_normal.shadow_offset = Vector2(0, 2)

	var btn_hover: StyleBoxFlat = StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.32, 0.23, 0.16, 0.98)
	btn_hover.border_color = Color(0.88, 0.72, 0.45, 1.0)
	btn_hover.set_border_width_all(1)
	btn_hover.set_corner_radius_all(10)
	btn_hover.set_content_margin_all(8)

	journal_btn.add_theme_stylebox_override("normal", btn_normal)
	journal_btn.add_theme_stylebox_override("hover", btn_hover)
	journal_btn.add_theme_stylebox_override("pressed", btn_hover)
	journal_btn.add_theme_color_override("font_color", Color(0.96, 0.92, 0.85, 1.0))
	journal_btn.add_theme_font_size_override("font_size", 13)
	journal_btn.pressed.connect(_toggle_journal_dropdown)
	add_child(journal_btn)

	# 2. Dropdown Panel containing Objectives & Guide
	journal_panel = Panel.new()
	journal_panel.anchor_left = 1.0
	journal_panel.anchor_top = 1.0
	journal_panel.anchor_right = 1.0
	journal_panel.anchor_bottom = 1.0
	journal_panel.offset_left = -370.0
	journal_panel.offset_top = -370.0
	journal_panel.offset_right = -16.0
	journal_panel.offset_bottom = -54.0

	var p_sb: StyleBoxFlat = StyleBoxFlat.new()
	p_sb.bg_color = Color(0.14, 0.10, 0.08, 0.95)
	p_sb.border_color = Color(0.48, 0.36, 0.24, 1.0)
	p_sb.set_border_width_all(2)
	p_sb.set_corner_radius_all(12)
	p_sb.set_content_margin_all(12)
	p_sb.shadow_color = Color(0, 0, 0, 0.45)
	p_sb.shadow_size = 12
	p_sb.shadow_offset = Vector2(0, 4)
	journal_panel.add_theme_stylebox_override("panel", p_sb)
	add_child(journal_panel)

	var p_vbox: VBoxContainer = VBoxContainer.new()
	p_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	p_vbox.offset_left = 12.0
	p_vbox.offset_top = 10.0
	p_vbox.offset_right = -12.0
	p_vbox.offset_bottom = -10.0
	p_vbox.add_theme_constant_override("separation", 5)
	journal_panel.add_child(p_vbox)

	# Header Title
	var p_title: Label = Label.new()
	p_title.text = "📜 NHẬT KÝ & HƯỚNG DẪN SINH TỒN"
	p_title.add_theme_font_size_override("font_size", 14)
	p_title.add_theme_color_override("font_color", HEADER_COLOR)
	p_vbox.add_child(p_title)

	# Divider 1
	var div1: ColorRect = ColorRect.new()
	div1.custom_minimum_size = Vector2(0, 1)
	div1.color = Color(0.42, 0.32, 0.22, 0.7)
	p_vbox.add_child(div1)

	# Section 1: Daily Objectives
	var obj_head: Label = Label.new()
	obj_head.text = "🎯 NHIỆM VỤ HÀNG NGÀY:"
	obj_head.add_theme_font_size_override("font_size", 12)
	obj_head.add_theme_color_override("font_color", HEADER_COLOR)
	p_vbox.add_child(obj_head)

	dropdown_task_labels.clear()
	for idx in 3:
		var t_lbl: Label = Label.new()
		t_lbl.add_theme_font_size_override("font_size", 12)
		t_lbl.add_theme_color_override("font_color", TODO_COLOR)
		p_vbox.add_child(t_lbl)
		dropdown_task_labels.append(t_lbl)

	# Divider 2
	var div2: ColorRect = ColorRect.new()
	div2.custom_minimum_size = Vector2(0, 1)
	div2.color = Color(0.42, 0.32, 0.22, 0.7)
	p_vbox.add_child(div2)

	# Section 2: Controls & Guide
	var guide_head: Label = Label.new()
	guide_head.text = "📖 HƯỚNG DẪN ĐIỀU KHIỂN & MẸO:"
	guide_head.add_theme_font_size_override("font_size", 12)
	guide_head.add_theme_color_override("font_color", HEADER_COLOR)
	p_vbox.add_child(guide_head)

	var guide_lines: Array[String] = [
		"• [A / D] hoặc [← / →] : Di chuyển trái / phải",
		"• [W] hoặc [↑] : Leo thang gác xép & lên mái nhà",
		"• [E] : Tương tác (Hái quả, nhặt phế liệu, vào hầm)",
		"• [Chuột trái] : Bắn súng phòng thủ",
		"• [C] : Mở Menu Chế Tạo công trình",
		"• [T] : Mở Túi Đồ Sinh Tồn",
		"💡 Ban ngày tìm đồ & sửa rào; ban đêm cố thủ trên mái súng AK!"
	]
	for g_text in guide_lines:
		var g_lbl: Label = Label.new()
		g_lbl.text = g_text
		g_lbl.add_theme_font_size_override("font_size", 11)
		g_lbl.add_theme_color_override("font_color", GUIDE_COLOR)
		p_vbox.add_child(g_lbl)

	# Start collapsed by default
	journal_panel.visible = false
	journal_open = false
	_refresh_journal_btn_text()


func _toggle_journal_dropdown() -> void:
	journal_open = not journal_open
	if journal_open:
		journal_panel.visible = true
		journal_panel.modulate.a = 0.0
		journal_panel.scale = Vector2(0.96, 0.96)
		var tw: Tween = create_tween()
		tw.tween_property(journal_panel, "modulate:a", 1.0, 0.15)
		tw.parallel().tween_property(journal_panel, "scale", Vector2.ONE, 0.15)
		journal_btn.text = "📋 Đóng Hướng Dẫn & Nhiệm Vụ  ▼"
	else:
		var tw: Tween = create_tween()
		tw.tween_property(journal_panel, "modulate:a", 0.0, 0.12)
		tw.tween_callback(func() -> void: journal_panel.visible = false)
		_refresh_journal_btn_text()


func _refresh_journal_btn_text() -> void:
	if not journal_open and journal_btn != null:
		var tasks: Array = JournalManager.daily_tasks
		var done_count: int = 0
		for t in tasks:
			if bool(t.get("completed", false)):
				done_count += 1
		journal_btn.text = "📋 Nhiệm Vụ & Hướng Dẫn (" + str(done_count) + "/3)  ▲"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_stats"):
		_set_stats_visible(not stats_visible)
	elif event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_P or event.keycode == KEY_F4:
			GameState.set_eco_mode(not GameState.eco_mode)
			get_viewport().set_input_as_handled()


func _set_stats_visible(v: bool) -> void:
	stats_visible = v
	if stats_visible:
		stats_panel.visible = true
		stats_panel.modulate.a = 0.0
		stats_panel.scale = Vector2(0.96, 0.96)
		var tw: Tween = create_tween()
		tw.tween_property(stats_panel, "modulate:a", 1.0, 0.15)
		tw.parallel().tween_property(stats_panel, "scale", Vector2.ONE, 0.15)
	else:
		var tw: Tween = create_tween()
		tw.tween_property(stats_panel, "modulate:a", 0.0, 0.12)
		tw.tween_callback(func() -> void: stats_panel.visible = false)


func _refresh_stats() -> void:
	scrap_line.text = "🔩  Phế liệu: " + str(GameState.scrap_count)
	seeds_line.text = "🌱  Hạt giống: " + str(GameState.seeds_count)
	water_line.text = "💧  Nước: " + str(GameState.water_count)
	tired_line.visible = GameState.is_tired
	tired_line.text = "😴  Mất ngủ - bước chân nặng"


func _on_scrap_changed(new_amount: int) -> void:
	_refresh_stats()
	_pulse(scrap_line)

func _on_seeds_changed(new_amount: int) -> void:
	_refresh_stats()
	_pulse(seeds_line)

func _on_water_changed(new_amount: int) -> void:
	_refresh_stats()
	_pulse(water_line)

func _on_tired_changed(is_tired: bool) -> void:
	_refresh_stats()
	_pulse(tired_line)

	var root = get_tree().root
	var post_layer = root.find_child("LofiPostProcessLayer", true, false)
	if post_layer and post_layer.get_child_count() > 0:
		var crect = post_layer.get_child(0) as ColorRect
		if crect and crect.material is ShaderMaterial:
			var tw = create_tween()
			tw.tween_method(func(val): crect.material.set_shader_parameter("insomnia_level", val), 0.0 if not is_tired else 0.8, 0.8 if is_tired else 0.0, 3.0)


func _pulse(ln: Label) -> void:
	if not stats_panel.visible:
		return
	ln.scale = Vector2(1.05, 1.05)
	var tw: Tween = create_tween()
	tw.tween_property(ln, "scale", Vector2.ONE, 0.12)


func _on_tasks_updated() -> void:
	_update_tasks()


func _update_tasks() -> void:
	var tasks: Array = JournalManager.daily_tasks
	for i in dropdown_task_labels.size():
		var ln: Label = dropdown_task_labels[i]
		if i < tasks.size():
			var task: Dictionary = tasks[i]
			var task_type: String = str(task.get("type", ""))
			var icon_str: String = "🪵 "
			if task_type == "seed":
				icon_str = "🌱 "
			elif task_type == "zombie_kill":
				icon_str = "🧟 "

			var done: bool = bool(task.get("completed", false))
			if done:
				ln.text = "✓ " + icon_str + str(task.get("desc", "")) + " [HOÀN THÀNH]"
				ln.add_theme_color_override("font_color", DONE_COLOR)
			else:
				var prog: int = int(task.get("progress", 0))
				var tgt: int = int(task.get("target", 0))
				ln.text = "• " + icon_str + str(task.get("desc", "")) + " (" + str(prog) + "/" + str(tgt) + ")"
				ln.add_theme_color_override("font_color", TODO_COLOR)
		else:
			ln.text = ""
	_refresh_journal_btn_text()


var _tm_connected: bool = false
var _cached_tm: Node = null
var _cached_cam: Node = null
var _last_arc_slot: int = -1
var _last_phase_is_n: int = -1
var _last_arc_text: String = ""
var _last_solar_int: int = -999
var _last_solar_text: String = ""
var _last_zoom_str: String = ""
var eco_btn: Button

func _process(_delta: float) -> void:
	if fps_label != null:
		fps_label.text = str(Engine.get_frames_per_second()) + " FPS"
	if _cached_tm != null:
		var time_elapsed: float = float(_cached_tm.get("time_elapsed"))
		var is_n: bool = bool(_cached_tm.get("is_night"))
		var dur: float = float(_cached_tm.get("night_duration_seconds") if is_n else _cached_tm.get("day_duration_seconds"))
		var r: float = clampf(time_elapsed / maxf(dur, 1.0), 0.0, 1.0)
		var current_slot: int = int(r * 7.0)
		var phase_val: int = 1 if is_n else 0
		
		# Update Lofi Sun/Moon Arc Display ONLY when slot or phase changes
		if time_arc_label != null and (current_slot != _last_arc_slot or phase_val != _last_phase_is_n):
			_last_arc_slot = current_slot
			_last_phase_is_n = phase_val
			var phase_icon: String = "🌙 Đêm" if is_n else "☀️ Ngày"
			var arc_bar: String = _make_arc_bar(r)
			var new_arc_text: String = phase_icon + "  " + arc_bar
			if new_arc_text != _last_arc_text:
				_last_arc_text = new_arc_text
				time_arc_label.text = new_arc_text
			
		# Update Solar battery ONLY when integer percentage changes
		var sol: float = float(_cached_tm.get("current_solar_energy"))
		var sol_int: int = int(sol)
		if sol_int != _last_solar_int:
			_last_solar_int = sol_int
			if solar_bar != null:
				solar_bar.value = sol
			var new_solar_text: String = "⚡ Solar: " + str(sol_int) + "%"
			if new_solar_text != _last_solar_text and solar_text != null:
				_last_solar_text = new_solar_text
				solar_text.text = new_solar_text

	# Update Zoom level indicator ONLY when value changes
	if zoom_lbl != null and _cached_cam != null and _cached_cam.has_method("get_zoom_level"):
		var z_val: float = float(_cached_cam.call("get_zoom_level"))
		var z_str: String = str(snappedf(z_val, 0.1)) + "x"
		if z_str != _last_zoom_str:
			_last_zoom_str = z_str
			zoom_lbl.text = z_str


func _setup_eco_toggle_button() -> void:
	eco_btn = Button.new()
	eco_btn.anchor_left = 1.0
	eco_btn.anchor_top = 0.0
	eco_btn.anchor_right = 1.0
	eco_btn.anchor_bottom = 0.0
	eco_btn.offset_left = -140.0
	eco_btn.offset_top = 48.0
	eco_btn.offset_right = -14.0
	eco_btn.offset_bottom = 76.0
	eco_btn.add_theme_font_size_override("font_size", 11)

	var b_sb: StyleBoxFlat = StyleBoxFlat.new()
	b_sb.bg_color = Color(0.16, 0.12, 0.09, 0.90)
	b_sb.border_color = Color(0.48, 0.36, 0.24, 1.0)
	b_sb.set_border_width_all(1)
	b_sb.set_corner_radius_all(8)
	eco_btn.add_theme_stylebox_override("normal", b_sb)

	_update_eco_btn_ui()
	eco_btn.pressed.connect(func() -> void:
		GameState.set_eco_mode(not GameState.eco_mode)
	)
	add_child(eco_btn)


func _update_eco_btn_ui() -> void:
	if eco_btn == null:
		return
	if GameState.eco_mode:
		eco_btn.text = "⚡ Eco: BẬT"
		eco_btn.modulate = Color(0.65, 1.0, 0.65, 1.0)
	else:
		eco_btn.text = "⚡ Eco: TẮT"
		eco_btn.modulate = Color(1.0, 0.92, 0.82, 0.9)


func _on_eco_mode_changed(enabled: bool) -> void:
	_update_eco_btn_ui()
	_apply_eco_mode(enabled)
	if SaveManager != null:
		SaveManager.save_game()
	if enabled:
		show_toast("⚡ Chế độ Tiết kiệm: BẬT (Đã tắt hậu kỳ & tắt bóng đèn PointLight2D)", 3.2, false)
	else:
		show_toast("✨ Chế độ Tiết kiệm: TẮT (Đã bật đầy đủ hiệu ứng)", 3.2, false)


func _apply_eco_mode(enabled: bool) -> void:
	var post_layer: Node = get_tree().root.find_child("LofiPostProcessLayer", true, false)
	if post_layer != null and "visible" in post_layer:
		post_layer.set("visible", not enabled)
	if get_tree().current_scene != null:
		for light in get_tree().current_scene.find_children("", "PointLight2D", true, false):
			if light is PointLight2D:
				light.shadow_enabled = not enabled



func _setup_zoom_controls() -> void:
	var z_panel: Panel = Panel.new()
	z_panel.anchor_left = 1.0
	z_panel.anchor_top = 0.0
	z_panel.anchor_right = 1.0
	z_panel.anchor_bottom = 0.0
	z_panel.offset_left = -140.0
	z_panel.offset_top = 10.0
	z_panel.offset_right = -14.0
	z_panel.offset_bottom = 44.0

	var z_sb: StyleBoxFlat = StyleBoxFlat.new()
	z_sb.bg_color = Color(0.16, 0.12, 0.09, 0.90)
	z_sb.border_color = Color(0.48, 0.36, 0.24, 1.0)
	z_sb.set_border_width_all(1)
	z_sb.set_corner_radius_all(10)
	z_sb.set_content_margin_all(4)
	z_panel.add_theme_stylebox_override("panel", z_sb)
	add_child(z_panel)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 6)
	z_panel.add_child(hbox)

	var btn_out: Button = Button.new()
	btn_out.text = "－"
	btn_out.custom_minimum_size = Vector2(24, 22)
	btn_out.pressed.connect(func() -> void:
		if _cached_cam != null and _cached_cam.has_method("zoom_out"):
			_cached_cam.call("zoom_out")
	)
	hbox.add_child(btn_out)

	zoom_lbl = Label.new()
	zoom_lbl.text = "1.0x"
	zoom_lbl.add_theme_font_size_override("font_size", 11)
	zoom_lbl.add_theme_color_override("font_color", HEADER_COLOR)
	hbox.add_child(zoom_lbl)

	var btn_in: Button = Button.new()
	btn_in.text = "＋"
	btn_in.custom_minimum_size = Vector2(24, 22)
	btn_in.pressed.connect(func() -> void:
		if _cached_cam != null and _cached_cam.has_method("zoom_in"):
			_cached_cam.call("zoom_in")
	)
	hbox.add_child(btn_in)


func _make_arc_bar(r: float) -> String:
	var slots: int = 8
	var pos: int = int(r * float(slots - 1))
	var s: String = "["
	for i in slots:
		if i == pos:
			s += "●"
		else:
			s += "─"
	s += "]"
	return s


func _setup_clock_and_solar_widget() -> void:
	# Diegetic UI requested by user:
	# Hide the CanvasLayer clock and solar bar. They will be rendered directly
	# in the game world in art_cabin_props.gd
	pass


func _setup_vignette_and_toasts() -> void:
	vignette_rect = ColorRect.new()
	vignette_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette_rect.color = Color(0.95, 0.15, 0.10, 1.0)
	vignette_rect.modulate.a = 0.0
	vignette_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette_rect)

	toast_panel = Panel.new()
	toast_panel.anchor_left = 0.5
	toast_panel.anchor_top = 0.0
	toast_panel.anchor_right = 0.5
	toast_panel.anchor_bottom = 0.0
	toast_panel.offset_left = -220.0
	toast_panel.offset_top = 68.0
	toast_panel.offset_right = 220.0
	toast_panel.offset_bottom = 106.0

	var t_sb: StyleBoxFlat = StyleBoxFlat.new()
	t_sb.bg_color = Color(0.12, 0.08, 0.06, 0.96)
	t_sb.border_color = Color(0.72, 0.52, 0.32, 1.0)
	t_sb.set_border_width_all(1)
	t_sb.set_corner_radius_all(10)
	t_sb.set_content_margin_all(8)
	t_sb.shadow_color = Color(0, 0, 0, 0.4)
	t_sb.shadow_size = 8
	t_sb.shadow_offset = Vector2(0, 3)
	toast_panel.add_theme_stylebox_override("panel", t_sb)
	toast_panel.visible = false
	add_child(toast_panel)

	toast_label = Label.new()
	toast_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.add_theme_font_size_override("font_size", 13)
	toast_label.add_theme_color_override("font_color", HEADER_COLOR)
	toast_panel.add_child(toast_label)


func show_toast(msg: String, duration: float = 3.8, is_warning: bool = false) -> void:
	if toast_label == null or toast_panel == null:
		return
	toast_label.text = msg
	toast_panel.visible = true
	toast_panel.modulate.a = 0.0

	if is_warning:
		toast_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35, 1.0))
		if vignette_rect != null:
			vignette_rect.modulate.a = 0.0
			var vtw: Tween = create_tween()
			vtw.tween_property(vignette_rect, "modulate:a", 0.35, 0.3)
			vtw.tween_property(vignette_rect, "modulate:a", 0.0, 1.7)
	else:
		toast_label.add_theme_color_override("font_color", HEADER_COLOR)

	if toast_tween != null and toast_tween.is_valid():
		toast_tween.kill()
	toast_tween = create_tween()
	toast_tween.tween_property(toast_panel, "modulate:a", 1.0, 0.2)
	toast_tween.tween_interval(duration)
	toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.35)
	toast_tween.tween_callback(func() -> void: toast_panel.visible = false)


func _on_sunset_warning() -> void:
	show_toast("🌙 Trời sắp tối! Hãy chuẩn bị phòng thủ căn cứ!", 5.0, true)


func _on_phase_changed(is_night: bool) -> void:
	if is_night:
		show_toast("⚠️ ĐÊM ĐÃ XUỐNG! Zombie đang tiến tới!", 4.0, true)
	else:
		show_toast("☀️ Bình minh đã lên! Căn cứ an toàn.", 3.5, false)


func _on_solar_changed(new_amount: float) -> void:
	if solar_bar != null:
		solar_bar.value = new_amount
	if solar_text != null:
		solar_text.text = "⚡ Solar: " + str(int(new_amount)) + "%"


func _setup_mailbox_modal() -> void:
	var script: GDScript = preload("res://scripts/mailbox_ui.gd")
	mailbox_modal = Panel.new()
	mailbox_modal.set_script(script)
	add_child(mailbox_modal)
	_setup_merchant_modal()


var merchant_modal: Control = null


func _setup_merchant_modal() -> void:
	var scene: PackedScene = preload("res://scenes/merchant_modal.tscn")
	merchant_modal = scene.instantiate() as Control
	add_child(merchant_modal)


func open_mailbox_ui() -> void:
	if mailbox_modal != null and mailbox_modal.has_method("open_mailbox"):
		mailbox_modal.call("open_mailbox")


func open_merchant_modal() -> void:
	if merchant_modal != null and merchant_modal.has_method("open_shop"):
		merchant_modal.call("open_shop")


var cooking_modal: Control = null


func _setup_cooking_modal() -> void:
	var scene: PackedScene = preload("res://scenes/cooking_modal.tscn")
	cooking_modal = scene.instantiate() as Control
	add_child(cooking_modal)


func open_cooking_modal() -> void:
	if cooking_modal == null:
		_setup_cooking_modal()
	if cooking_modal != null and cooking_modal.has_method("open_menu"):
		cooking_modal.call("open_menu")
