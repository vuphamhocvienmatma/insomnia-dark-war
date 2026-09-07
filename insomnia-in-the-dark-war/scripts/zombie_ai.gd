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
var is_dead: bool = false

@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer

var is_attacking: bool = false
var current_target_fence: Node2D = null
var _footprint_timer: float = 0.0
var _groan_timer: float = randf_range(2.0, 5.0)
var _audio_timer: float = 0.0
var safe_zone: Area2D = null
var _art_node: Node2D = null
var _hud: Node = null


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

	_hud = get_tree().get_first_node_in_group("hud")
	var sz := get_tree().get_first_node_in_group("safe_zone")
	if sz != null:
		safe_zone = sz as Area2D
	position.y = GROUND_Y
	spawn_position = global_position
	attack_timer.wait_time = attack_cooldown
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)


func _process(delta: float) -> void:
	if is_dead: return

	# Groan / ambient zombie sound
	_groan_timer -= delta
	if _groan_timer <= 0.0:
		_groan_timer = randf_range(3.0, 7.0)
		if has_node("/root/AudioDirector"):
			match zombie_type:
				"runner":
					AudioDirector.play_sfx_positional("zombie_runner", global_position)
				"brute":
					AudioDirector.play_sfx_positional("zombie_brute", global_position)
				"thief":
					AudioDirector.play_sfx_positional("zombie_thief", global_position)
				_:
					AudioDirector.play_sfx_positional("zombie_groan_normal", global_position)

	# Footstep sounds while moving
	if velocity.length() > 1.0:
		_footprint_timer -= delta
		if _footprint_timer <= 0.0:
			var step_interval = 0.35 / max(speed / 30.0, 0.5)
			_footprint_timer = step_interval
			if has_node("/root/AudioDirector"):
				AudioDirector.play_sfx_positional("footstep", global_position)

func _physics_process(_delta: float) -> void:

	queue_redraw()
	if is_dead: return
	
	position.y = GROUND_Y

	if safe_zone != null and is_instance_valid(safe_zone):
		var dist_to_safe: float = global_position.distance_to(safe_zone.global_position)
		if dist_to_safe < SAFE_RADIUS:
			var away: Vector2 = global_position - safe_zone.global_position
			if away.length() < 1.0:
				away = Vector2(signf(spawn_position.x), 0.0)
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
		var dir: float = -signf(global_position.x)
		velocity = Vector2(dir * speed, 0.0)
		if _art_node != null:
			_art_node.scale.x = -1.0 if global_position.x > 0.0 else 1.0
		move_and_slide()
	else:
		var side: float = signf(global_position.x)
		var has_gap: bool = false
		for socket in get_tree().get_nodes_in_group("critical_socket"):
			if socket is BuildSocket2D and not socket.is_occupied:
				if signf(socket.global_position.x) == side:
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
						if _hud != null and _hud.has_method("show_toast"):
							_hud.call("show_toast", "⚠️ Tên trộm Thief đã cuỗm " + str(stolen_scrap) + " phế liệu!", 3.0, true)
				else:
					if GameState.spend_scrap(1):
						pass
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
	var dir: float = signf(spawn_position.x)
	velocity = Vector2(dir * speed, 0.0)
	if _art_node != null:
		_art_node.scale.x = -1.0 if dir < 0.0 else 1.0
	move_and_slide()
	if abs(global_position.x - spawn_position.x) < 35.0:
		queue_free()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if is_dead: return
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
	if is_dead: return
	if current_target_fence and is_instance_valid(current_target_fence):
		current_target_fence.call("take_damage", attack_damage)
		var cam: Node = get_tree().get_first_node_in_group("main_camera")
		if cam != null and cam.has_method("trigger_shake"):
			var shake_pwr: float = 14.0 if zombie_type == "brute" else 6.0
			cam.call("trigger_shake", shake_pwr)
		
		var ground = get_tree().get_first_node_in_group("ground_props")
		if ground and ground.has_method("add_decal"):
			ground.call("add_decal", "scratch", global_position + Vector2(randf_range(-10, 10), 0))
	else:
		is_attacking = false
		attack_timer.stop()

func take_damage(amount: float) -> void:
	if is_dead: return
	current_health -= amount
	if current_health <= 0.0:
		is_dead = true
		set_physics_process(false)
		attack_area.set_deferred("monitoring", false)
		
		_spawn_death_fx()
		if stolen_scrap > 0:
			GameState.add_scrap(stolen_scrap)
			if _hud != null and _hud.has_method("show_toast"):
				_hud.call("show_toast", "🎉 Đã hạ gục tên trộm! Thu hồi +" + str(stolen_scrap) + " phế liệu!", 3.0, false)

		var ls: Node = get_tree().root.find_child("LevelSetup", true, false)
		if ls != null and str(ls.get("current_night_mutation")) == "scrap_jackpot":
			GameState.add_scrap(1) 

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
	particles.lifetime = 1.2
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.direction = Vector2(0, -1)
	particles.spread = 60.0
	particles.gravity = Vector2(25.0, -15.0)
	particles.initial_velocity_min = 10.0
	particles.initial_velocity_max = 20.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 3.5
	particles.color = Color(0.05, 0.05, 0.05, 0.75)
	particles.emitting = true
	get_tree().create_timer(0.45).timeout.connect(particles.queue_free)


func _draw() -> void:
	var eco = false
	if GameState != null and GameState.eco_mode: eco = true
	
	if not eco:
		var tm = get_tree().get_first_node_in_group("time_manager")
		if tm != null:
			var is_night = bool(tm.get("is_night"))
			var sun_ang = tm.get("sun_angle")
			var sh_int = float(tm.get("shadow_intensity"))
			if sh_int > 0.05:
				var sh_col = Color(0, 0, 0, 0.4 * sh_int)
				if is_night: sh_col = Color(0.1, 0.1, 0.3, 0.5 * sh_int)
				
				# Directional shadow
				var h = 30.0
				var w = 16.0
				var dx = sun_ang.x * h
				var pts = PackedVector2Array([
					Vector2(-w/2, 0),
					Vector2(w/2, 0),
					Vector2(w/2 + dx, -h * 0.3),
					Vector2(-w/2 + dx, -h * 0.3)
				])
				draw_colored_polygon(pts, sh_col)
				
				# Contact shadow
				draw_circle(Vector2(0, 0), w/1.5, Color(0,0,0,0.5))
