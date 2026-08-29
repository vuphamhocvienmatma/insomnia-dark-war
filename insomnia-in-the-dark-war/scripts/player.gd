extends CharacterBody2D

const GROUND_Y: float = 0.0

@export var speed: float = 150.0

@onready var cabin: Node2D = get_tree().get_first_node_in_group("cabin_structure")
@onready var art: Node2D = $Art

var _climbing: bool = false


func _ready() -> void:
	add_to_group("player")
	position.y = GROUND_Y
	if cabin == null:
		cabin = get_node_or_null("../CabinStructure") as Node2D
	if cabin != null:
		cabin.floor_changed.connect(_on_floor_changed)


func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		direction.x += 1.0

	if direction != Vector2.ZERO:
		direction = direction.normalized()

	if cabin != null and Input.is_action_just_pressed("ui_up"):
		if cabin.can_climb_up(global_position.x):
			cabin.climb_up()
	if cabin != null and Input.is_action_just_pressed("ui_down"):
		if cabin.can_climb_down(global_position.x):
			cabin.climb_down()

	var effective_speed: float = speed * (0.85 if (GameState and GameState.is_tired) else 1.0)
	velocity = Vector2(direction.x * effective_speed, 0.0)

	if art and direction.x != 0.0:
		art.scale.x = -1.0 if direction.x < 0.0 else 1.0

	move_and_slide()

	if not _climbing:
		position.y = cabin.get_current_floor_y() if cabin != null else GROUND_Y


func _on_floor_changed(_floor_name: String) -> void:
	if cabin == null:
		return
	_climbing = true
	var target_y: float = cabin.get_current_floor_y()
	var tw := create_tween()
	tw.tween_property(self, "position:y", target_y, 0.3)
	tw.tween_callback(func() -> void: _climbing = false)
