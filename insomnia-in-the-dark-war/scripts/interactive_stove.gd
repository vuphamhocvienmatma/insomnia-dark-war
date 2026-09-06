extends Area2D

var player_inside: bool = false
var is_cooking: bool = false



var _noise: FastNoiseLite
var _time: float = 0.0

func _ready() -> void:
	add_to_group("stove")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$CookingTimer.timeout.connect(_on_cooking_timer_timeout)
	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

func _process(delta: float) -> void:
	_time += delta * 15.0
	if has_node("FireLight"):
		var light = get_node("FireLight")
		light.energy = 1.0 + _noise.get_noise_1d(_time) * 0.4
		light.scale = Vector2.ONE * (1.0 + _noise.get_noise_1d(_time + 100.0) * 0.1)
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_inside and not is_cooking:
		interact()
		get_viewport().set_input_as_handled()


func interact() -> void:
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("open_cooking_modal"):
		hud.call("open_cooking_modal")
	else:
		start_cooking_visual()


func start_cooking_visual() -> void:
	is_cooking = true
	$SteamParticles.emitting = true
	$CookingTimer.start()


func _on_cooking_timer_timeout() -> void:
	is_cooking = false
	$SteamParticles.emitting = false
	print("Món súp nấu chín! Thật chill...")
