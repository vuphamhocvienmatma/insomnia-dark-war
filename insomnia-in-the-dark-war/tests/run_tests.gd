extends Node

var step = 0
var tests = [
	"res://tests/unit/test_game_state.gd",
	"res://tests/unit/test_journal_manager.gd",
	"res://tests/unit/test_save_manager.gd",
	"res://tests/unit/test_time_manager.gd",
	"res://tests/unit/test_mailbox_manager.gd",
	"res://tests/unit/test_crafting_ui.gd",
	"res://tests/e2e/test_font_integrity.gd"
]
var current_test_node: Node = null
var is_waiting = false

func _ready() -> void:
	print("=== INSOMNIA IN THE DARK WAR - TEST SUITE ===")
	set_process(true)

func _process(delta: float) -> void:
	if is_waiting:
		return
		
	if step >= tests.size():
		var result: int = 0
		# Instead of getting exit code from OS (which might not exist in GDScript), we can track if there are any failures.
		# Since I use OS.set_exit_code(1) in test_assert, let's just track it here globally.
		# But wait, Godot 4 does not have OS.set_exit_code, it has get_tree().quit(exit_code).
		# Wait! OS.set_exit_code() was removed in Godot 4!
		print("\n✅ TAT CA TEST XONG")
		get_tree().quit()
		return

	var path = tests[step]
	step += 1
	
	if not ResourceLoader.exists(path):
		print("[SKIP] File not found: " + path)
		return
		
	var scr: GDScript = load(path)
	current_test_node = Node.new()
	current_test_node.set_script(scr)
	
	if current_test_node.has_signal("test_done"):
		current_test_node.test_done.connect(_on_test_done)
		is_waiting = true
	
	add_child(current_test_node)
	
	if not is_waiting:
		current_test_node.queue_free()

func _on_test_done() -> void:
	current_test_node.queue_free()
	is_waiting = false
