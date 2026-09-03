extends Panel

var current_letter: Dictionary = {}

var header_lbl: Label
var sender_lbl: Label
var affinity_lbl: Label
var title_lbl: Label
var content_lbl: Label
var gift_box: Panel
var gift_lbl: Label
var gift_btn: Button
var reply_vbox: VBoxContainer
var status_lbl: Label

const WOOD_BG: Color = Color(0.15, 0.11, 0.08, 0.98)
const BORDER_COL: Color = Color(0.62, 0.46, 0.30, 1.0)
const GOLD_COL: Color = Color(0.96, 0.84, 0.55, 1.0)
const TEXT_COL: Color = Color(0.94, 0.90, 0.82, 1.0)
const HEART_COL: Color = Color(1.0, 0.45, 0.45, 1.0)


func _ready() -> void:
	anchor_left = 0.5
	anchor_top = 0.5
	anchor_right = 0.5
	anchor_bottom = 0.5
	offset_left = -250.0
	offset_top = -205.0
	offset_right = 250.0
	offset_bottom = 205.0

	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = WOOD_BG
	sb.border_color = BORDER_COL
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(14)
	sb.set_content_margin_all(14)
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 14
	sb.shadow_offset = Vector2(0, 5)
	add_theme_stylebox_override("panel", sb)

	_build_ui()
	visible = false


func _build_ui() -> void:
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 12.0
	vbox.offset_top = 10.0
	vbox.offset_right = -12.0
	vbox.offset_bottom = -10.0
	vbox.add_theme_constant_override("separation", 6)
	add_child(vbox)

	# 1. Header Bar with Close Button
	var head_hbox: HBoxContainer = HBoxContainer.new()
	vbox.add_child(head_hbox)

	header_lbl = Label.new()
	header_lbl.text = "✉️ THƯ TỪ VÙNG HOANG MẠC"
	header_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_lbl.add_theme_font_size_override("font_size", 14)
	header_lbl.add_theme_color_override("font_color", GOLD_COL)
	head_hbox.add_child(header_lbl)

	var close_btn: Button = Button.new()
	close_btn.text = " ✕ "
	close_btn.add_theme_font_size_override("font_size", 12)
	close_btn.pressed.connect(close_mailbox)
	head_hbox.add_child(close_btn)

	# 2. Sender & Affinity Info
	var meta_hbox: HBoxContainer = HBoxContainer.new()
	vbox.add_child(meta_hbox)

	sender_lbl = Label.new()
	sender_lbl.text = "Người gửi: Bác Sáu"
	sender_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sender_lbl.add_theme_font_size_override("font_size", 12)
	sender_lbl.add_theme_color_override("font_color", GOLD_COL)
	meta_hbox.add_child(sender_lbl)

	affinity_lbl = Label.new()
	affinity_lbl.text = "❤️ Thân mật: 0"
	affinity_lbl.add_theme_font_size_override("font_size", 12)
	affinity_lbl.add_theme_color_override("font_color", HEART_COL)
	meta_hbox.add_child(affinity_lbl)

	# Divider line
	var div1: ColorRect = ColorRect.new()
	div1.custom_minimum_size = Vector2(0, 1)
	div1.color = Color(0.42, 0.32, 0.22, 0.7)
	vbox.add_child(div1)

	# 3. Letter Title
	title_lbl = Label.new()
	title_lbl.text = "Tiêu đề thư"
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", GOLD_COL)
	vbox.add_child(title_lbl)

	# 4. Letter Content
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 95)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	content_lbl = Label.new()
	content_lbl.text = "Nội dung thư..."
	content_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_lbl.add_theme_font_size_override("font_size", 11)
	content_lbl.add_theme_color_override("font_color", TEXT_COL)
	scroll.add_child(content_lbl)

	# 5. Gift Card
	gift_box = Panel.new()
	gift_box.custom_minimum_size = Vector2(0, 36)
	var g_sb: StyleBoxFlat = StyleBoxFlat.new()
	g_sb.bg_color = Color(0.22, 0.16, 0.10, 0.90)
	g_sb.border_color = Color(0.72, 0.55, 0.28, 1.0)
	g_sb.set_border_width_all(1)
	g_sb.set_corner_radius_all(8)
	g_sb.set_content_margin_all(6)
	gift_box.add_theme_stylebox_override("panel", g_sb)
	vbox.add_child(gift_box)

	var gift_hbox: HBoxContainer = HBoxContainer.new()
	gift_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gift_hbox.offset_left = 6.0
	gift_hbox.offset_right = -6.0
	gift_box.add_child(gift_hbox)

	gift_lbl = Label.new()
	gift_lbl.text = "🎁 Quà đính kèm: +15 🔩 Phế liệu"
	gift_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gift_lbl.add_theme_font_size_override("font_size", 11)
	gift_lbl.add_theme_color_override("font_color", GOLD_COL)
	gift_hbox.add_child(gift_lbl)

	gift_btn = Button.new()
	gift_btn.text = "Nhận Quà"
	gift_btn.add_theme_font_size_override("font_size", 11)
	gift_btn.pressed.connect(_on_claim_gift_pressed)
	gift_hbox.add_child(gift_btn)

	# 6. Status Feedback Label (reactions / affinity changes)
	status_lbl = Label.new()
	status_lbl.text = ""
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_lbl.add_theme_font_size_override("font_size", 11)
	status_lbl.add_theme_color_override("font_color", GOLD_COL)
	vbox.add_child(status_lbl)

	# 7. Reply Choices Container
	reply_vbox = VBoxContainer.new()
	reply_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(reply_vbox)


func open_mailbox() -> void:
	var mm: Node = get_tree().get_first_node_in_group("mailbox_manager")
	if mm == null:
		return

	if not bool(mm.call("has_unread")):
		status_lbl.text = "📭 Hòm thư hiện tại đang trống. Hãy đợi thư mới từ phương xa!"
		title_lbl.text = "Không có thư mới"
		content_lbl.text = "Những người bạn đường xa thỉnh thoảng sẽ gửi thư thăm hỏi, chia sẻ chuyện vui buồn và quà tiếp tế cho bạn."
		sender_lbl.text = "Hòm thư dã chiến"
		affinity_lbl.text = ""
		gift_box.visible = false
		_clear_reply_buttons()
		visible = true
		modulate.a = 0.0
		var tw: Tween = create_tween()
		tw.tween_property(self, "modulate:a", 1.0, 0.15)
		return

	var letter: Dictionary = Dictionary(mm.call("get_current_unread"))
	display_letter(letter)
	visible = true
	modulate.a = 0.0
	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.15)


func close_mailbox() -> void:
	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.12)
	tw.tween_callback(func() -> void: visible = false)


func display_letter(letter: Dictionary) -> void:
	current_letter = letter
	status_lbl.text = ""

	var sender: String = str(letter.get("sender", "Ẩn danh"))
	sender_lbl.text = "Người gửi: " + sender
	title_lbl.text = str(letter.get("title", ""))
	content_lbl.text = str(letter.get("content", ""))

	var mm: Node = get_tree().get_first_node_in_group("mailbox_manager")
	var aff_val: int = 0
	if mm != null and "sender_affinity" in mm:
		var aff_dict: Dictionary = Dictionary(mm.get("sender_affinity"))
		aff_val = int(aff_dict.get(sender, 0))
	affinity_lbl.text = "❤️ Thân mật: " + str(aff_val)

	# Handle Gift display
	var gifts: Dictionary = Dictionary(letter.get("gift", {}))
	if gifts.is_empty():
		gift_box.visible = false
	else:
		gift_box.visible = true
		var g_desc: String = "🎁 Quà đính kèm: "
		if gifts.has("scrap"):
			g_desc += "+" + str(int(gifts["scrap"])) + " 🔩 Phế liệu  "
		if gifts.has("seeds"):
			g_desc += "+" + str(int(gifts["seeds"])) + " 🌱 Hạt giống  "
		if gifts.has("water"):
			g_desc += "+" + str(int(gifts["water"])) + " 💧 Nước"
		gift_lbl.text = g_desc
		var claimed: bool = bool(letter.get("gift_claimed", false))
		gift_btn.visible = not claimed
		if claimed:
			gift_lbl.text = "✓ " + g_desc + " (Đã nhận)"

	# Build Reply Choices
	_clear_reply_buttons()
	var replies: Array = letter.get("replies", [])
	for idx in replies.size():
		var choice: Dictionary = Dictionary(replies[idx])
		var btn: Button = Button.new()
		var aff_delta: int = int(choice.get("affinity", 0))
		var aff_sign: String = ("+" if aff_delta > 0 else "") + str(aff_delta)
		btn.text = "💬 " + str(choice.get("text", "")) + " (" + aff_sign + " ❤️)"
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 11)
		var c_idx: int = idx
		btn.pressed.connect(func() -> void: _on_reply_chosen(c_idx))
		reply_vbox.add_child(btn)


func _on_claim_gift_pressed() -> void:
	var mm: Node = get_tree().get_first_node_in_group("mailbox_manager")
	if mm == null or current_letter.is_empty():
		return
	var l_id: String = str(current_letter.get("id", ""))
	mm.call("claim_gift", l_id)
	current_letter["gift_claimed"] = true
	gift_btn.visible = false
	gift_lbl.text = "✓ Đã nhận quà vào túi đồ!"
	status_lbl.text = "✨ Đã nhận quà thành công!"


func _on_reply_chosen(choice_index: int) -> void:
	var mm: Node = get_tree().get_first_node_in_group("mailbox_manager")
	if mm == null or current_letter.is_empty():
		return

	var l_id: String = str(current_letter.get("id", ""))
	var result: Dictionary = Dictionary(mm.call("reply_letter", l_id, choice_index))
	
	var reaction: String = str(result.get("reaction", "Đã gửi thư hồi đáp!"))
	var aff_delta: int = int(result.get("affinity", 0))
	var aff_sign: String = ("+" if aff_delta > 0 else "") + str(aff_delta)
	
	status_lbl.text = "🕊️ " + reaction + " (" + aff_sign + " ❤️ Thân mật)"
	_clear_reply_buttons()
	gift_box.visible = false

	# After short moment, check if more letters exist
	get_tree().create_timer(2.2).timeout.connect(func() -> void:
		if is_inside_tree() and visible:
			open_mailbox()
	)


func _clear_reply_buttons() -> void:
	for child in reply_vbox.get_children():
		child.queue_free()
