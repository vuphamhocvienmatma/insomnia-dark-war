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

	ladder_prompt = Label.new()
	ladder_prompt.visible = false
	ladder_prompt.add_theme_font_size_override("font_size", 11)
	ladder_prompt.add_theme_color_override("font_color", Color(0.98, 0.88, 0.58, 1.0))
	ladder_prompt.offset_left = -70.0
	ladder_prompt.offset_top = -58.0
	ladder_prompt.offset_right = 70.0
	ladder_prompt.offset_bottom = -38.0
	ladder_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(ladder_prompt)


var ladder_prompt: Label


func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		direction.x += 1.0

	if direction != Vector2.ZERO:
		direction = direction.normalized()

	# Ladder interaction only triggered by pressing E when near the ladder (x = 150)
	var near_ladder: bool = absf(position.x - 150.0) < 22.0
	if ladder_prompt != null:
		if near_ladder and not _climbing:
			ladder_prompt.visible = true
			if cabin != null and cabin.current_floor == "mezzanine":
				ladder_prompt.text = "🪜 [E] Leo xuống tầng 1"
			else:
				ladder_prompt.text = "🪜 [E] Leo lên gác xép"
		else:
			ladder_prompt.visible = false

	if near_ladder and not _climbing and Input.is_action_just_pressed("interact"):
		if cabin != null:
			if cabin.current_floor == "ground":
				cabin.climb_up()
			else:
				cabin.climb_down()

	var effective_speed: float = speed * (0.85 if (GameState and GameState.is_tired) else 1.0)
	velocity = Vector2(direction.x * effective_speed, 0.0)

	if art and direction.x != 0.0:
		art.scale.x = -1.0 if direction.x < 0.0 else 1.0

	move_and_slide()

	# Clamp movement bounds: On mezzanine cannot walk into air; on ground cannot leave map
	if cabin != null and cabin.current_floor == "mezzanine":
		position.x = clampf(position.x, -180.0, 180.0)
	else:
		position.x = clampf(position.x, -1600.0, 1600.0)

	if not _climbing:
		position.y = cabin.get_current_floor_y() if cabin != null else GROUND_Y


func _on_floor_changed(_floor_name: String) -> void:
	if cabin == null:
		return
	_climbing = true
	# Center on ladder while climbing
	position.x = 150.0
	velocity = Vector2.ZERO
	if art != null and art.has_method("set_climbing"):
		art.call("set_climbing", true)

	var target_y: float = cabin.get_current_floor_y()
	var tw: Tween = create_tween()
	tw.tween_property(self, "position:y", target_y, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(func() -> void:
		_climbing = false
		if art != null and art.has_method("set_climbing"):
			art.call("set_climbing", false)
	)
