extends Node

signal phase_changed(is_night: bool)
signal solar_changed(new_amount: float)
signal sunset_warning

@export var day_duration_seconds: float = 180.0
@export var night_duration_seconds: float = 90.0

@export var day_color: Color = Color("#F4A261")
@export var sunset_color: Color = Color("#E76F51")
@export var night_color: Color = Color("#1D3557")

@export var environmental_light: CanvasModulate

var current_solar_energy: float = 0.0
var max_solar_storage: float = 100.0
var is_night: bool = false
var time_elapsed: float = 0.0
var _warned_sunset: bool = false

func _ready() -> void:
	add_to_group("time_manager")

func _process(delta: float) -> void:
	time_elapsed += delta
	var target_color: Color

	if not is_night:
		var ratio: float = time_elapsed / day_duration_seconds
		if ratio < 0.65:
			# Morning to late afternoon golden transition
			var sub_t: float = ratio / 0.65
			target_color = day_color.lerp(sunset_color, sub_t * 0.5)
		else:
			# Sunset to twilight transition
			var sub_t: float = (ratio - 0.65) / 0.35
			var eased_dusk: float = ease(sub_t, 0.6)
			target_color = sunset_color.lerp(night_color, eased_dusk)
			
		if GameState:
			current_solar_energy = clamp(
				current_solar_energy + (delta * 5.0 * GameState.solar_charge_multiplier),
				0.0,
				max_solar_storage
			)
			solar_changed.emit(current_solar_energy)

		if not _warned_sunset and (day_duration_seconds - time_elapsed) <= 10.0:
			_warned_sunset = true
			sunset_warning.emit()

		if time_elapsed >= day_duration_seconds:
			transition_to_night()
	else:
		var ratio: float = time_elapsed / night_duration_seconds
		# Late night pre-dawn blue tint
		target_color = night_color.lerp(sunset_color, ratio * 0.15)

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
	_warned_sunset = false
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
