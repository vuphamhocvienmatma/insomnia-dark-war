extends CanvasLayer

@onready var label: Label = $Label
@onready var seeds_label: Label = $SeedsLabel
@onready var water_label: Label = $WaterLabel
@onready var tired_label: Label = $TiredLabel

func _ready() -> void:
	GameState.scrap_changed.connect(_on_scrap_changed)
	GameState.seeds_changed.connect(_on_seeds_changed)
	GameState.water_changed.connect(_on_water_changed)
	GameState.tired_changed.connect(_on_tired_changed)
	label.text = "Phế liệu: " + str(GameState.scrap_count)
	seeds_label.text = "Hạt giống: " + str(GameState.seeds_count)
	water_label.text = "Nước: " + str(GameState.water_count)
	tired_label.visible = GameState.is_tired

func _on_scrap_changed(new_amount: int) -> void:
	label.text = "Phế liệu: " + str(new_amount)

func _on_seeds_changed(new_amount: int) -> void:
	seeds_label.text = "Hạt giống: " + str(new_amount)

func _on_water_changed(new_amount: int) -> void:
	water_label.text = "Nước: " + str(new_amount)

func _on_tired_changed(is_tired: bool) -> void:
	tired_label.visible = is_tired
