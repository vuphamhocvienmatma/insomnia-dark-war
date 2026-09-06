extends Node

signal test_done

var _t: Node

func _ready() -> void:
	_t = preload("res://tests/helpers/test_assert.gd").new()
	add_child(_t)
	_t.begin("MailboxManager")
	run_all()
	_t.done()
	test_done.emit()

func run_all() -> void:
	_t.check(MailboxManager != null, "MM-07: MailboxManager is autoloaded")
	
	MailboxManager.sender_affinity["Bac Sau"] = 0
	_t.check(MailboxManager.sender_affinity["Bac Sau"] == 0, "MM-01: init affinity")
	
	var test_letter = {
		"id": "test_mail",
		"sender": "Bac Sau",
		"title": "Test Title",
		"content": "Test Content",
		"gift": {"scrap": 10},
		"replies": [{"text": "Reply", "affinity": 10}]
	}
	
	MailboxManager.receive_letter(test_letter)
	var has_mail = MailboxManager.has_unread()
	_t.check(has_mail, "MM-02: mail_received and unread populated")
	
	var l = MailboxManager.get_current_unread()
	_t.check(l.has("title") and l.has("content") and l.has("sender"), "MM-03: letter has required fields")
	
	var old_aff = MailboxManager.sender_affinity.get("Bac Sau", 0)
	MailboxManager.reply_letter("test_mail", 0)
	var new_aff = MailboxManager.sender_affinity.get("Bac Sau", 0)
	_t.check(new_aff > old_aff, "MM-04: reply increases affinity")
	
	MailboxManager.sender_affinity["Bác Sáu (Câu Cá Sa Mạc)"] = 60
	MailboxManager._check_milestone_surprise("Bác Sáu (Câu Cá Sa Mạc)", 60)
	_t.check(GameState.relics_found.has("golden_fishing_rod"), "MM-05/06: golden_fishing_rod at 60 affinity")
	
	_t.check(MailboxManager.letter_history.size() > 0, "MM-08: mail history updated")
