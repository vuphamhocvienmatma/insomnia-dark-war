extends Node

@export var time_manager: Node

@onready var day_lofi_player: AudioStreamPlayer = $DayLofiPlayer
@onready var night_ambient_player: AudioStreamPlayer = $NightAmbientPlayer

func play_sfx(sfx_name: String) -> void:
	print("[SFX_PLAYED] ", sfx_name) # Stub for physical sounds like typewriter_tick, build_wall, coffee_boil

func _update_audio_zone(in_cabin: bool) -> void:
	var tw = create_tween().set_parallel(true)
	if in_cabin:
		tw.tween_property(day_lofi_player, "pitch_scale", 0.9, 1.0) # Muffled/Cozy
	else:
		tw.tween_property(day_lofi_player, "pitch_scale", 1.0, 1.0) # Clear

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

func fade_to_sunset() -> void:
	# Dynamic Music System: Sunset brings slight urgency
	var tween := create_tween().set_parallel(true)
	tween.tween_property(day_lofi_player, "pitch_scale", 1.05, 4.0)

func fade_to_night() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(day_lofi_player, "volume_db", -15.0, 4.0)
	tween.tween_property(night_ambient_player, "volume_db", 0.0, 4.0)

func fade_to_day() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(day_lofi_player, "volume_db", 0.0, 4.0)
	tween.tween_property(night_ambient_player, "volume_db", -80.0, 4.0)
