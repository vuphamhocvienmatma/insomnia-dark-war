extends Area2D

@onready var prompt: Label = $Prompt
var is_player_near: bool = false


func _ready() -> void:
	add_to_group("mailbox")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt != null:
		prompt.visible = false
		prompt.text = "✉️ [E] Hòm thư"


func _unhandled_input(event: InputEvent) -> void:
	if is_player_near and event.is_action_pressed("interact"):
		var hud: Node = get_tree().get_first_node_in_group("hud")
		if hud != null and hud.has_method("open_mailbox_ui"):
			hud.call("open_mailbox_ui")
		else:
			# Fallback: Find HUD on main level
			var root_hud: Node = get_tree().root.find_child("HUD", true, false)
			if root_hud != null and root_hud.has_method("open_mailbox_ui"):
				root_hud.call("open_mailbox_ui")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = true
		if prompt != null:
			prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = false
		if prompt != null:
			prompt.visible = false
