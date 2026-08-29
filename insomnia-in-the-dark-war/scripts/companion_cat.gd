extends CharacterBody2D

const GROUND_Y: float = 0.0

@export var follow_speed: float = 120.0
@export var loot_radius: float = 150.0
@export var loot_cooldown: float = 8.0

var target_player: Node2D = null
var is_carrying_item: bool = false
var carried_item_node: Node2D = null
var next_loot_time: float = 0.0
var is_being_pet: bool = false
var pet_happiness: float = 0.0

func _ready() -> void:
	add_to_group("companion_cat")
	position.y = GROUND_Y

func _physics_process(_delta: float) -> void:
	position.y = GROUND_Y

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
		_seek_x(target_player.global_position.x, 40.0)
		if abs(target_player.global_position.x - global_position.x) < 40.0:
			_deliver_item()
		return

	var nearest := _find_nearest_scrap()
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

func _seek_x(target_x: float, stop_dist: float) -> void:
	var diff := target_x - global_position.x
	if abs(diff) > stop_dist:
		velocity = Vector2(sign(diff) * follow_speed, 0.0)
	else:
		velocity = Vector2.ZERO
	var art := get_node_or_null("Art") as Node2D
	if art and velocity.x != 0.0:
		art.scale.x = -1.0 if velocity.x < 0.0 else 1.0
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
		
	# Lấy item_type an toàn (chỉ truyền 1 tham số vào hàm get)
	var item_type: String = str(carried_item_node.get("item_type")) if "item_type" in carried_item_node else "scrap"
	
	match item_type:
		"scrap":
			GameState.add_scrap(1)
		"seed":
			GameState.add_seeds(1)
			JournalManager.track_progress("seed")
		"water":
			GameState.add_water(1)
	
	print("Mèo mang về 1 ", item_type, "!")
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
