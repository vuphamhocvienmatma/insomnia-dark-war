extends CanvasLayer

@onready var label: Label = $Label
@onready var seeds_label: Label = $SeedsLabel
@onready var water_label: Label = $WaterLabel
@onready var tired_label: Label = $TiredLabel
@onready var task1_label: Label = $Task1Label
@onready var task2_label: Label = $Task2Label
@onready var task3_label: Label = $Task3Label

func _ready() -> void:
	GameState.scrap_changed.connect(_on_scrap_changed)
	GameState.seeds_changed.connect(_on_seeds_changed)
	GameState.water_changed.connect(_on_water_changed)
	GameState.tired_changed.connect(_on_tired_changed)
	JournalManager.tasks_updated.connect(_on_tasks_updated)
	label.text = "Phế liệu: " + str(GameState.scrap_count)
	seeds_label.text = "Hạt giống: " + str(GameState.seeds_count)
	water_label.text = "Nước: " + str(GameState.water_count)
	tired_label.visible = GameState.is_tired
	_update_tasks()

func _on_scrap_changed(new_amount: int) -> void:
	label.text = "Phế liệu: " + str(new_amount)
	_pulse_label(label)

func _on_seeds_changed(new_amount: int) -> void:
	seeds_label.text = "Hạt giống: " + str(new_amount)
	_pulse_label(seeds_label)

func _on_water_changed(new_amount: int) -> void:
	water_label.text = "Nước: " + str(new_amount)
	_pulse_label(water_label)

func _pulse_label(lbl: Label) -> void:
	var tw := create_tween()
	tw.tween_property(lbl, "scale", Vector2(1.2, 1.2), 0.1)
	tw.tween_property(lbl, "scale", Vector2.ONE, 0.1)

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
