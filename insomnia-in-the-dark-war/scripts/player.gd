extends CharacterBody2D

@export var speed: float = 150.0

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1.0
	if Input.is_action_pressed("ui_down"):
		direction.y += 1.0
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		direction.x += 1.0

	if direction != Vector2.ZERO:
		direction = direction.normalized()

	var effective_speed: float = speed * (0.85 if (GameState and GameState.is_tired) else 1.0)
	velocity = direction * effective_speed
	move_and_slide()

func _ready() -> void:
	add_to_group("player")
