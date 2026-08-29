extends Area2D

@export_enum("scrap", "seed", "water") var item_type: String = "scrap"

var player_inside: bool = false

func _ready() -> void:
	add_to_group("scrap")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	match item_type:
		"scrap":
			$Sprite2D.modulate = Color(0.7, 0.7, 0.7, 1)
		"seed":
			$Sprite2D.modulate = Color(0.4, 0.9, 0.4, 1)
		"water":
			$Sprite2D.modulate = Color(0.4, 0.6, 1.0, 1)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_inside:
		match item_type:
			"scrap":
				GameState.add_scrap(1)
			"seed":
				GameState.add_seeds(1)
			"water":
				GameState.add_water(1)
		queue_free()
