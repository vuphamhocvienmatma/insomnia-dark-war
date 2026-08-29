extends CharacterBody2D

const GROUND_Y: float = 0.0

@export var speed: float = 150.0

func _ready() -> void:
	add_to_group("player")
	position.y = GROUND_Y

func _physics_process(_delta: float) -> void:
	position.y = GROUND_Y

	var direction: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		direction.x += 1.0

	if direction != Vector2.ZERO:
		direction = direction.normalized()

	var effective_speed: float = speed * (0.85 if (GameState and GameState.is_tired) else 1.0)
	velocity = Vector2(direction.x * effective_speed, 0.0)

	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite and direction.x != 0.0:
		sprite.flip_h = direction.x < 0.0

	move_and_slide()
	position.y = GROUND_Y
