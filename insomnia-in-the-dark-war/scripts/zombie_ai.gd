extends CharacterBody2D

const GROUND_Y: float = 0.0

@export var speed: float = 30.0
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.5
@export var max_health: float = 30.0

var current_health: float = 0.0
var spawn_position: Vector2 = Vector2.ZERO
var state: String = "approach"
var has_looted: bool = false

@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer

var is_attacking: bool = false
var current_target_fence: Node2D = null

func _ready() -> void:
	current_health = max_health
	add_to_group("zombie")
	position.y = GROUND_Y
	spawn_position = global_position
	attack_timer.wait_time = attack_cooldown
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(_delta: float) -> void:
	position.y = GROUND_Y

	if is_attacking:
		return

	var dir: float = 0.0
	var art := get_node_or_null("Art") as Node2D

	if state == "approach":
		dir = -sign(global_position.x)
		velocity = Vector2(dir * speed, 0.0)
		if art != null:
			art.scale.x = -1.0 if global_position.x > 0.0 else 1.0
		move_and_slide()
		if abs(global_position.x) < 40.0 and not has_looted:
			has_looted = true
			if GameState.spend_scrap(1):
				print("Zombie lục lọi! Mất 1 phế liệu.")
			else:
				print("Zombie lục lội nhưng bạn sạch túi... chúng chán nản bỏ đi.")
			state = "leave"
	elif state == "leave":
		dir = sign(spawn_position.x - global_position.x)
		velocity = Vector2(dir * speed, 0.0)
		if art != null:
			art.scale.x = -1.0 if (spawn_position.x - global_position.x) < 0.0 else 1.0
		move_and_slide()
		if abs(global_position.x - spawn_position.x) < 35.0:
			queue_free()

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

func _on_attack_timer_timeout() -> void:
	if current_target_fence and is_instance_valid(current_target_fence):
		current_target_fence.call("take_damage", attack_damage)
		var cam := get_tree().get_first_node_in_group("main_camera")
		if cam and cam.has_method("trigger_shake"):
			cam.call("trigger_shake", 8.0)
	else:
		is_attacking = false
		attack_timer.stop()

func take_damage(amount: float) -> void:
	current_health -= amount
	print("Zombie chịu ", amount, " sát thương! Còn lại: ", current_health)
	if current_health <= 0.0:
		print("Zombie gục ngã và tan biến...")
		JournalManager.track_progress("zombie_kill")
		queue_free()
