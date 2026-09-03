extends CanvasLayer

const RECIPES: Array[Dictionary] = [
	{"id": "meal", "name": "Bữa ăn ấm bụng (2 hạt + 1 nước)", "cost_seeds": 2, "cost_water": 1},
	{"id": "battery", "name": "Pin mặt trời dự phòng (3 phế liệu)", "cost_scrap": 3},
	{"id": "cat_toy", "name": "Đồ chơi cho mèo (2 phế liệu + 1 hạt)", "cost_scrap": 2, "cost_seeds": 1}
]

var panel: Panel
var buttons: Array[Button] = []
var cat_toy_done: bool = false
var craft_sound: AudioStreamPlayer


func _ready() -> void:
	panel = $Panel
	panel.visible = false
	var vbox: VBoxContainer = $Panel/VBoxContainer
	for r in RECIPES:
		var btn: Button = Button.new()
		btn.text = r["name"]
		btn.pressed.connect(_craft_i.bind(RECIPES.find(r)))
		vbox.add_child(btn)
		buttons.append(btn)
	var close_btn: Button = Button.new()
	close_btn.text = "Đóng [C]"
	close_btn.pressed.connect(_close)
	vbox.add_child(close_btn)
	GameState.scrap_changed.connect(_on_resource_changed)
	GameState.seeds_changed.connect(_on_resource_changed)
	GameState.water_changed.connect(_on_resource_changed)
	craft_sound = AudioStreamPlayer.new()
	add_child(craft_sound)
	if ResourceLoader.exists("res://assets/sfx/craft_success.ogg"):
		var sfx: AudioStream = load("res://assets/sfx/craft_success.ogg") as AudioStream
		if sfx != null:
			craft_sound.stream = sfx


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_crafting"):
		panel.visible = !panel.visible
		if panel.visible:
			_refresh()


func can_afford(r: Dictionary) -> bool:
	if GameState.scrap_count < int(r.get("cost_scrap", 0)):
		return false
	if GameState.seeds_count < int(r.get("cost_seeds", 0)):
		return false
	if GameState.water_count < int(r.get("cost_water", 0)):
		return false
	return true


func spend(r: Dictionary) -> void:
	if int(r.get("cost_scrap", 0)) > 0:
		GameState.spend_scrap(int(r.get("cost_scrap", 0)))
	if int(r.get("cost_seeds", 0)) > 0:
		GameState.spend_seeds(int(r.get("cost_seeds", 0)))
	if int(r.get("cost_water", 0)) > 0:
		GameState.spend_water(int(r.get("cost_water", 0)))


func _refresh() -> void:
	for i in range(buttons.size()):
		var r: Dictionary = RECIPES[i]
		var blocked: bool = not can_afford(r)
		if r["id"] == "cat_toy" and cat_toy_done:
			blocked = true
		buttons[i].disabled = blocked


func _on_resource_changed(_value: int) -> void:
	if panel.visible:
		_refresh()


func _close() -> void:
	panel.visible = false


func _craft_i(i: int) -> void:
	_craft(i)


func _craft(i: int) -> void:
	var r: Dictionary = RECIPES[i]
	if not can_afford(r):
		return
	spend(r)
	match r["id"]:
		"meal":
			if GameState.is_tired:
				GameState.is_tired = false
				GameState.tired_changed.emit(false)
				print("Ăn xong ấm bụng, hết mệt!")
			else:
				GameState.meal_buff = true
				print("Cất dành bữa ăn cho tối nay.")
		"battery":
			var tm := get_tree().get_first_node_in_group("time_manager")
			if tm != null:
				var cur: float = float(tm.get("max_solar_storage"))
				tm.set("max_solar_storage", cur + 25.0)
				print("Max solar +25!")
		"cat_toy":
			var cat := get_tree().get_first_node_in_group("companion_cat")
			if cat != null:
				cat.set("loot_cooldown", 4.0)
				cat_toy_done = true
				print("Mèo có đồ chơi, chăm nhặt hơn!")
	_spawn_craft_fx(i)
	_refresh()


func _spawn_craft_fx(i: int) -> void:
	var btn: Button = buttons[i]
	var particles := GPUParticles2D.new()
	particles.global_position = btn.global_position
	add_child(particles)
	particles.amount = 20
	particles.lifetime = 0.8
	particles.one_shot = true
	var mat := ParticleProcessMaterial.new()
	mat.color = Color(1.0, 1.0, 0.0, 1.0)
	mat.gravity = Vector3(0.0, 100.0, 0.0)
	mat.direction = Vector3(0.0, -1.0, 0.0)
	mat.spread = 45.0
	mat.initial_velocity_min = 30.0
	mat.initial_velocity_max = 80.0
	mat.scale_min = 0.0
	mat.scale_max = 0.5
	particles.process_material = mat
	particles.emitting = true
	btn.modulate = Color(1.0, 1.0, 0.5, 1.0)
	var tw := create_tween()
	tw.tween_property(btn, "modulate", Color.WHITE, 0.2)
	if craft_sound != null and craft_sound.stream != null:
		craft_sound.play()
	await get_tree().create_timer(1.0).timeout
	particles.queue_free()
