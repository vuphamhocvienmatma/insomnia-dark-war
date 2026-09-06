extends Node



signal phase_changed(is_night: bool)

signal solar_changed(new_amount: float)

signal sunset_warning

signal mood_changed(mood_name: String)



var current_mood: String = ""



@export var day_duration_seconds: float = 180.0

@export var night_duration_seconds: float = 90.0



@export var day_color: Color = Color("#F4A261")

@export var sunset_color: Color = Color("#E76F51")

@export var night_color: Color = Color("#1D3557")



@export var environmental_light: CanvasModulate



var sun_angle: Vector2 = Vector2.ZERO

var shadow_intensity: float = 1.0

var cloud_cover: float = 0.0

var _cloud_timer: float = 0.0



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

		var new_mood: String = "dawn"

		if ratio > 0.3 and ratio <= 0.65:

			new_mood = "golden"

		elif ratio > 0.65:

			new_mood = "dusk"

			

		if new_mood != current_mood:

			current_mood = new_mood

			mood_changed.emit(current_mood)

			

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

			var old_int: int = int(current_solar_energy)

			current_solar_energy = clamp(

				current_solar_energy + (delta * 5.0 * GameState.solar_charge_multiplier),

				0.0,

				max_solar_storage

			)

			if int(current_solar_energy) != old_int:

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



	# Cloud events

	if not is_night:

		_cloud_timer -= delta

		if _cloud_timer <= 0.0:

			if cloud_cover > 0.0:

				cloud_cover -= delta * 0.5

				if cloud_cover <= 0.0:

					cloud_cover = 0.0

					_cloud_timer = randf_range(60.0, 120.0)

			else:

				if randf() < 0.3:

					cloud_cover += delta * 0.5

					if cloud_cover >= 0.6:

						cloud_cover = 0.6

						_cloud_timer = randf_range(5.0, 15.0)

				else:

					_cloud_timer = randf_range(10.0, 30.0)

	

	# Compute Sun Angle and Shadow Intensity

	var ls = get_node_or_null("/root/LevelSetup")

	var w = "sunny"

	if ls: w = str(ls.get("current_weather"))

	

	if is_night:

		var ratio = time_elapsed / night_duration_seconds

		sun_angle = Vector2(lerp(1.5, -1.5, ratio), 0.5)

		shadow_intensity = 0.6

	else:

		var ratio = time_elapsed / day_duration_seconds

		sun_angle = Vector2(lerp(-2.0, 2.0, ratio), 0.5)

		shadow_intensity = 1.0 - (cloud_cover * 0.8)

	

	if w == "heavy_rain" or w == "thick_fog" or w == "sandstorm":

		shadow_intensity = 0.0

	elif w == "drizzle" or w == "snowstorm":

		shadow_intensity *= 0.3



	if environmental_light != null:

		environmental_light.color = target_color.lerp(Color(0.5, 0.5, 0.5, 1.0), cloud_cover * 0.4)



func transition_to_night() -> void:

	is_night = true

	time_elapsed = 0.0

	phase_changed.emit(true)

	

	# Handle night moods based on game state

	current_mood = "night"

	if GameState.is_tired:

		current_mood = "insomnia"

	

	var ls = get_node_or_null("/root/LevelSetup")

	if ls != null:

		if ls.get("current_night_mutation") != "":

			current_mood = "nightmare"

			

	mood_changed.emit(current_mood)

	print("????????m xu???????ng, h????y c??????u nguy???????n h????ng r????o kh????ng b??????? v??????...")



func transition_to_day() -> void:

	is_night = false

	_warned_sunset = false

	time_elapsed = 0.0

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









