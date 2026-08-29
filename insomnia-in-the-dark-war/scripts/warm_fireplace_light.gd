extends PointLight2D

@export var base_energy: float = 1.2
@export var flicker_speed: float = 12.0

var noise: FastNoiseLite
var noise_time: float = 0.0

func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

func _process(delta: float) -> void:
	noise_time += delta * flicker_speed
	energy = base_energy + (noise.get_noise_1d(noise_time) * 0.25)
