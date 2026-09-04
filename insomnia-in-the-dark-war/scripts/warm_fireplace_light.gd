extends PointLight2D

@export var base_energy: float = 0.55
@export var flicker_speed: float = 8.0

var noise: FastNoiseLite
var noise_time: float = 0.0
var _update_timer: float = 0.0

func _ready() -> void:
	shadow_enabled = false
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

func _process(delta: float) -> void:
	if GameState != null and GameState.eco_mode:
		energy = base_energy
		return
	_update_timer += delta
	if _update_timer >= 0.08:
		_update_timer = 0.0
		noise_time += delta * flicker_speed * 1.5
		energy = base_energy + (noise.get_noise_1d(noise_time) * 0.25)
