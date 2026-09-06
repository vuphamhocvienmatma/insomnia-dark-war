extends Node

var pass_count: int = 0
var fail_count: int = 0
var suite_name: String = ""

signal test_done

func begin(name: String) -> void:
	suite_name = name
	print("\n=== " + name + " ===")

func check(condition: bool, msg: String) -> void:
	if condition:
		print("[PASS] " + msg)
		pass_count += 1
	else:
		printerr("[FAIL] " + msg)
		fail_count += 1
		var file = FileAccess.open("res://test_failed.flag", FileAccess.WRITE)
		file.store_string("failed")
		file.close()

func done() -> void:
	print("[%s] PASS: %d | FAIL: %d" % [suite_name, pass_count, fail_count])
	test_done.emit()
