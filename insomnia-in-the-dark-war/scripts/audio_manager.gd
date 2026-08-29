extends Node

var bgm_day: AudioStreamPlayer
var bgm_night: AudioStreamPlayer
var sfx_pool: Dictionary = {}


func _ready() -> void:
	add_to_group("audio_manager")
	bgm_day = AudioStreamPlayer.new()
	bgm_night = AudioStreamPlayer.new()
	add_child(bgm_day)
	add_child(bgm_night)
	bgm_day.stream = load("res://assets/bgm/day_lofi.ogg")
	bgm_night.stream = load("res://assets/bgm/night_ambient.ogg")
	bgm_day.volume_db = -80.0
	bgm_night.volume_db = -80.0
	bgm_day.play()
	bgm_night.play()
	var tm = get_tree().get_first_node_in_group("time_manager")
	if tm != null:
		tm.phase_changed.connect(crossfade_bgm)
	crossfade_bgm(false)


func crossfade_bgm(is_night: bool) -> void:
	if is_night:
		_fade(bgm_day, false)
		_fade(bgm_night, true)
	else:
		_fade(bgm_night, false)
		_fade(bgm_day, true)


func _fade(player: AudioStreamPlayer, up: bool) -> void:
	var tw := create_tween()
	if up:
		tw.tween_property(player, "volume_db", 0.0, 2.0)
	else:
		tw.tween_property(player, "volume_db", -80.0, 2.0)


func play_sfx(name: String, pos: Vector2 = Vector2.ZERO) -> void:
	var player: AudioStreamPlayer = null
	if sfx_pool.has(name):
		player = sfx_pool[name]
	else:
		player = AudioStreamPlayer.new()
		add_child(player)
		sfx_pool[name] = player
	var stream := load("res://assets/sfx/" + name + ".ogg") as AudioStream
	if stream != null:
		player.stream = stream
	player.play()
