extends CharacterBody2D

const GROUND_Y: float = 0.0

@export var follow_speed: float = 120.0
@export var loot_radius: float = 150.0
@export var loot_cooldown: float = 8.0

@onready var cabin: Node2D = get_tree().get_first_node_in_group("cabin_structure")
var _cat_floor: String = "ground"
var _cat_climbing: bool = false
var _idle_time: float = 0.0

var target_player: Node2D = null
var is_carrying_item: bool = false
var carried_item_node: Node2D = null
var next_loot_time: float = 0.0
var is_being_pet: bool = false
var pet_happiness: float = 0.0
var lucky_loot: bool = false

func _ready() -> void:
	add_to_group("companion_cat")
	position.y = GROUND_Y
	if cabin == null:
		cabin = get_node_or_null("../CabinStructure") as Node2D
	target_player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if cabin != null and not _cat_climbing:
		position.y = cabin.get_current_floor_y()
	elif cabin == null:
		position.y = GROUND_Y

	if target_player == null or not is_instance_valid(target_player):
		return

	if is_being_pet:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var now := Time.get_ticks_msec() / 1000.0

	var ls: Node = get_tree().root.find_child("LevelSetup", true, false)
	var is_sunny = (ls and str(ls.get("current_weather")) == "sunny")
	if ls != null and str(ls.get("current_weather")) == "sandstorm":
		# Stay inside cabin near stove keeping warm during sandstorm
		_seek_x(-60.0, 15.0)
		return
	elif is_sunny:
		# Seek the god rays in the cabin (x: 120)
		_seek_x(120.0, 10.0)
		return

	if is_carrying_item:
		if not is_instance_valid(carried_item_node):
			is_carrying_item = false
			return
		_seek_x(target_player.global_position.x, 40.0)
		if abs(target_player.global_position.x - global_position.x) < 40.0:
			_deliver_item()
		return

	var nearest: Node2D = _find_nearest_scrap()
	if now > next_loot_time and nearest != null:
		_seek_x(nearest.global_position.x, 20.0)
		if abs(nearest.global_position.x - global_position.x) < 20.0:
			carried_item_node = nearest
			is_carrying_item = true
			next_loot_time = now + loot_cooldown
			nearest.get_parent().remove_child(nearest)
			add_child(nearest)
			nearest.position = Vector2.ZERO
			nearest.set_process(false)
			nearest.set("player_inside", false)
	else:
		_seek_x(target_player.global_position.x, 40.0)

	_update_idle_art(_delta)

func _update_idle_art(delta: float) -> void:
	var art: Node2D = get_node_or_null("Art") as Node2D
	if art == null:
		return
	if abs(velocity.x) < 1.0 and not _cat_climbing:
		_idle_time += delta
		art.position.y = sin(_idle_time * 2.0) * 1.5
	else:
		_idle_time = 0.0
		art.position.y = lerpf(art.position.y, 0.0, 8.0 * delta)

func _seek_x(target_x: float, stop_dist: float) -> void:
	# If player is on a different floor, cat goes to ladder at 150.0 to follow
	if cabin != null and cabin.current_floor != _cat_floor:
		target_x = 150.0
		if abs(global_position.x - 150.0) < 12.0 and not _cat_climbing:
			_cat_floor = cabin.current_floor
			_start_cat_climb()

	var diff: float = target_x - global_position.x
	if abs(diff) > stop_dist:
		velocity = Vector2(sign(diff) * follow_speed, 0.0)
	else:
		velocity = Vector2.ZERO
	var art: Node2D = get_node_or_null("Art") as Node2D
	if art and velocity.x != 0.0:
		art.scale.x = -1.0 if velocity.x < 0.0 else 1.0
	move_and_slide()
	if cabin != null and cabin.current_floor == "mezzanine":
		position.x = clampf(position.x, -180.0, 180.0)
	else:
		position.x = clampf(position.x, -1580.0, 1580.0)

func _start_cat_climb() -> void:
	if cabin == null:
		return
	_cat_climbing = true
	var target_y: float = cabin.get_current_floor_y()
	var tw := create_tween()
	tw.tween_property(self, "position:y", target_y, 0.3)
	tw.tween_callback(func() -> void: _cat_climbing = false)

func _find_nearest_scrap() -> Node2D:
	var best: Node2D = null
	var best_dist: float = loot_radius
	for scrap in get_tree().get_nodes_in_group("scrap"):
		if not is_instance_valid(scrap):
			continue
		var d: float = global_position.distance_to(scrap.global_position)
		if d < best_dist:
			best_dist = d
			best = scrap
	return best

func _deliver_item() -> void:
	if carried_item_node == null or not is_instance_valid(carried_item_node):
		is_carrying_item = false
		return

	var item_type: String = str(carried_item_node.get("item_type")) if "item_type" in carried_item_node else "scrap"
	var amount: int = 2 if lucky_loot else 1

	match item_type:
		"scrap":
			GameState.add_scrap(amount)
		"seed":
			GameState.add_seeds(amount)
			JournalManager.track_progress("seed")
		"water":
			GameState.add_water(amount)

	print("Mèo mang về ", amount, " ", item_type, "!")
	carried_item_node.queue_free()
	carried_item_node = null
	is_carrying_item = false

func _unhandled_input(event: InputEvent) -> void:
	if target_player != null and is_instance_valid(target_player):
		if event.is_action_pressed("interact") and global_position.distance_to(target_player.global_position) < 40.0:
			is_being_pet = true
			pet_happiness = min(pet_happiness + 10.0, 100.0)
			print("Vuốt ve mèo... purrr... Mood: ", pet_happiness)
			modulate = Color(1.0, 0.8, 0.5, 1.0)
			_finish_pet_after_delay()

func _finish_pet_after_delay() -> void:
	await get_tree().create_timer(2.0).timeout
	is_being_pet = false
	modulate = Color.WHITE
