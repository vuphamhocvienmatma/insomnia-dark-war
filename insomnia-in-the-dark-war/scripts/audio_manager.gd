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
	var day_path: String = ""
	if ResourceLoader.exists("res://assets/bgm/day_lofi.ogg"):
		day_path = "res://assets/bgm/day_lofi.ogg"
	elif ResourceLoader.exists("res://assets/bgm/day_lofi.wav"):
		day_path = "res://assets/bgm/day_lofi.wav"
		
	if day_path != "":
		var s_day: AudioStream = load(day_path) as AudioStream
		if s_day != null:
			if s_day is AudioStreamWAV:
				(s_day as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
			elif s_day is AudioStreamOggVorbis:
				(s_day as AudioStreamOggVorbis).loop = true
			bgm_day.stream = s_day
			bgm_day.play()

	var night_path: String = ""
	if ResourceLoader.exists("res://assets/bgm/night_ambient.ogg"):
		night_path = "res://assets/bgm/night_ambient.ogg"
	elif ResourceLoader.exists("res://assets/bgm/night_ambient.wav"):
		night_path = "res://assets/bgm/night_ambient.wav"
		
	if night_path != "":
		var s_night: AudioStream = load(night_path) as AudioStream
		if s_night != null:
			if s_night is AudioStreamWAV:
				(s_night as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
			elif s_night is AudioStreamOggVorbis:
				(s_night as AudioStreamOggVorbis).loop = true
			bgm_night.stream = s_night
			bgm_night.play()

	bgm_day.volume_db = -6.0
	bgm_night.volume_db = -80.0


var _connected_tm: Node = null

func _process(_delta: float) -> void:
	if _connected_tm == null:
		var tm: Node = get_tree().get_first_node_in_group("time_manager")
		if tm != null:
			_connected_tm = tm
			if not tm.phase_changed.is_connected(crossfade_bgm):
				tm.phase_changed.connect(crossfade_bgm)
			var is_night: bool = bool(tm.get("is_night"))
			crossfade_bgm(is_night)
	
	# Ensure music keeps playing
	if bgm_day.stream != null and not bgm_day.playing and bgm_day.volume_db > -40.0:
		bgm_day.play()
	if bgm_night.stream != null and not bgm_night.playing and bgm_night.volume_db > -40.0:
		bgm_night.play()


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
		tw.tween_property(player, "volume_db", -6.0, 2.0)
	else:
		tw.tween_property(player, "volume_db", -80.0, 2.0)


func play_sfx(sfx_name: String, pos: Vector2 = Vector2.ZERO) -> void:
	var player: AudioStreamPlayer = null
	if sfx_pool.has(sfx_name):
		player = sfx_pool[sfx_name]
	else:
		player = AudioStreamPlayer.new()
		add_child(player)
		sfx_pool[sfx_name] = player
	var sfx_path: String = "res://assets/sfx/" + sfx_name + ".ogg"
	if ResourceLoader.exists(sfx_path):
		var stream: AudioStream = load(sfx_path) as AudioStream
		if stream != null:
			player.stream = stream
			player.play()
