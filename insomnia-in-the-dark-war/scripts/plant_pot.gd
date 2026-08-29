extends Area2D

enum PotState { EMPTY, SEEDED, SPROUT, BLOOMED }

var current_state: PotState = PotState.EMPTY
var player_inside: bool = false

func _ready() -> void:
	add_to_group("plant_pot")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_inside:
		if current_state == PotState.EMPTY and GameState.spend_seeds(1) == true:
			current_state = PotState.SEEDED
			$Sprite2D.modulate = Color("8d6e63")
			print("Đã gieo hạt mầm hy vọng...")
		elif (current_state == PotState.SEEDED or current_state == PotState.SPROUT) and GameState.spend_water(1) == true:
			if current_state == PotState.SEEDED:
				current_state = PotState.SPROUT
				$Sprite2D.modulate = Color("aed581")
			elif current_state == PotState.SPROUT:
				current_state = PotState.BLOOMED
				$Sprite2D.modulate = Color("f48fb1")
			print("Tưới nước... cây đang lớn!")
		elif current_state == PotState.BLOOMED:
			GameState.add_scrap(2)
			current_state = PotState.EMPTY
			$Sprite2D.modulate = Color.WHITE
			print("Thu hoạch hoa, nhận 2 phế liệu! Thật chill...")
