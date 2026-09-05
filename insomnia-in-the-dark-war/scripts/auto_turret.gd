extends Area2D

var current_target: CharacterBody2D = null
var targets_in_range: Array[CharacterBody2D] = []

@export var attack_damage: float = 10.0
@export var solar_cost_per_shot: float = 5.0

func _ready() -> void:
	add_to_group("auto_turret")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$FireRateTimer.timeout.connect(_on_fire_rate_timer_timeout)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("zombie"):
		var z = body as CharacterBody2D
		if z not in targets_in_range:
			targets_in_range.append(z)
		_pick_target()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("zombie"):
		var z = body as CharacterBody2D
		if z in targets_in_range:
			targets_in_range.erase(z)
		if z == current_target:
			current_target = null
			_pick_target()

func _pick_target() -> void:
	if current_target != null and is_instance_valid(current_target) and current_target.get("current_health") > 0.0:
		return
	current_target = null
	
	# Clean up dead ones
	var i = targets_in_range.size() - 1
	while i >= 0:
		if not is_instance_valid(targets_in_range[i]) or targets_in_range[i].get("current_health") <= 0.0:
			targets_in_range.remove_at(i)
		i -= 1
		
	if not targets_in_range.is_empty():
		current_target = targets_in_range[0]

func _on_fire_rate_timer_timeout() -> void:
	_pick_target()
	if current_target == null: return

	var tm = get_tree().get_first_node_in_group("time_manager")
	if tm == null or tm.is_night == false:
		return

	if tm.spend_solar(solar_cost_per_shot):
		var final_damage: float = attack_damage * (GameState.turret_damage_multiplier if GameState else 1.0)
		if GameState != null and GameState.relics_found.has("night_vision_relic"):
			final_damage *= 1.25
			
		current_target.call("take_damage", final_damage)
		
		var line := Line2D.new()
		line.add_point(Vector2.ZERO)
		line.add_point(current_target.global_position - global_position)
		line.width = 3.0
		line.default_color = Color(1.0, 0.5, 0.0, 0.8)
		add_child(line)
		get_tree().create_timer(0.1).timeout.connect(line.queue_free)
		
		var art_node: Node = get_node_or_null("Art")
		if art_node != null and art_node.has_method("trigger_muzzle_flash"):
			art_node.call("trigger_muzzle_flash")
			
		var am := get_tree().get_first_node_in_group("audio_manager")
		if am != null and am.has_method("play_sfx"):
			am.call("play_sfx", "turret_shoot")