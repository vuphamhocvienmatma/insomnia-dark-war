extends Node2D

enum PotState { EMPTY, PLANTED, BLOOMED }

@export var growth_time: float = 30.0

var current_state: PotState = PotState.EMPTY
var growth_timer: float = 0.0
var growth_progress: float = 0.0

@onready var art_node: Node2D = $Art

func _ready() -> void:
	add_to_group("plant_pot")
	art_node.set_state("empty")

func _process(delta: float) -> void:
	if current_state == PotState.PLANTED:
		growth_timer += delta
		growth_progress = growth_timer / growth_time
		art_node.queue_redraw()
		if growth_timer >= growth_time:
			current_state = PotState.BLOOMED
			growth_progress = 1.0
			art_node.set_state("bloomed")
			print("Cây đã nở hoa! Đến thu hoạch thôi.")
	elif current_state == PotState.EMPTY:
		growth_progress = 0.0
	elif current_state == PotState.BLOOMED:
		growth_progress = 1.0

func plant_seed() -> bool:
	if current_state != PotState.EMPTY:
		return false
	if GameState.spend_seeds(1) == false:
		print("Không có hạt giống để trồng.")
		return false
	current_state = PotState.PLANTED
	growth_timer = 0.0
	art_node.set_state("planted")
	var am := get_tree().get_first_node_in_group("audio_manager")
	if am != null:
		am.call("play_sfx", "plant")
	_spawn_burst(5, Color(0.3, 0.8, 0.3, 1.0))
	print("Đã trồng hạt giống, chờ nở...")
	return true

func harvest() -> bool:
	if current_state != PotState.BLOOMED:
		return false
	var reward: int = 2 + GameState.plant_harvest_bonus
	GameState.add_scrap(reward)
	current_state = PotState.EMPTY
	art_node.set_state("empty")
	var am := get_tree().get_first_node_in_group("audio_manager")
	if am != null:
		am.call("play_sfx", "harvest")
	_spawn_burst(10, Color(1.0, 0.85, 0.2, 1.0))
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

func _spawn_burst(count: int, col: Color) -> void:
	var particles := GPUParticles2D.new()
	var parent := get_parent()
	if parent != null:
		parent.add_child(particles)
	else:
		add_child(particles)
	particles.global_position = global_position
	particles.amount = count
	particles.lifetime = 0.5
	particles.one_shot = true
	var mat := ParticleProcessMaterial.new()
	mat.color = col
	mat.gravity = Vector3(0.0, 50.0, 0.0)
	mat.scale_min = 0.0
	mat.scale_max = 0.3
	particles.process_material = mat
	particles.emitting = true
	get_tree().create_timer(0.6).timeout.connect(particles.queue_free)
