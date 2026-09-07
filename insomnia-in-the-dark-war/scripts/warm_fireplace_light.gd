extends PointLight2D

@export var base_energy: float = 0.55
@export var flicker_speed: float = 8.0

# Thermal Contrast: Màu đèn thay đổi theo thời tiết
const COLOR_WARM_GOLD: Color = Color(1.00, 0.82, 0.55, 1.0)
const COLOR_EMBER_RED: Color = Color(1.00, 0.45, 0.20, 1.0)
const COLOR_ICY_BLUE: Color = Color(0.60, 0.78, 1.00, 1.0)

var noise: FastNoiseLite
var noise_time: float = 0.0
var _update_timer: float = 0.0
var _target_color: Color = COLOR_WARM_GOLD
var _current_color: Color = COLOR_WARM_GOLD
var _target_energy: float = 0.55

func _ready() -> void:
	shadow_enabled = false
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	color = COLOR_WARM_GOLD

func on_weather_changed(weather_type: String) -> void:
	match weather_type:
		"sandstorm", "nightmare_sandstorm":
			_target_color = COLOR_EMBER_RED
			flicker_speed = 14.0
		"rain", "thunder":
			_target_color = COLOR_WARM_GOLD
			flicker_speed = 9.0
		"night_clear":
			_target_color = COLOR_ICY_BLUE
			flicker_speed = 6.0
		_:
			_target_color = COLOR_WARM_GOLD
			flicker_speed = 8.0

func _process(delta: float) -> void:
	if GameState != null and GameState.eco_mode:
		energy = base_energy
		return

	_current_color = _current_color.lerp(_target_color, delta * 1.5)
	color = _current_color

	_update_timer += delta
	if _update_timer >= 0.04:
		_update_timer = 0.0
		noise_time += delta * flicker_speed * 1.5
		_target_energy = base_energy + (noise.get_noise_1d(noise_time) * 0.25)
	energy = lerpf(energy, _target_energy, 8.0 * delta)
