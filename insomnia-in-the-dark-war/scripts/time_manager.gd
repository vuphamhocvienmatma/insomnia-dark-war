extends Node

signal phase_changed(is_night: bool)
signal solar_changed(new_amount: float)

@export var day_duration_seconds: float = 180.0
@export var night_duration_seconds: float = 90.0

@export var day_color: Color = Color("ffe699")
@export var night_color: Color = Color("1c1d3a")

@export var environmental_light: CanvasModulate

var current_solar_energy: float = 0.0
var max_solar_storage: float = 100.0
var is_night: bool = false
var time_elapsed: float = 0.0

func _ready() -> void:
	add_to_group("time_manager")

func _process(delta: float) -> void:
	time_elapsed += delta
	var target_color: Color

	if not is_night:
		var ratio := time_elapsed / day_duration_seconds
		var eased_ratio := ease(ratio, 0.4)
		target_color = day_color.lerp(night_color, eased_ratio)
		if GameState:
			current_solar_energy = clamp(
				current_solar_energy + (delta * 5.0 * GameState.solar_charge_multiplier),
				0.0,
				max_solar_storage
			)
			solar_changed.emit(current_solar_energy)

		if time_elapsed >= day_duration_seconds:
			transition_to_night()
	else:
		var ratio := time_elapsed / night_duration_seconds
		target_color = night_color.lerp(day_color, ratio * 0.1)

		if time_elapsed >= night_duration_seconds:
			transition_to_day()

	if environmental_light != null:
		environmental_light.color = target_color

func transition_to_night() -> void:
	is_night = true
	time_elapsed = 0.0
	phase_changed.emit(true)
	print("Đêm xuống, hãy cầu nguyện hàng rào không bị vỡ...")

func transition_to_day() -> void:
	is_night = false
	time_elapsed = 0.0
	current_solar_energy = 0.0  # Reset solar khi ngày mới bắt đầu
	phase_changed.emit(false)
	GameState.start_new_day()
	if SaveManager:
		SaveManager.save_game()

func spend_solar(amount: float) -> bool:
	if current_solar_energy < amount:
		return false
	current_solar_energy -= amount
	solar_changed.emit(current_solar_energy)
	return true
