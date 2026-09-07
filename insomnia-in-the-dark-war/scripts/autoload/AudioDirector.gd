extends Node

const BGM_DIR = "res://assets/bgm/"
const SFX_DIR = "res://assets/sfx/"

# Audio Buses
const BUS_MASTER = "Master"
const BUS_BGM = "BGM_Bus"
const BUS_WEATHER = "Weather_Bus"
const BUS_SFX = "SFX_Bus"
const BUS_UI = "UI_Bus"

const WEATHER_BED_MAP = {
	"drizzle": "rain",
	"heavy_rain": "rain",
	"thick_fog": "wind",
	"snowstorm": "wind",
	"meteor_shower": "wind",
	"sandstorm": "sandstorm",
	"nightmare_sandstorm": "sandstorm",
}

# Pooling
var _sfx_players: Array[AudioStreamPlayer] = []
var _bgm_players: Array[AudioStreamPlayer] = []
var _weather_players: Array[AudioStreamPlayer] = []

var _sfx_2d_pool: Array[AudioStreamPlayer2D] = []
var _active_bgm_idx: int = 0
var _current_bgm_name: String = ""
var _current_weather_id: String = ""
var _bgm_base_vol: float = 0.0
var _duck_tween: Tween = null
var _duck_active: bool = false

var _audio_resumed: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_buses()
	_init_pools()
	_connect_signals()
	# Resume Web AudioContext after first user gesture (required for HTML5/WebGL)
	if OS.has_feature("web"):
		get_viewport().gui_focus_changed.connect(_on_web_focus_changed)

func _on_web_focus_changed(_ctrl: Control) -> void:
	_resume_web_audio()

func _unhandled_input(event: InputEvent) -> void:
	if not _audio_resumed and OS.has_feature("web"):
		if event is InputEventMouseButton or event is InputEventKey:
			_resume_web_audio()

func _resume_web_audio() -> void:
	if _audio_resumed:
		return
	_audio_resumed = true
	# Godot 4 Web: AudioServer.resume_autoplay() doesn't exist, but playing a silent
	# stream or just setting bus volumes forces the AudioContext to resume
	var bgm_bus = AudioServer.get_bus_index(BUS_BGM)
	if bgm_bus >= 0:
		AudioServer.set_bus_mute(bgm_bus, false)
	print("🔊 Web AudioContext resumed after user gesture")

func _setup_buses() -> void:
	# Ensure buses exist
	_ensure_bus(BUS_BGM)
	_ensure_bus(BUS_WEATHER)
	_ensure_bus(BUS_SFX)
	_ensure_bus(BUS_UI)

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

func connect_time_manager(tm: Node) -> void:
	if tm == null:
		return
	if tm.has_signal("phase_changed") and not tm.phase_changed.is_connected(_on_time_phase_changed):
		tm.phase_changed.connect(_on_time_phase_changed)
	if tm.has_signal("sunset_warning") and not tm.sunset_warning.is_connected(func(): crossfade_bgm("bgm_sunset", 3.0)):
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
		push_warning("BGM not found: " + BGM_DIR + target_track + ".ogg")
		return
		
	p_in.stream = stream
	p_in.volume_db = -80.0
	p_in.play()
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(p_in, "volume_db", _bgm_base_vol, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(p_out, "volume_db", -80.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_callback(p_out.stop)
	
	_active_bgm_idx = next_idx
	# Restore bus volume in case a duck was in progress
	var bgm_bus_idx = AudioServer.get_bus_index(BUS_BGM)
	if bgm_bus_idx >= 0:
		AudioServer.set_bus_volume_db(bgm_bus_idx, _bgm_base_vol)

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
	var bed_key = WEATHER_BED_MAP.get(weather_id, weather_id)
	var bed_path = BGM_DIR + "bed_" + bed_key + ".ogg"
	if ResourceLoader.exists(bed_path):
		var stream = load(bed_path)
		if stream:
			var p = _weather_players[0]
			p.stream = stream
			p.volume_db = -80.0
			p.play()
			create_tween().tween_property(p, "volume_db", 0.0, 2.0)

func duck_bgm(amount_db: float = -6.0, duration: float = 0.1, hold: float = 0.8) -> void:
	# Guard: don't restart duck if already ducking (prevents pumping from rapid triggers)
	if _duck_active:
		return
	var bgm_bus_idx = AudioServer.get_bus_index(BUS_BGM)
	if bgm_bus_idx < 0:
		return
	_duck_active = true
	if _duck_tween != null and _duck_tween.is_valid():
		_duck_tween.kill()
	var current_vol = AudioServer.get_bus_volume_db(bgm_bus_idx)
	var target_vol = _bgm_base_vol + amount_db
	_duck_tween = create_tween()
	_duck_tween.tween_method(func(val: float): AudioServer.set_bus_volume_db(bgm_bus_idx, val), current_vol, target_vol, duration)
	_duck_tween.tween_interval(hold)
	_duck_tween.tween_method(func(val: float): AudioServer.set_bus_volume_db(bgm_bus_idx, val), target_vol, _bgm_base_vol, duration * 2.0)
	_duck_tween.tween_callback(func(): _duck_active = false)

func trigger_thunder() -> void:
	var v = randi() % 3 + 1
	play_sfx("bed_thunder_0" + str(v), 0.0, BUS_WEATHER)
	duck_bgm(-6.0, 0.1, 1.0)

func play_sfx(id: String, pitch_variance: float = 0.05, custom_bus: String = BUS_SFX) -> void:
	# Eco mode: limit SFX to reduce CPU load on WebGL
	if GameState != null and GameState.eco_mode:
		var any_playing = false
		for p in _sfx_players:
			if p.playing:
				any_playing = true
				break
		if any_playing:
			return
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
	if perfect:
		# Play a pluck sound with lane-based pitch variation
		var pitch_offset = float(lane) * 0.08
		play_sfx("typewriter_tick", 0.02, BUS_SFX)
	else:
		duck_bgm(-10.0, 0.1, 0.3)

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
	if not ResourceLoader.exists(SFX_DIR + id + ".ogg"):
		return
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
		
	# Adjust max_distance based on camera zoom to prevent volume whiplash
	var cam = get_viewport().get_camera_2d()
	var zoom_factor: float = 1.0
	if cam != null:
		zoom_factor = max(cam.zoom.x, 0.5)
		
	for p in _sfx_2d_pool:
		if not p.playing:
			p.stream = stream
			p.global_position = world_pos
			p.max_distance = 1500.0 / zoom_factor
			p.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
			p.play()
			return
