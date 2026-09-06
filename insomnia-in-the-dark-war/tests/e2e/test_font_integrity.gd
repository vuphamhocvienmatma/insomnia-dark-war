extends Node

signal test_done

func _ready() -> void:
	var _t = preload("res://tests/helpers/test_assert.gd").new()
	add_child(_t)
	_t.begin("FontIntegrity")

	var files_to_check: Array[String] = [
		"res://scripts/hud.gd",
		"res://scripts/zombie_ai.gd",
		"res://scripts/time_manager.gd",
		"res://scripts/mailbox_manager.gd",
		"res://scripts/art_cabin_props.gd",
		"res://scripts/companion_cat.gd",
	]

	var bad_patterns: Array[String] = ["Ã°", "Å¸", "â€", "Ã¡", "á»", "Ã©", "Ã¢"]

	for file_path in files_to_check:
		if not FileAccess.file_exists(file_path):
			continue
		var f := FileAccess.open(file_path, FileAccess.READ)
		var content: String = f.get_as_text()
		f.close()

		var has_corruption: bool = false
		for pattern in bad_patterns:
			if pattern in content:
				has_corruption = true
				break

		var fname: String = file_path.get_file()
		_t.check(not has_corruption, "FONT: " + fname + " - khong co mojibake")

	_t.done()
	test_done.emit()
