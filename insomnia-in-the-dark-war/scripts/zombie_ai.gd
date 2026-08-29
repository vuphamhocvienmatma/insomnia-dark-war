extends CharacterBody2D

@export var speed: float = 30.0
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.5
@export var max_health: float = 30.0

var current_health: float = 0.0
var spawn_position: Vector2 = Vector2.ZERO
var is_leaving: bool = false
var has_looted: bool = false

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer

var target_fort_center: Vector2 = Vector2.ZERO
var is_attacking: bool = false
var current_target_fence: Node2D = null

func _ready() -> void:
	current_health = max_health
	add_to_group("zombie")
	spawn_position = global_position
	target_fort_center = get_tree().get_first_node_in_group("fort_center").global_position
	navigation_agent.target_position = target_fort_center
	attack_timer.wait_time = attack_cooldown
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(_delta: float) -> void:
	if is_attacking:
		return

	if navigation_agent.is_navigation_finished() and not is_attacking:
		if not is_leaving:
			if not has_looted:
				has_looted = true
				if GameState.spend_scrap(1):
					print("Zombie lục lọi! Mất 1 phế liệu.")
				else:
					print("Zombie lục lọi nhưng bạn sạch túi... chúng chán nản bỏ đi.")
			is_leaving = true
			navigation_agent.target_position = spawn_position
		else:
			queue_free()
		return

	var next_path_pos := navigation_agent.get_next_path_position()
	var dir := global_position.direction_to(next_path_pos)
	velocity = dir * speed
	move_and_slide()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("defensive_wall"):
		is_attacking = true
		current_target_fence = body
		attack_timer.start()

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body == current_target_fence:
		is_attacking = false
		attack_timer.stop()
		current_target_fence = null
		navigation_agent.target_position = target_fort_center

func _on_attack_timer_timeout() -> void:
	if current_target_fence and is_instance_valid(current_target_fence):
		current_target_fence.take_damage(attack_damage)
		var cam := get_tree().get_first_node_in_group("main_camera")
		if cam and cam.has_method("trigger_shake"):
			cam.trigger_shake(8.0)
	else:
		is_attacking = false
		attack_timer.stop()
		navigation_agent.target_position = target_fort_center

func take_damage(amount: float) -> void:
	current_health -= amount
	print("Zombie chịu ", amount, " sát thương! Còn lại: ", current_health)
	if current_health <= 0.0:
		print("Zombie gục ngã và tan biến...")
		queue_free()
