extends StaticBody2D

@export var max_health: float = 50.0

var current_health: float = 0.0

func _ready() -> void:
	current_health = max_health
	add_to_group("defensive_wall")

func take_damage(amount: float) -> void:
	current_health -= amount
	print("Rào chắn chịu ", amount, " sát thương! Còn lại: ", current_health)
	if current_health <= 0.0:
		queue_free()
