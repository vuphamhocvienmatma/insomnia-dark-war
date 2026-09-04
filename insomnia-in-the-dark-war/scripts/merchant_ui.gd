extends Control

signal item_purchased(item_id: String)

@onready var scrap_label: Label = $Panel/ScrapHeader
@onready var item_container: VBoxContainer = $Panel/ScrollContainer/ItemContainer
@onready var close_btn: Button = $Panel/CloseButton

var purchased_unique: Dictionary = {}


func _ready() -> void:
	visible = false
	close_btn.pressed.connect(close_shop)
	_refresh_shop()


func open_shop() -> void:
	visible = true
	_refresh_shop()


func close_shop() -> void:
	visible = false


func _refresh_shop() -> void:
	if scrap_label != null and GameState != null:
		scrap_label.text = "🔩 Phế liệu hiện có: " + str(GameState.scrap_count)

	if item_container == null:
		return

	# Clear previous items
	for child in item_container.get_children():
		child.queue_free()

	var stock: Array[Dictionary] = [
		{"id": "seeds_pack", "name": "🌾 Túi Hạt Giống (+3 Hạt)", "desc": "Hạt giống thảo dược chịu hạn tốt", "price": 4, "type": "consumable"},
		{"id": "water_pack", "name": "💧 Bình Nước Sạch (+2 Nước)", "desc": "Nước ngầm lọc than hoạt tính", "price": 3, "type": "consumable"},
		{"id": "cozy_rug", "name": "🧶 Thảm Len Dệt (+20 Cozy)", "desc": "Thảm len êm ái trải giữa phòng khách", "price": 12, "type": "unique"},
		{"id": "disco_ball", "name": "🪩 Quả Cầu Disco Lofi (+25 Cozy)", "desc": "Treo xà trần, xoay lấp lánh đốm nắng", "price": 18, "type": "unique"},
		{"id": "retro_poster", "name": "🖼️ Tranh Poster Hoài Niệm (+15 Cozy)", "desc": "Treo tường tầng 1, ngắm là thấy chill", "price": 8, "type": "unique"},
		{"id": "pastel_lights", "name": "💡 Bộ Đèn Fairy Light Hồng (+20 Cozy)", "desc": "Đổi màu dây đèn lofi sang tông hồng pastel", "price": 10, "type": "unique"},
		{"id": "bp_radio", "name": "📻 Blueprint: Radio Dã Chiến", "desc": "Mở khóa chế tạo Radio dự báo bão & đột biến", "price": 15, "type": "unique"},
		{"id": "bp_stove", "name": "♨️ Blueprint: Lò Sưởi Tăng Cường", "desc": "Mở khóa lò sưởi chặn mệt mỏi 2 ngày", "price": 20, "type": "unique"},
		{"id": "bp_greenhouse", "name": "🌿 Blueprint: Nhà Kính Hiên Nhà", "desc": "Mở khóa thêm 2 chậu cây trồng rau", "price": 25, "type": "unique"},
		{"id": "tape_rainy", "name": "📼 Băng Nhạc: Rainy Shelter", "desc": "Băng cassette lofi tiếng mưa và acoustic guitar", "price": 10, "type": "unique"}
	]

	for itm in stock:
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 38)

		var info_box := VBoxContainer.new()
		info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_lbl := Label.new()
		name_lbl.text = itm["name"] + " — " + str(itm["price"]) + " Phế liệu"
		name_lbl.add_theme_font_size_override("font_size", 12)
		name_lbl.add_theme_color_override("font_color", Color(0.96, 0.88, 0.65, 1.0))

		var desc_lbl := Label.new()
		desc_lbl.text = itm["desc"]
		desc_lbl.add_theme_font_size_override("font_size", 10)
		desc_lbl.add_theme_color_override("font_color", Color(0.72, 0.72, 0.75, 1.0))

		info_box.add_child(name_lbl)
		info_box.add_child(desc_lbl)

		var buy_btn := Button.new()
		buy_btn.custom_minimum_size = Vector2(75, 30)

		var is_bought: bool = purchased_unique.has(itm["id"])
		if is_bought and itm["type"] == "unique":
			buy_btn.text = "Đã Mua"
			buy_btn.disabled = true
		else:
			buy_btn.text = "Mua"
			var can_afford: bool = GameState.scrap_count >= itm["price"]
			buy_btn.disabled = not can_afford
			var item_ref: Dictionary = itm
			buy_btn.pressed.connect(func() -> void: _buy_item(item_ref))

		row.add_child(info_box)
		row.add_child(buy_btn)
		item_container.add_child(row)


func _buy_item(itm: Dictionary) -> void:
	if not GameState.spend_scrap(itm["price"]):
		return

	if itm["type"] == "unique":
		purchased_unique[itm["id"]] = true

	# Handle items
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if itm["id"] == "seeds_pack":
		GameState.add_seeds(3)
		if hud != null and hud.has_method("show_toast"):
			hud.call("show_toast", "🌾 Đã mua 3 Hạt giống!", 2.5, false)
	elif itm["id"] == "water_pack":
		GameState.add_water(2)
		if hud != null and hud.has_method("show_toast"):
			hud.call("show_toast", "💧 Đã mua 2 Nước sạch!", 2.5, false)
	else:
		# Decor / Blueprint / Tape
		var cdm: Node = get_tree().root.find_child("CabinDecorationManager", true, false)
		if cdm != null and cdm.has_method("unlock_item"):
			cdm.call("unlock_item", itm["id"])
		if hud != null and hud.has_method("show_toast"):
			hud.call("show_toast", "✨ Đã mở khóa: " + itm["name"] + "!", 3.0, false)

	item_purchased.emit(itm["id"])
	_refresh_shop()
