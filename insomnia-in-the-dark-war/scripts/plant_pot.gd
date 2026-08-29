extends Node2D

enum PotState { EMPTY, PLANTED, BLOOMED }

@export var growth_time: float = 30.0

var current_state: PotState = PotState.EMPTY
var growth_timer: float = 0.0

@onready var art_node: Node2D = $Art

func _ready() -> void:
	add_to_group("plant_pot")
	art_node.set_state("empty")

func _process(delta: float) -> void:
	if current_state == PotState.PLANTED:
		growth_timer += delta
		if growth_timer >= growth_time:
			current_state = PotState.BLOOMED
			art_node.set_state("bloomed")
			print("Cây đã nở hoa! Đến thu hoạch thôi.")

func plant_seed() -> bool:
	if current_state != PotState.EMPTY:
		return false
	if GameState.spend_seeds(1) == false:
		print("Không có hạt giống để trồng.")
		return false
	current_state = PotState.PLANTED
	growth_timer = 0.0
	art_node.set_state("planted")
	print("Đã trồng hạt giống, chờ nở...")
	return true

func harvest() -> bool:
	if current_state != PotState.BLOOMED:
		return false
	var reward: int = 2 + GameState.plant_harvest_bonus
	GameState.add_scrap(reward)
	current_state = PotState.EMPTY
	art_node.set_state("empty")
	print("Thu hoạch hoa, nhận ", reward, " phế liệu! Thật chill...")
	return true

func water_plant() -> bool:
	if current_state == PotState.PLANTED:
		if GameState.spend_water(1):
			growth_time = max(5.0, growth_time * 0.5)
			print("Tưới nước! Cây lớn nhanh hơn.")
			return true
	return false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var player := get_tree().get_first_node_in_group("player") as Node2D
		if player and global_position.distance_to(player.global_position) < 60.0:
			if current_state == PotState.BLOOMED:
				harvest()
			elif current_state == PotState.EMPTY:
				plant_seed()
			elif current_state == PotState.PLANTED:
				water_plant()
