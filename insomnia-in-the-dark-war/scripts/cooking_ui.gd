extends Control

signal dish_cooked(buff_name: String)

@onready var close_btn: Button = $Panel/CloseButton
@onready var dish_container: VBoxContainer = $Panel/DishContainer
@onready var ingredients_lbl: Label = $Panel/IngredientsHeader

var active_buff: String = ""


func _ready() -> void:
	visible = false
	if close_btn != null:
		close_btn.pressed.connect(close_menu)


func open_menu() -> void:
	visible = true
	_refresh_dishes()


func close_menu() -> void:
	visible = false


func _refresh_dishes() -> void:
	if ingredients_lbl != null and GameState != null:
		ingredients_lbl.text = "🌾 Hạt giống: " + str(GameState.seeds_count) + " | 💧 Nước: " + str(GameState.water_count) + " | 🔩 Phế liệu: " + str(GameState.scrap_count)

	if dish_container == null:
		return

	for child in dish_container.get_children():
		child.queue_free()

	var recipes: Array[Dictionary] = [
		{
			"id": "speed",
			"name": "🍲 Canh Măng Sa Mạc",
			"cost": {"seeds": 1, "water": 1},
			"desc": "Tăng +25% tốc độ di chuyển cả ngày",
			"buff_txt": "Tốc Độ +25%"
		},
		{
			"id": "solar",
			"name": "🍵 Trà Hoa Cúc Mật Ong",
			"cost": {"seeds": 1, "water": 1},
			"desc": "Tăng +15% hiệu suất nạp pin Solar ban ngày",
			"buff_txt": "Nạp Solar +15%"
		},
		{
			"id": "fortify",
			"name": "🥣 Súp Hầm Kiên Cố",
			"cost": {"scrap": 1, "water": 1},
			"desc": "Tăng +50 HP cho cửa và toàn bộ tường rào đêm nay",
			"buff_txt": "Tường & Cửa +50 HP"
		},
		{
			"id": "lucky_cat",
			"name": "🍘 Bánh Hạt Vừng May Mắn",
			"cost": {"seeds": 2, "water": 1},
			"desc": "Mèo cưng may mắn: Mỗi lần nhặt đồ nhân đôi (x2)",
			"buff_txt": "Mèo May Mắn x2"
		}
	]

	for rec in recipes:
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(0, 48)

		var hbox := HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_lbl := Label.new()
		var cost_str: String = ""
		if rec["cost"].has("seeds"):
			cost_str += str(rec["cost"]["seeds"]) + " Hạt  "
		if rec["cost"].has("water"):
			cost_str += str(rec["cost"]["water"]) + " Nước  "
		if rec["cost"].has("scrap"):
			cost_str += str(rec["cost"]["scrap"]) + " Phế liệu"

		name_lbl.text = rec["name"] + " (" + cost_str + ")"
		name_lbl.add_theme_font_size_override("font_size", 12)
		name_lbl.add_theme_color_override("font_color", Color(0.98, 0.88, 0.60, 1.0))

		var desc_lbl := Label.new()
		desc_lbl.text = rec["desc"]
		desc_lbl.add_theme_font_size_override("font_size", 10)
		desc_lbl.add_theme_color_override("font_color", Color(0.78, 0.78, 0.82, 1.0))

		vbox.add_child(name_lbl)
		vbox.add_child(desc_lbl)

		var cook_btn := Button.new()
		cook_btn.custom_minimum_size = Vector2(75, 30)
		cook_btn.text = "Nấu"

		# Check affordability
		var can_cook: bool = true
		if rec["cost"].has("seeds") and GameState.seeds_count < rec["cost"]["seeds"]:
			can_cook = false
		if rec["cost"].has("water") and GameState.water_count < rec["cost"]["water"]:
			can_cook = false
		if rec["cost"].has("scrap") and GameState.scrap_count < rec["cost"]["scrap"]:
			can_cook = false

		cook_btn.disabled = not can_cook
		var r_copy: Dictionary = rec
		cook_btn.pressed.connect(func() -> void: _cook_recipe(r_copy))

		hbox.add_child(vbox)
		hbox.add_child(cook_btn)
		panel.add_child(hbox)
		dish_container.add_child(panel)


func _cook_recipe(rec: Dictionary) -> void:
	# Spend cost
	if rec["cost"].has("seeds"):
		GameState.spend_seeds(rec["cost"]["seeds"])
	if rec["cost"].has("water"):
		GameState.spend_water(rec["cost"]["water"])
	if rec["cost"].has("scrap"):
		GameState.spend_scrap(rec["cost"]["scrap"])

	active_buff = rec["id"]
	GameState.meal_buff = true

	# Apply buff
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if rec["id"] == "speed":
		var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
		if player != null:
			player.set("speed", 135.0)
	elif rec["id"] == "solar":
		GameState.solar_charge_multiplier = 1.15
	elif rec["id"] == "fortify":
		for wall in get_tree().get_nodes_in_group("defensive_wall"):
			if "hp" in wall:
				wall.set("hp", float(wall.get("hp")) + 50.0)
	elif rec["id"] == "lucky_cat":
		var cat: Node = get_tree().get_first_node_in_group("companion_cat")
		if cat != null:
			cat.set("lucky_loot", true)

	if hud != null and hud.has_method("show_toast"):
		hud.call("show_toast", "🍲 Đã nấu " + rec["name"] + "! Kích hoạt: " + rec["buff_txt"], 4.0, false)

	var stove: Node = get_tree().get_first_node_in_group("stove")
	if stove != null and stove.has_method("start_cooking_visual"):
		stove.call("start_cooking_visual")

	dish_cooked.emit(rec["id"])
	close_menu()
