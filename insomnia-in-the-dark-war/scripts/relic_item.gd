extends Area2D

@export_enum("buff_turret", "buff_plant", "buff_solar") var relic_type: String = "buff_turret"

var player_inside: bool = false

func _ready() -> void:
	add_to_group("relic")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_inside:
		GameState.add_relic(relic_type)
		queue_free()
