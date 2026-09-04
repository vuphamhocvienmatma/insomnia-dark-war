extends Node

signal mail_received(letter: Dictionary)
signal mail_read(letter: Dictionary)
signal affinity_changed(sender: String, new_affinity: int, delta: int)
signal surprise_gift_unlocked(sender: String, title: String, reward_desc: String)

var unread_letters: Array[Dictionary] = []
var letter_history: Array[Dictionary] = []
var sender_affinity: Dictionary = {
	"Bác Sáu (Câu Cá Sa Mạc)": 0,
	"Bóng Đêm 404 (Trạm Vô Tuyến)": 0,
	"Cô Bé Hoa Cúc (Trạm Cứu Hộ)": 0,
	"Thợ Máy Râu Kẽm (Xưởng Ngầm)": 0
}

var _all_templates: Array[Dictionary] = []
var _used_letter_ids: Array[String] = []
var _timer: float = 0.0
var _next_letter_delay: float = 65.0


func _ready() -> void:
	add_to_group("mailbox_manager")
	_init_letter_templates()
	
	# Initial welcome mail on Day 1
	var starter_letter: Dictionary = _get_starter_letter()
	receive_letter(starter_letter)


func _process(delta: float) -> void:
	_timer += delta
	if _timer >= _next_letter_delay:
		_timer = 0.0
		_next_letter_delay = randf_range(60.0, 95.0)
		generate_random_letter()


func has_unread() -> bool:
	return not unread_letters.is_empty()


func get_current_unread() -> Dictionary:
	if unread_letters.is_empty():
		return {}
	return unread_letters[0]


func receive_letter(letter: Dictionary) -> void:
	unread_letters.append(letter)
	mail_received.emit(letter)
	var am: Node = get_tree().get_first_node_in_group("audio_manager")
	if am != null and am.has_method("play_sfx"):
		am.call("play_sfx", "item_pickup")


func claim_gift(letter_id: String) -> Dictionary:
	for l in unread_letters:
		if str(l.get("id", "")) == letter_id:
			var gifts: Dictionary = Dictionary(l.get("gift", {}))
			l["gift_claimed"] = true
			_grant_rewards(gifts)
			return gifts
	return {}


func reply_letter(letter_id: String, choice_index: int) -> Dictionary:
	var target_letter: Dictionary = {}
	var target_idx: int = -1
	for i in unread_letters.size():
		if str(unread_letters[i].get("id", "")) == letter_id:
			target_letter = unread_letters[i]
			target_idx = i
			break

	if target_letter.is_empty():
		return {}

	var choices: Array = target_letter.get("replies", [])
	if choice_index < 0 or choice_index >= choices.size():
		return {}

	var chosen: Dictionary = choices[choice_index]
	var delta: int = int(chosen.get("affinity", 0))
	var sender: String = str(target_letter.get("sender", "Ẩn Danh"))

	# Update affinity
	var cur_aff: int = int(sender_affinity.get(sender, 0)) + delta
	cur_aff = clampi(cur_aff, -20, 100)
	sender_affinity[sender] = cur_aff
	affinity_changed.emit(sender, cur_aff, delta)

	# Claim gift if not claimed yet
	if not bool(target_letter.get("gift_claimed", false)):
		var gifts: Dictionary = Dictionary(target_letter.get("gift", {}))
		if not gifts.is_empty():
			_grant_rewards(gifts)

	target_letter["replied"] = true
	target_letter["chosen_reply"] = chosen.get("text", "")
	unread_letters.remove_at(target_idx)
	letter_history.append(target_letter)
	mail_read.emit(target_letter)

	# Check surprise gift milestones (at 30 and 60 affinity)
	_check_milestone_surprise(sender, cur_aff)

	return chosen


func _grant_rewards(gifts: Dictionary) -> void:
	if gifts.has("scrap"):
		var scrap_amt: int = int(gifts["scrap"])
		GameState.add_scrap(scrap_amt)
	if gifts.has("seeds"):
		var seed_amt: int = int(gifts["seeds"])
		GameState.add_seeds(seed_amt)
	if gifts.has("water"):
		var water_amt: int = int(gifts["water"])
		GameState.add_water(water_amt)


func _check_milestone_surprise(sender: String, aff: int) -> void:
	if aff >= 60 and not bool(SaveManager.has_unlocked("surprise_60_" + sender) if SaveManager else false):
		if SaveManager:
			SaveManager.unlock("surprise_60_" + sender)

		var title: String = "🎁 [TRI KỶ] Gói Tiếp Tế Bí Mật Từ " + sender
		var content: String = "Chú em/Đồng chí thân mến! Hiếm có người nào ở vùng hoang mạc này lại tâm đầu ý hợp và đáng tin như cậu. Tôi gửi tặng cậu toàn bộ thùng đồ sinh tồn cao cấp nhất!"
		var gifts: Dictionary = {"scrap": 40, "seeds": 12, "water": 5}
		var relic_name: String = ""

		if sender.begins_with("Bác Sáu"):
			title = "🎁 [MINI-ENDING: BÁC SÁU] Trao Tặng Cần Câu Vàng Gia Truyền!"
			content = "Chào chú mày! Lão Sáu chèo thuyền qua bão cát ghé thăm chú đây! Nhìn căn cabin ấm áp thế này lão ưng cái bụng quá. Lão trao cho chú bảo vật gia truyền: CẦN CÂU VÀNG CỦA LÃO SÁU. Cứ mỗi sáng bình minh, cần câu sẽ tự động vớt tặng chú 1 Phế Liệu & 1 Bình Nước ngọt vĩnh viễn!"
			gifts = {"scrap": 25, "water": 5}
			relic_name = "golden_fishing_rod"
			GameState.add_relic("golden_fishing_rod")
		elif sender.begins_with("Bóng Đêm 404"):
			title = "🎁 [MINI-ENDING: ĐIỆP VỤ 404] Ống Kính Nhìn Đêm AK-47!"
			content = "Tín hiệu đã thông suốt toàn bộ hoang mạc. Drone tiếp tế thả thẳng xuống mái nhà cậu: ỐNG KÍNH NHÌN ĐÊM QUÂN SỰ. Gắn trực tiếp vào AK-47, tăng 25% tầm bắn và độ chính xác trong đêm tối!"
			gifts = {"scrap": 30}
			relic_name = "night_vision_relic"
			GameState.add_relic("night_vision_relic")
		elif sender.begins_with("Cô Bé Hoa Cúc"):
			title = "🎁 [MINI-ENDING: VƯỜN THẢO DƯỢC] Bình Tưới Thần Kỳ!"
			content = "Anh ơi! Khu bảo tồn hoa cúc đã phủ xanh ngọn đồi rồi! Em tặng anh BÌNH TƯỚI THẦN KỲ làm từ vỏ hợp kim máy bay. Cây hoa và thảo dược của anh giờ đây sẽ lớn nhanh hơn gấp rưỡi (x1.5)!"
			gifts = {"seeds": 15, "water": 4}
			relic_name = "miracle_watering_can"
			GameState.add_relic("miracle_watering_can")
		elif sender.begins_with("Thợ Máy Râu Kẽm"):
			title = "🎁 [MINI-ENDING: VUA CÔNG SỰ] Bộ Nòng AK Mạ Crom!"
			content = "Ha ha! Công sự kiên cố của chú mày làm lão nể phục rồi đấy! Lão gửi tặng món quà vô giá: BỘ NÒNG AK MẠ CROM rèn từ thép thiên thạch, tăng 25% tốc độ xả đạn của súng trên mái!"
			gifts = {"scrap": 35}
			relic_name = "chromium_ak_barrel"
			GameState.add_relic("chromium_ak_barrel")

		var s_pkg: Dictionary = {
			"id": "surprise_60_" + str(Time.get_ticks_msec()),
			"sender": sender,
			"title": title,
			"content": content,
			"gift": gifts,
			"replies": [
				{"text": "Vô cùng cảm kích tấm lòng của bạn! Hẹn ngày gặp lại.", "affinity": 10, "reaction": "Tình bạn vượt qua mọi giông bão tận thế!"}
			]
		}
		receive_letter(s_pkg)
		surprise_gift_unlocked.emit(sender, title, "Kích hoạt bảo vật vĩnh viễn: " + relic_name)
	elif aff >= 30 and not bool(SaveManager.has_unlocked("surprise_30_" + sender) if SaveManager else false):
		if SaveManager:
			SaveManager.unlock("surprise_30_" + sender)
		var s_pkg: Dictionary = {
			"id": "surprise_30_" + str(Time.get_ticks_msec()),
			"sender": sender,
			"title": "🎉 [THÂN THIẾT] Món Quà Bất Ngờ Từ " + sender,
			"content": "Tôi rất vui vì những lá thư qua lại cùng bạn. Nơi hoang vắng này có một người biết lắng nghe thật đáng quý. Tặng bạn hộp linh kiện và hạt giống tôi chắt chiu được.",
			"gift": {"scrap": 25, "seeds": 6, "water": 2},
			"replies": [
				{"text": "Cảm ơn bạn rất nhiều, giữ an toàn nhé!", "affinity": 5, "reaction": "Sợi dây liên kết ngày càng khăng khít."}
			]
		}
		receive_letter(s_pkg)
		surprise_gift_unlocked.emit(sender, "Gói Quà Thân Thiết", "+25 🔩 Phế liệu, +6 🌱 Hạt giống, +2 💧 Nước")


func generate_random_letter() -> void:
	var candidates: Array[Dictionary] = []
	for t in _all_templates:
		if not _used_letter_ids.has(t.get("id", "")):
			candidates.append(t)

	if candidates.is_empty():
		_used_letter_ids.clear()
		candidates = _all_templates.duplicate()

	if not candidates.is_empty():
		var chosen_template: Dictionary = candidates[randi() % candidates.size()]
		_used_letter_ids.append(chosen_template.get("id", ""))
		var new_letter: Dictionary = chosen_template.duplicate(true)
		new_letter["timestamp"] = Time.get_time_string_from_system()
		receive_letter(new_letter)


func _get_starter_letter() -> Dictionary:
	return {
		"id": "starter_mail",
		"sender": "Bác Sáu (Câu Cá Sa Mạc)",
		"title": "🐟 Lời chào từ lão già câu cá cồn cát phía Đông",
		"content": "Chào người anh em mới đến ngụ cư ở căn chòi gỗ!\n\nLão thấy ống khói lò sưởi của chú bốc lên mấy hôm nay giữa trời sa mạc buốt giá, nhìn ấm cúng phết. Vùng này ban ngày thì nắng rát cát cháy, ban đêm thì zombie mắt đỏ đi rầm rập như trẩy hội.\n\nLão câu được mấy thùng phế liệu kẹt dưới đáy giếng cát, gửi chú em lấy may làm vốn sửa cái hàng rào phòng thủ!",
		"gift": {"scrap": 15, "water": 2},
		"replies": [
			{
				"text": "Dạ cháu cảm ơn bác nhiều ạ! Cháu sẽ gia cố rào cẩn thận.",
				"affinity": 10,
				"reaction": "Bác Sáu cười khoái chí: 'Thằng bé ngoan và lễ phép, lão ưng đấy!'"
			},
			{
				"text": "Cảm ơn bác, hôm nào rảnh bác ghé chòi cháu uống trà nghe đĩa than nhé!",
				"affinity": 8,
				"reaction": "Bác Sáu reo lên: 'Có đĩa than à? Chắc chắn lão sẽ ghé!'"
			},
			{
				"text": "Ừ nhận đồ rồi, lần sau có gửi thì gửi thêm đạn súng AK nhé.",
				"affinity": -5,
				"reaction": "Bác Sáu lầm bầm: 'Cậu em này ăn nói cục súc quá...'"
			}
		]
	}


func _init_letter_templates() -> void:
	_all_templates = [
		# 1. Hài Hước (Comedy)
		{
			"id": "humor_1",
			"sender": "Bác Sáu (Câu Cá Sa Mạc)",
			"title": "🎣 Cần câu giật trúng... cái quần đùi của zombie!",
			"content": "Chú em ơi cười chết mất thôi!\n\nNãy phao câu giật lia lịa, lão tưởng bắt được thủy quái sa mạc huyền thoại. Kéo lên bờ té ra là cái quần đùi rách tả tơi của một con zombie bơi cát! Nó trồi đầu lên ngơ ngác nhìn lão rồi lại tụt xuống cát lủi mất.\n\nĐính kèm cho chú em mấy hạt giống rau muống sa mạc lão câu được trong hốc đá!",
			"gift": {"seeds": 5, "water": 1},
			"replies": [
				{"text": "Bác hài hước thật đấy, câu cá mà tấu hài số một vùng hoang mạc!", "affinity": 10, "reaction": "Bác Sáu cười sặc nước: 'Hahaha đời tận thế phải vui chú em ạ!'"},
				{"text": "Trời lạnh thế mà zombie cũng thích tắm cát hả bác?", "affinity": 6, "reaction": "Bác Sáu gật gù: 'Cát ấm mà lị!'"},
				{"text": "Bác rảnh quá thì đi tìm phế liệu tử tế giùm cháu đi.", "affinity": -6, "reaction": "Bác Sáu thở dài: 'Thanh niên thời nay khô khan quá...'"}
			]
		},
		# 2. Kinh Dị Tận Thế (Horror / Mystery)
		{
			"id": "horror_1",
			"sender": "Bóng Đêm 404 (Trạm Vô Tuyến)",
			"title": "📡 Tiếng thở dốc ngoài rào chắn lúc 03:15 sáng",
			"content": "Tần số khẩn cấp: 142.8 MHz.\n\nTôi vừa quan sát thấy một bóng đen hình người cao hơn 3 mét lướt qua bãi mìn phía Tây cabin của bạn. Nó không phát ra tiếng bước chân, chỉ có tiếng kim loại cào vào nhau ken két.\n\nĐừng mở cửa ban đêm nếu nghe tiếng người thân gọi tên bạn từ trong sương mù. Nhận lấy gói linh kiện thép này để gia cố chốt cửa ngay lập tức.",
			"gift": {"scrap": 20},
			"replies": [
				{"text": "Tôi đã khóa chặt cửa và kiểm tra lại băng đạn AK. Cảm ơn thông tin sinh tử!", "affinity": 10, "reaction": "Bóng Đêm 404: 'Sự tỉnh táo là vũ khí tối thượng của bạn.'"},
				{"text": "Nghe rợn tóc gáy thật... Trạm của bạn có an toàn không?", "affinity": 8, "reaction": "Bóng Đêm 404: 'Tôi ở trong bóng tối, bóng tối bảo vệ tôi.'"},
				{"text": "Chắc bạn nhìn gà hóa cuốc rồi, làm gì có quái vật 3 mét.", "affinity": -5, "reaction": "Bóng Đêm 404: 'Hy vọng bạn sẽ không phải hối hận vì sự khinh suất.'"}
			]
		},
		# 3. Động Viên Ấm Áp (Cozy Encouragement)
		{
			"id": "warmth_1",
			"sender": "Cô Bé Hoa Cúc (Trạm Cứu Hộ)",
			"title": "🌻 Mầm hoa cúc dại đầu tiên hé nở trong bão cát",
			"content": "Anh chủ cabin ơi,\n\nSáng nay sau một đêm bão cát dữ dội, em bước ra hiên trạm thì thấy một mầm cây xanh li ti đã vươn mình đâm thủng lớp đất cằn cỗi. Nó kiên cường vô cùng anh ạ!\n\nEm gói tặng anh mấy gói hạt giống hoa cúc và bình nước suối khoáng thanh mát. Mong căn chòi nhỏ của anh luôn ấm áp ánh lửa lò sưởi và tiếng nhạc bình yên nhé!",
			"gift": {"seeds": 6, "water": 3},
			"replies": [
				{"text": "Cảm ơn đóa hoa cúc của em, nhìn mầm cây anh có thêm niềm tin sống sót!", "affinity": 10, "reaction": "Cô Bé Hoa Cúc vui mừng: 'Em sẽ gửi thêm nhiều hạt hoa đẹp nữa cho anh!'"},
				{"text": "Anh sẽ gieo những hạt giống này ngay cạnh bậc thềm cabin!", "affinity": 7, "reaction": "Cô Bé Hoa Cúc: 'Tuyệt vời ạ, chòi của anh sẽ là một khu vườn nhỏ!'"},
				{"text": "Tận thế cần thức ăn và đạn chứ ai ngắm hoa bao giờ.", "affinity": -6, "reaction": "Cô Bé Hoa Cúc buồn bã: 'Nhưng tâm hồn cũng cần được tưới mát mà...'"}
			]
		},
		# 4. Tiếp Tế Dã Chiến & Kỹ Thuật (Technical Supplies)
		{
			"id": "tech_1",
			"sender": "Thợ Máy Râu Kẽm (Xưởng Ngầm)",
			"title": "🔧 Hộp phụ tùng lò xo tăng lực cho súng AK",
			"content": "Này chàng trai cabin,\n\nTôi vừa nhặt được một lô lò xo thép tôi luyện từ xác chiếc xe tăng cũ. Tôi gia công lại thành bộ giảm giật cho súng trường tự động. Đặt bệ súng nghiêng theo mái nhà của cậu là chuẩn bài rồi đấy, lắp thêm đống phế liệu này vào thì quét zombie mượt như máy cắt cỏ!\n\nNhận lấy mà dùng thử, thấy sướng thì rep lại cho tôi một câu nhé.",
			"gift": {"scrap": 25},
			"replies": [
				{"text": "Tay nghề của bác Râu Kẽm đúng là huyền thoại vùng hoang dã!", "affinity": 10, "reaction": "Râu Kẽm cười sảng khoái: 'Hahaha thợ cơ khí bậc 7 thời xưa đấy chú em!'"},
				{"text": "Phụ tùng ngon lắm bác, súng bắn êm ru không giật tí nào!", "affinity": 7, "reaction": "Râu Kẽm: 'Tất nhiên rồi, hàng của tôi làm sao mà tệ được!'"},
				{"text": "Sắt vụn thôi mà làm như báu vật, nhưng dù sao cũng lấy.", "affinity": -6, "reaction": "Râu Kẽm bực bội: 'Biết thế cho ve chai cho xong, đồ khó tính!'"}
			]
		}
	]
