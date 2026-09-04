extends CharacterBody2D

signal shop_opened

var is_player_near: bool = false
@onready var prompt: Label = $Prompt


func _ready() -> void:
	add_to_group("merchant_dog")
	position.y = 0.0
	_update_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if not is_player_near:
		return

	if event.is_action_pressed("interact"):
		open_shop()
		get_viewport().set_input_as_handled()


func open_shop() -> void:
	shop_opened.emit()
	var hud: Node = get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("open_merchant_modal"):
		hud.call("open_merchant_modal")


func _update_prompt() -> void:
	if prompt != null:
		prompt.visible = is_player_near
		prompt.text = "🤖 [E / Click] Chó Robot Thương Nhân"


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = true
		_update_prompt()


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = false
		_update_prompt()
