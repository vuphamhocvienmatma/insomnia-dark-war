extends Node

const BGM_DIR = "res://assets/bgm/"
const SFX_DIR = "res://assets/sfx/"

# Audio Buses
const BUS_MASTER = "Master"
const BUS_BGM = "BGM_Bus"
const BUS_WEATHER = "Weather_Bus"
const BUS_SFX = "SFX_Bus"
const BUS_UI = "UI_Bus"

# Pooling
var _sfx_players: Array[AudioStreamPlayer] = []
var _bgm_players: Array[AudioStreamPlayer] = []
var _weather_players: Array[AudioStreamPlayer] = []

var _sfx_2d_pool: Array[AudioStreamPlayer2D] = []
var _active_bgm_idx: int = 0
var _current_bgm_name: String = ""
var _current_weather_id: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_buses()
	_init_pools()
	_connect_signals()

func _setup_buses() -> void:
	# Ensure buses exist
	_ensure_bus(BUS_BGM)
	_ensure_bus(BUS_WEATHER)
	_ensure_bus(BUS_SFX)
	_ensure_bus(BUS_UI)
	
	# Add compressor to Master to duck BGM when SFX is loud
	var master_idx = AudioServer.get_bus_index(BUS_MASTER)
	var has_comp = false
	for i in AudioServer.get_bus_effect_count(master_idx):
		if AudioServer.get_bus_effect(master_idx, i) is AudioEffectCompressor:
			has_comp = true
			break
	
	if not has_comp:
		var comp = AudioEffectCompressor.new()
		comp.threshold = -15.0
		comp.ratio = 4.0
		comp.release_ms = 250.0
		AudioServer.add_bus_effect(master_idx, comp)

func _ensure_bus(bus_name: String) -> void:
	var idx = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		AudioServer.add_bus()
		idx = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(idx, bus_name)
		AudioServer.set_bus_send(idx, BUS_MASTER)

func _init_pools() -> void:
	# SFX Pool (10)
	for i in 10:
		var p = AudioStreamPlayer.new()
		p.bus = BUS_SFX
		add_child(p)
		_sfx_players.append(p)
		var p2 = AudioStreamPlayer2D.new()
		p2.bus = BUS_SFX
		p2.max_distance = 1500.0
		p2.attenuation = 2.0
		add_child(p2)
		_sfx_2d_pool.append(p2)
		
	# BGM Pool (2 for crossfade)
	for i in 2:
		var p = AudioStreamPlayer.new()
		p.bus = BUS_BGM
		add_child(p)
		_bgm_players.append(p)
		
	# Weather Pool (4)
	for i in 4:
		var p = AudioStreamPlayer.new()
		p.bus = BUS_WEATHER
		add_child(p)
		_weather_players.append(p)

func _connect_signals() -> void:
	# Note: These autoloads must exist in the project
	if has_node("/root/GameState"):
		var gs = get_node("/root/GameState")
		if gs.has_signal("eco_mode_changed"):
			gs.eco_mode_changed.connect(_on_eco_mode_changed)
			
	if has_node("/root/TimeManager"):
		var tm = get_node("/root/TimeManager")
		if tm.has_signal("phase_changed"):
			tm.phase_changed.connect(_on_time_phase_changed)
		if tm.has_signal("sunset_warning"):
			tm.sunset_warning.connect(func(): crossfade_bgm("bgm_sunset", 3.0))

func crossfade_bgm(target_track: String, duration: float = 3.0) -> void:
	if _current_bgm_name == target_track:
		return
		
	_current_bgm_name = target_track
	var next_idx = (_active_bgm_idx + 1) % 2
	var p_out = _bgm_players[_active_bgm_idx]
	var p_in = _bgm_players[next_idx]
	
	var stream = load(BGM_DIR + target_track + ".ogg")
	if not stream:
		push_warning("BGM not found: " + target_track)
		return
		
	p_in.stream = stream
	p_in.volume_db = -80.0
	p_in.play()
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(p_in, "volume_db", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(p_out, "volume_db", -80.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_callback(p_out.stop)
	
	_active_bgm_idx = next_idx

func set_weather(weather_id: String) -> void:
	if _current_weather_id == weather_id:
		return
	_current_weather_id = weather_id
	
	# Stop all weather beds
	var has_playing = false
	for p in _weather_players:
		if p.playing:
			has_playing = true
			break
	if has_playing:
		var tween = create_tween()
		for p in _weather_players:
			if p.playing:
				tween.tween_property(p, "volume_db", -80.0, 2.0)
				tween.chain().tween_callback(p.stop)
			
	if weather_id == "":
		return
		
	# Play new weather bed
	var bed_path = BGM_DIR + "bed_" + weather_id + ".ogg"
	if ResourceLoader.exists(bed_path):
		var stream = load(bed_path)
		if stream:
			var p = _weather_players[0]
			p.stream = stream
			p.volume_db = -80.0
			p.play()
			create_tween().tween_property(p, "volume_db", 0.0, 2.0)

func trigger_thunder() -> void:
	var v = randi() % 3 + 1
	play_sfx("bed_thunder_0" + str(v), 0.0, BUS_WEATHER)
	
	# Duck BGM
	var bgm_bus_idx = AudioServer.get_bus_index(BUS_BGM)
	if bgm_bus_idx >= 0:
		var current_vol = AudioServer.get_bus_volume_db(bgm_bus_idx)
		var tween = create_tween()
		tween.tween_method(func(val: float): AudioServer.set_bus_volume_db(bgm_bus_idx, val), current_vol, current_vol - 3.0, 0.1)
		tween.tween_interval(1.0)
		tween.tween_method(func(val: float): AudioServer.set_bus_volume_db(bgm_bus_idx, val), current_vol - 3.0, current_vol, 1.0)

func play_sfx(id: String, pitch_variance: float = 0.05, custom_bus: String = BUS_SFX) -> void:
	var stream = null
	if ResourceLoader.exists(SFX_DIR + id + ".ogg"):
		stream = load(SFX_DIR + id + ".ogg")
	elif ResourceLoader.exists(BGM_DIR + id + ".ogg"):
		stream = load(BGM_DIR + id + ".ogg")
	if not stream:
		return
		
	for p in _sfx_players:
		if not p.playing:
			p.stream = stream
			p.bus = custom_bus
			p.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
			p.play()
			return
			
	# If all playing, override oldest (first in array for simplicity, just index 0)
	var override_p = _sfx_players[0]
	override_p.stream = stream
	override_p.bus = custom_bus
	override_p.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
	override_p.play()

func on_guitar_hit(lane: int, perfect: bool) -> void:
	# If missing beat, duck BGM slightly to simulate missing voice
	if not perfect:
		var p_in = _bgm_players[_active_bgm_idx]
		var old_vol = p_in.volume_db
		var tween = create_tween()
		tween.tween_property(p_in, "volume_db", old_vol - 10.0, 0.1)
		tween.tween_property(p_in, "volume_db", old_vol, 0.4)

func _on_eco_mode_changed(is_eco: bool) -> void:
	# Turn off vinyl crackle and wow/flutter in Lofi Shader or Audio Bus
	# For now we'll just lowpass the master bus slightly more if eco is on to simulate it, or disable effects
	pass

func _on_time_phase_changed(is_night: bool) -> void:
	if is_night:
		crossfade_bgm("bgm_night_watch", 4.0)
	else:
		crossfade_bgm("bgm_day_clear", 4.0)

func play_sfx_positional(id: String, world_pos: Vector2, pitch_variance: float = 0.05) -> void:
	var stream = load(SFX_DIR + id + ".ogg")
	if not stream: return
	
	# Only pan if weather is bad
	var level = get_node_or_null("/root/LevelSetup")
	var is_bad_weather = false
	if level and level.has_node("ArtWeather"):
		var w_type = level.get_node("ArtWeather").get("weather_type")
		if w_type and w_type != "sunny" and w_type != "clear":
			is_bad_weather = true
			
	if not is_bad_weather:
		play_sfx(id, pitch_variance)
		return
		
	for p in _sfx_2d_pool:
		if not p.playing:
			p.stream = stream
			p.global_position = world_pos
			p.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
			p.play()
			return
