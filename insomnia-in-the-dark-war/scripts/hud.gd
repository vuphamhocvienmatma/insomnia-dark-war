extends CanvasLayer

var stats_visible: bool = false
var hud_panel: Node2D
var icon_scrap: Texture2D
var icon_seeds: Texture2D
var icon_water: Texture2D
var _scrap: int = 0
var _seeds: int = 0
var _water: int = 0

@onready var tired_label: Label = $TiredLabel
@onready var task1_label: Label = $Task1Label
@onready var task2_label: Label = $Task2Label
@onready var task3_label: Label = $Task3Label


func _ready() -> void:
	hud_panel = Node2D.new()
	hud_panel.set_script(preload("res://scripts/art_hud_panel.gd"))
	hud_panel.position = Vector2(100.0, 120.0)
	hud_panel.z_index = -1
	add_child(hud_panel)
	hud_panel.visible = false
	icon_scrap = load("res://assets/icons/scrap.png") as Texture2D
	icon_seeds = load("res://assets/icons/seeds.png") as Texture2D
	icon_water = load("res://assets/icons/water.png") as Texture2D
	_scrap = GameState.scrap_count
	_seeds = GameState.seeds_count
	_water = GameState.water_count
	GameState.scrap_changed.connect(_on_scrap_changed)
	GameState.seeds_changed.connect(_on_seeds_changed)
	GameState.water_changed.connect(_on_water_changed)
	GameState.tired_changed.connect(_on_tired_changed)
	JournalManager.tasks_updated.connect(_on_tasks_updated)
	var rl := get_node_or_null("Label")
	if rl != null:
		rl.visible = false
	var sl := get_node_or_null("SeedsLabel")
	if sl != null:
		sl.visible = false
	var wl := get_node_or_null("WaterLabel")
	if wl != null:
		wl.visible = false
	tired_label.visible = GameState.is_tired
	_update_tasks()
	queue_redraw()


func _draw() -> void:
	if not stats_visible:
		return
	_draw_icon(icon_scrap, Color(0.6, 0.6, 0.6, 1.0), Vector2(30.0, 80.0))
	_draw_icon(icon_seeds, Color(0.3, 0.7, 0.3, 1.0), Vector2(30.0, 120.0))
	_draw_icon(icon_water, Color(0.3, 0.5, 0.9, 1.0), Vector2(30.0, 160.0))
	var font := ThemeDB.get_default_font()
	draw_string(font, Vector2(62.0, 98.0), ": " + str(_scrap), HORIZONTAL_ALIGNMENT_LEFT, 200, Color.WHITE)
	draw_string(font, Vector2(62.0, 138.0), ": " + str(_seeds), HORIZONTAL_ALIGNMENT_LEFT, 200, Color.WHITE)
	draw_string(font, Vector2(62.0, 178.0), ": " + str(_water), HORIZONTAL_ALIGNMENT_LEFT, 200, Color.WHITE)


func _draw_icon(icon: Texture2D, fallback_col: Color, pos: Vector2) -> void:
	if icon != null:
		draw_texture_rect(icon, Rect2(pos.x, pos.y, 24.0, 24.0), false)
	else:
		draw_circle(pos + Vector2(12.0, 12.0), 12.0, fallback_col)


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_stats"):
		stats_visible = !stats_visible
		hud_panel.visible = stats_visible
		queue_redraw()


func _on_scrap_changed(new_amount: int) -> void:
	_scrap = new_amount
	queue_redraw()


func _on_seeds_changed(new_amount: int) -> void:
	_seeds = new_amount
	queue_redraw()


func _on_water_changed(new_amount: int) -> void:
	_water = new_amount
	queue_redraw()


func _on_tired_changed(is_tired: bool) -> void:
	tired_label.visible = is_tired


func _on_tasks_updated() -> void:
	_update_tasks()


func _update_tasks() -> void:
	var tasks := JournalManager.daily_tasks
	var labels := [task1_label, task2_label, task3_label]
	for i in labels.size():
		if i < tasks.size():
			var task: Dictionary = tasks[i]
			var mark := "x" if task["progress"] >= task["target"] else " "
			labels[i].text = "[" + mark + "] " + str(task["desc"]) + " (" + str(int(task["progress"])) + "/" + str(int(task["target"])) + ")"
		else:
			labels[i].text = ""
