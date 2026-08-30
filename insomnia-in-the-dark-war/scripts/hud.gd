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

const WOOD := Color(0.76, 0.62, 0.46, 0.96)
const BORDER := Color(0.34, 0.24, 0.16, 1.0)
const TEXT_COLOR := Color(0.20, 0.14, 0.10, 1.0)
const DONE_COLOR := Color(0.55, 0.85, 0.55, 1.0)
const TODO_COLOR := Color(0.95, 0.90, 0.80, 1.0)


func _ready() -> void:
	stats_panel = Panel.new()
	stats_panel.position = Vector2(16, 16)
	stats_panel.size = Vector2(230, 150)
	var sb := StyleBoxFlat.new()
	sb.bg_color = WOOD
	sb.border_color = BORDER
	sb.set_corner_radius_all(18)
	sb.set_content_margin_all(12)
	sb.shadow_color = Color(0, 0, 0, 0.22)
	sb.shadow_size = 8
	sb.shadow_offset = Vector2(0, 4)
	stats_panel.add_theme_stylebox_override("panel", sb)
	add_child(stats_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 6)
	stats_panel.add_child(vbox)

	var title := Label.new()
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

	GameState.scrap_changed.connect(_on_scrap_changed)
	GameState.seeds_changed.connect(_on_seeds_changed)
	GameState.water_changed.connect(_on_water_changed)
	GameState.tired_changed.connect(_on_tired_changed)
	JournalManager.tasks_updated.connect(_on_tasks_updated)

	_refresh_stats()
	_update_tasks()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_stats"):
		_set_stats_visible(not stats_visible)


func _set_stats_visible(v: bool) -> void:
	stats_visible = v
	if stats_visible:
		stats_panel.visible = true
		stats_panel.modulate.a = 0.0
		stats_panel.scale = Vector2(0.96, 0.96)
		var tw := create_tween()
		tw.tween_property(stats_panel, "modulate:a", 1.0, 0.15)
		tw.parallel().tween_property(stats_panel, "scale", Vector2.ONE, 0.15)
	else:
		var tw := create_tween()
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


func _pulse(ln: Label) -> void:
	if not stats_panel.visible:
		return
	ln.scale = Vector2(1.05, 1.05)
	var tw := create_tween()
	tw.tween_property(ln, "scale", Vector2.ONE, 0.12)


func _on_tasks_updated() -> void:
	_update_tasks()


func _update_tasks() -> void:
	var tasks := JournalManager.daily_tasks
	var labels := [task1_label, task2_label, task3_label]
	for i in labels.size():
		var ln: Label = labels[i]
		ln.add_theme_font_size_override("font_size", 14)
		if i < tasks.size():
			var task: Dictionary = tasks[i]
			var done: bool = bool(task.get("completed", false))
			var mark := "✓ " if done else "• "
			ln.text = mark + str(task.get("desc", "")) + " (" + str(int(task.get("progress", 0))) + "/" + str(int(task.get("target", 0))) + ")"
			ln.add_theme_color_override("font_color", DONE_COLOR if done else TODO_COLOR)
		else:
			ln.text = ""
