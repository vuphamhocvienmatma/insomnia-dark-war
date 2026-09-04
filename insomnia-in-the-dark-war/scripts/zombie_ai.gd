extends CharacterBody2D

const GROUND_Y: float = 0.0
const SAFE_RADIUS: float = 125.0

@export var speed: float = 30.0
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.5
@export var max_health: float = 30.0
@export var zombie_type: String = "normal"

var current_health: float = 0.0
var spawn_position: Vector2 = Vector2.ZERO
var state: String = "approach"
var has_looted: bool = false
var stolen_scrap: int = 0

@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer

var is_attacking: bool = false
var current_target_fence: Node2D = null
var safe_zone: Area2D = null
var _art_node: Node2D = null


func setup_type(type_name: String) -> void:
	zombie_type = type_name
	if zombie_type == "runner":
		speed = 68.0
		max_health = 16.0
		current_health = 16.0
		attack_damage = 8.0
		attack_cooldown = 1.0
	elif zombie_type == "brute":
		speed = 18.0
		max_health = 80.0
		current_health = 80.0
		attack_damage = 30.0
		attack_cooldown = 2.0
		scale = Vector2(1.35, 1.35)
	elif zombie_type == "thief":
		speed = 48.0
		max_health = 22.0
		current_health = 22.0
		attack_damage = 6.0
		attack_cooldown = 1.2
	else:
		zombie_type = "normal"
		speed = 30.0
		max_health = 30.0
		current_health = 30.0
		attack_damage = 10.0

	if attack_timer != null:
		attack_timer.wait_time = attack_cooldown
	if _art_node != null and "zombie_type" in _art_node:
		_art_node.set("zombie_type", zombie_type)


func _ready() -> void:
	current_health = max_health
	add_to_group("zombie")
	_art_node = get_node_or_null("Art") as Node2D
	if _art_node != null and "zombie_type" in _art_node:
		_art_node.set("zombie_type", zombie_type)

	var sz := get_tree().get_first_node_in_group("safe_zone")
	if sz != null:
		safe_zone = sz as Area2D
	position.y = GROUND_Y
	spawn_position = global_position
	attack_timer.wait_time = attack_cooldown
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)


func _physics_process(_delta: float) -> void:
	position.y = GROUND_Y

	if safe_zone == null:
		var sz := get_tree().get_first_node_in_group("safe_zone")
		if sz != null:
			safe_zone = sz as Area2D

	if safe_zone != null and is_instance_valid(safe_zone):
		var dist_to_safe: float = global_position.distance_to(safe_zone.global_position)
		if dist_to_safe < SAFE_RADIUS:
			var away: Vector2 = global_position - safe_zone.global_position
			if away.length() < 1.0:
				away = Vector2(sign(spawn_position.x), 0.0)
			velocity = away.normalized() * speed * 1.25
			if _art_node != null and velocity.x != 0.0:
				_art_node.scale.x = -1.0 if velocity.x < 0.0 else 1.0
			move_and_slide()
			return

	if state == "leave":
		_do_leave()
		return

	if is_attacking:
		return

	if state == "at_gap":
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if abs(global_position.x) > 232.0:
		var dir: float = -sign(global_position.x)
		velocity = Vector2(dir * speed, 0.0)
		if _art_node != null:
			_art_node.scale.x = -1.0 if global_position.x > 0.0 else 1.0
		move_and_slide()
	else:
		var side: float = sign(global_position.x)
		var has_gap: bool = false
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
				if zombie_type == "thief":
					if GameState.spend_scrap(2):
						stolen_scrap = 2
					elif GameState.spend_scrap(1):
						stolen_scrap = 1
					if stolen_scrap > 0:
						var hud: Node = get_tree().get_first_node_in_group("hud")
						if hud != null and hud.has_method("show_toast"):
							hud.call("show_toast", "⚠️ Tên trộm Thief đã cuỗm " + str(stolen_scrap) + " phế liệu!", 3.0, true)
				else:
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
	var dir: float = sign(spawn_position.x)
	velocity = Vector2(dir * speed, 0.0)
	if _art_node != null:
		_art_node.scale.x = -1.0 if dir < 0.0 else 1.0
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
		var cam: Node = get_tree().get_first_node_in_group("main_camera")
		if cam != null and cam.has_method("trigger_shake"):
			var shake_pwr: float = 14.0 if zombie_type == "brute" else 6.0
			cam.call("trigger_shake", shake_pwr)
	else:
		is_attacking = false
		attack_timer.stop()

func take_damage(amount: float) -> void:
	current_health -= amount
	if current_health <= 0.0:
		_spawn_death_fx()
		if stolen_scrap > 0:
			GameState.add_scrap(stolen_scrap)
			var hud: Node = get_tree().get_first_node_in_group("hud")
			if hud != null and hud.has_method("show_toast"):
				hud.call("show_toast", "🎉 Đã hạ gục tên trộm! Thu hồi +" + str(stolen_scrap) + " phế liệu!", 3.0, false)

		var ls: Node = get_tree().root.find_child("LevelSetup", true, false)
		if ls != null and str(ls.get("current_night_mutation")) == "scrap_jackpot":
			GameState.add_scrap(1) # Extra jackpot drop

		JournalManager.track_progress("zombie_kill")
		queue_free()


func _spawn_death_fx() -> void:
	var particles := CPUParticles2D.new()
	var parent := get_parent()
	if parent != null:
		parent.add_child(particles)
	else:
		get_tree().current_scene.add_child(particles)
	particles.global_position = global_position
	particles.amount = 10
	particles.lifetime = 0.4
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.direction = Vector2(0, -1)
	particles.spread = 60.0
	particles.gravity = Vector2(0.0, 160.0)
	particles.initial_velocity_min = 25.0
	particles.initial_velocity_max = 60.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 3.5
	particles.color = Color(0.45, 0.65, 0.42, 0.8)
	particles.emitting = true
	get_tree().create_timer(0.45).timeout.connect(particles.queue_free)
