extends Area2D

var player_inside: bool = false
var is_cooking: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$CookingTimer.timeout.connect(_on_cooking_timer_timeout)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_inside and not is_cooking:
		start_cooking()

func start_cooking() -> void:
	is_cooking = true
	$SteamParticles.emitting = true
	$CookingTimer.start()

func _on_cooking_timer_timeout() -> void:
	is_cooking = false
	$SteamParticles.emitting = false
	print("Món súp nấu chín! Thật chill...")
