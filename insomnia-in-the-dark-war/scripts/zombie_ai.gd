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

	if state == "leave":
		_do_leave()
		return

	if is_attacking:
		return

	if state == "at_gap":
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var art := get_node_or_null("Art") as Node2D

	if abs(global_position.x) > 232.0:
		var dir: float = -sign(global_position.x)
		velocity = Vector2(dir * speed, 0.0)
		if art != null:
			art.scale.x = -1.0 if global_position.x > 0.0 else 1.0
		move_and_slide()
	else:
		var side: float = sign(global_position.x)
		var has_gap := false
		for socket in get_tree().get_nodes_in_group("critical_socket"):
			if socket is BuildSocket2D and not socket.is_occupied:
				if sign(socket.global_position.x) == side:
					has_gap = true
					break

		if has_gap:
			state = "at_gap"
			velocity = Vector2.ZERO
			move_and_slide()
		elif abs(global_position.x) < 200.0 and not _has_wall_in_front():
			if not has_looted:
				has_looted = true
				if GameState.spend_scrap(1):
					print("Zombie lục lọi! Mất 1 phế liệu.")
				else:
					print("Zombie lục lội nhưng bạn sạch túi... chúng chán nản bỏ đi.")
				state = "leave"
		else:
			velocity = Vector2.ZERO
			move_and_slide()

func _has_wall_in_front() -> bool:
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("defensive_wall"):
			return true
	return false

func _do_leave() -> void:
	var art := get_node_or_null("Art") as Node2D
	var dir: float = sign(spawn_position.x)
	velocity = Vector2(dir * speed, 0.0)
	if art != null:
		art.scale.x = -1.0 if dir < 0.0 else 1.0
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
		_spawn_death_fx()
		print("Zombie gục ngã và tan biến...")
		JournalManager.track_progress("zombie_kill")
		queue_free()


func _spawn_death_fx() -> void:
	var particles := GPUParticles2D.new()
	var parent := get_parent()
	if parent != null:
		parent.add_child(particles)
	else:
		add_child(particles)
	particles.global_position = global_position
	particles.amount = 15
	particles.lifetime = 0.5
	particles.one_shot = true
	var mat := ParticleProcessMaterial.new()
	mat.color = Color(0.5, 0.7, 0.5)
	mat.gravity = Vector3(0.0, 100.0, 0.0)
	mat.scale_min = 0.0
	mat.scale_max = 0.3
	particles.process_material = mat
	particles.emitting = true
	get_tree().create_timer(0.6).timeout.connect(particles.queue_free)
