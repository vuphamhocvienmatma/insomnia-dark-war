extends CanvasLayer

var panel: Panel
var current_page: int = 0

var pages: Array[Dictionary] = [
	{"title": "🎮 Controls", "content": "←→ Di chuyển\n↑↓ Leo thang\nE Tương tác\nC Crafting\nH Hướng dẫn"},
	{"title": "☀️ Ban ngày", "content": "- Nhặt phế liệu/hạt/nước\n- Xây rào ở khe hở\n- Trồng cây (tưới để lớn nhanh)\n- Nấu ăn ở bếp"},
	{"title": "🌙 Ban đêm", "content": "- Zombie tấn công rào\n- Turret tự bắn (tốn solar)\n- Rào hở → zombie lục đồ\n- Sáng dậy mệt nếu rào hở"},
	{"title": "🔨 Crafting [C]", "content": "- Bữa ăn: hết mệt\n- Pin mặt trời: +25 solar\n- Đồ chơi mèo: nhặt nhanh hơn"},
	{"title": "💡 Tips", "content": "- Hoàn thành task → thưởng\n- Ngày sau zombie đông hơn\n- Tưới cây để lớn nhanh\n- Xây rào kín để ngủ ngon"}
]


func _ready() -> void:
	panel = $Panel
	panel.visible = false
	_update_page()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tutorial"):
		panel.visible = !panel.visible
		if panel.visible:
			_update_page()
		return
	if panel.visible:
		if event.is_action_pressed("ui_left"):
			current_page = max(0, current_page - 1)
			_update_page()
		elif event.is_action_pressed("ui_right"):
			current_page = min(pages.size() - 1, current_page + 1)
			_update_page()


func _update_page() -> void:
	$Panel/VBoxContainer/Title.text = pages[current_page]["title"]
	$Panel/VBoxContainer/Content.text = pages[current_page]["content"]
	$Panel/VBoxContainer/PageIndicator.text = str(current_page + 1) + "/" + str(pages.size())
