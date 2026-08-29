extends Node

@export var time_manager: Node

@onready var day_lofi_player: AudioStreamPlayer = $DayLofiPlayer
@onready var night_ambient_player: AudioStreamPlayer = $NightAmbientPlayer

func _ready() -> void:
	day_lofi_player.play()
	night_ambient_player.play()
	night_ambient_player.volume_db = -80.0
	day_lofi_player.volume_db = 0.0
	if time_manager != null:
		time_manager.phase_changed.connect(_on_phase_changed)

func _on_phase_changed(is_night: bool) -> void:
	if is_night:
		fade_to_night()
	else:
		fade_to_day()

func fade_to_night() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(day_lofi_player, "volume_db", -15.0, 4.0)
	tween.tween_property(night_ambient_player, "volume_db", 0.0, 4.0)

func fade_to_day() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(day_lofi_player, "volume_db", 0.0, 4.0)
	tween.tween_property(night_ambient_player, "volume_db", -80.0, 4.0)
