extends Area2D

var current_target: CharacterBody2D = null

@export var attack_damage: float = 10.0
@export var solar_cost_per_shot: float = 5.0

func _ready() -> void:
	add_to_group("auto_turret")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$FireRateTimer.timeout.connect(_on_fire_rate_timer_timeout)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("zombie"):
		if current_target == null:
			current_target = body as CharacterBody2D

func _on_body_exited(body: Node2D) -> void:
	if body == current_target:
		current_target = null

func _on_fire_rate_timer_timeout() -> void:
	if current_target != null and not is_instance_valid(current_target):
		current_target = null

	var tm = get_tree().get_first_node_in_group("time_manager")
	if tm == null or tm.is_night == false:
		return

	if current_target != null and is_instance_valid(current_target):
		if tm.spend_solar(solar_cost_per_shot):
			var final_damage: float = attack_damage * GameState.turret_damage_multiplier
			current_target.call("take_damage", final_damage)
			print("Turret phun lửa! Tiêu tốn ", solar_cost_per_shot, " Solar.")
		else:
			print("Hết năng lượng mặt trời! Turret ngừng bắn.")

func apply_buff(type: String) -> void:
	print("Turret nhận buff (damage x", GameState.turret_damage_multiplier, "): ", type)
