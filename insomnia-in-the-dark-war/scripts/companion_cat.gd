extends CharacterBody2D

@export var follow_speed: float = 120.0
@export var loot_radius: float = 150.0
@export var loot_cooldown: float = 8.0

var target_player: Node2D = null
var is_carrying_item: bool = false
var carried_item_node: Node2D = null
var next_loot_time: float = 0.0
var is_being_pet: bool = false
var pet_happiness: float = 0.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	add_to_group("companion_cat")

func _physics_process(_delta: float) -> void:
	if target_player == null or not is_instance_valid(target_player):
		target_player = get_tree().get_first_node_in_group("player")
	if target_player == null:
		return

	if is_being_pet:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var now := Time.get_ticks_msec() / 1000.0

	if is_carrying_item:
		if not is_instance_valid(carried_item_node):
			is_carrying_item = false
			return
		navigation_agent.target_position = target_player.global_position
		if global_position.distance_to(target_player.global_position) < 40.0:
			_deliver_item()
	else:
		navigation_agent.target_position = target_player.global_position + Vector2(40.0, 40.0)
		if now > next_loot_time:
			var nearest := _find_nearest_scrap()
			if nearest != null:
				navigation_agent.target_position = nearest.global_position
				if global_position.distance_to(nearest.global_position) < 20.0:
					carried_item_node = nearest
					is_carrying_item = true
					next_loot_time = now + loot_cooldown
					nearest.get_parent().remove_child(nearest)
					add_child(nearest)
					nearest.position = Vector2.ZERO
					nearest.set_process(false)
					nearest.set("player_inside", false)

	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_pos := navigation_agent.get_next_path_position()
		var dir := global_position.direction_to(next_pos)
		velocity = dir * follow_speed
	move_and_slide()

func _find_nearest_scrap() -> Node2D:
	var best: Node2D = null
	var best_dist := loot_radius
	for scrap in get_tree().get_nodes_in_group("scrap"):
		if not is_instance_valid(scrap):
			continue
		var d := global_position.distance_to(scrap.global_position)
		if d < best_dist:
			best_dist = d
			best = scrap
	return best

func _deliver_item() -> void:
	if carried_item_node == null or not is_instance_valid(carried_item_node):
		is_carrying_item = false
		return
	match carried_item_node.item_type:
		"scrap":
			GameState.add_scrap(1)
		"seed":
			GameState.add_seeds(1)
			JournalManager.track_progress("seed")
		"water":
			GameState.add_water(1)
	print("Mèo mang về 1 ", carried_item_node.item_type, "!")
	carried_item_node.queue_free()
	carried_item_node = null
	is_carrying_item = false

func _unhandled_input(event: InputEvent) -> void:
	if target_player != null and is_instance_valid(target_player):
		if event.is_action_pressed("interact") and global_position.distance_to(target_player.global_position) < 40.0:
			is_being_pet = true
			pet_happiness = min(pet_happiness + 10.0, 100.0)
			print("Vuốt ve mèo... purrr... Mood: ", pet_happiness)
			modulate = Color("ffcc80")
			_finish_pet_after_delay()

func _finish_pet_after_delay() -> void:
	await get_tree().create_timer(2.0).timeout
	is_being_pet = false
	modulate = Color.WHITE
