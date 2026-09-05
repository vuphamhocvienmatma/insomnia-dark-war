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

	# Climb logic here
	var effective_speed: float = speed * (0.85 if (GameState and GameState.is_tired) else 1.0)
	velocity = Vector2(direction.x * effective_speed, 0.0)

	if art and direction.x != 0.0:
		art.scale.x = -1.0 if direction.x < 0.0 else 1.0

	position.x = clampf(position.x, -3150.0, 3150.0)
	move_and_slide()
	
	_handle_footsteps(direction.x, _delta)
	_handle_cold_breath(_delta)

	# Clamp movement bounds: On mezzanine cannot walk into air; on ground cannot leave map
	if cabin != null and cabin.current_floor == "mezzanine":
		position.x = clampf(position.x, -180.0, 180.0)
	else:
		position.x = clampf(position.x, -1600.0, 1600.0)

	if not _climbing:
		position.y = cabin.get_current_floor_y() if cabin != null else GROUND_Y

var _step_timer: float = 0.0
var _breath_timer: float = 0.0

func _handle_footsteps(dir_x: float, delta: float) -> void:
	if dir_x == 0.0 or _climbing:
		_step_timer = 0.0
		return
	
	_step_timer += delta
	if _step_timer >= 0.4:
		_step_timer = 0.0
		var sound_text = "sột soạt"
		var w = "sunny"
		if get_node_or_null("/root/LevelSetup"):
			w = get_node("/root/LevelSetup").get("current_weather")
		
		# In cabin
		if position.x > -180.0 and position.x < 180.0:
			sound_text = "cộp cộp"
		elif w == "snowstorm":
			sound_text = "xộp xộp"
		elif w == "heavy_rain" or w == "drizzle":
			sound_text = "lép nhép"
			
		_spawn_floating_text(sound_text, Color(0.8, 0.8, 0.8, 0.6))

func _handle_cold_breath(delta: float) -> void:
	var w = "sunny"
	if get_node_or_null("/root/LevelSetup"):
		w = get_node("/root/LevelSetup").get("current_weather")
		
	if w == "snowstorm" or w == "thick_fog":
		_breath_timer += delta
		if _breath_timer >= 2.5:
			_breath_timer = 0.0
			_spawn_cold_breath()

func _spawn_cold_breath() -> void:
	var puff = Label.new()
	puff.text = "☁️"
	puff.add_theme_font_size_override("font_size", 10)
	puff.modulate = Color(1,1,1,0.5)
	var offset_x = 20.0 * (1.0 if (art and art.scale.x > 0) else -1.0)
	puff.position = Vector2(offset_x, -30)
	add_child(puff)
	
	var tw = create_tween()
	tw.tween_property(puff, "position:y", -50.0, 1.5)
	tw.parallel().tween_property(puff, "modulate:a", 0.0, 1.5)
	tw.tween_callback(puff.queue_free)

func _spawn_floating_text(txt: String, col: Color) -> void:
	var lbl = Label.new()
	lbl.text = txt
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.position = Vector2(-20, 0)
	add_child(lbl)
	
	var tw = create_tween()
	tw.tween_property(lbl, "position:y", -20.0, 0.5)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.5)
	tw.tween_callback(lbl.queue_free)




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
