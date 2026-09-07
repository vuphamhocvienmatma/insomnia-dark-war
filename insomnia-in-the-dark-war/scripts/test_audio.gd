extends Control

func _ready() -> void:
	$VBox/BtnDay.pressed.connect(func(): AudioDirector.crossfade_bgm("bgm_day_clear"))
	$VBox/BtnNight.pressed.connect(func(): AudioDirector.crossfade_bgm("bgm_night_watch"))
	$VBox/BtnRain.pressed.connect(func(): AudioDirector.set_weather("rain"))
	$VBox/BtnThunder.pressed.connect(func(): AudioDirector.trigger_thunder())
	$VBox/BtnSfx.pressed.connect(func(): AudioDirector.play_sfx("click_wood"))
	$VBox/BtnGuitar.pressed.connect(func(): AudioDirector.on_guitar_hit(0, true))

