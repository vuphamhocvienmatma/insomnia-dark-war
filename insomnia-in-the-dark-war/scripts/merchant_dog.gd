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


func _draw() -> void:
	var eco = false
	if GameState != null and GameState.eco_mode: eco = true
	
	if not eco:
		var tm = get_tree().get_first_node_in_group("time_manager")
		if tm != null:
			var is_night = bool(tm.get("is_night"))
			var sun_ang = tm.get("sun_angle")
			var sh_int = float(tm.get("shadow_intensity"))
			if sh_int > 0.05:
				var sh_col = Color(0, 0, 0, 0.4 * sh_int)
				if is_night: sh_col = Color(0.1, 0.1, 0.3, 0.5 * sh_int)
				
				# Directional shadow
				var h = 30.0
				var w = 16.0
				var dx = sun_ang.x * h
				var pts = PackedVector2Array([
					Vector2(-w/2, 0),
					Vector2(w/2, 0),
					Vector2(w/2 + dx, -h * 0.3),
					Vector2(-w/2 + dx, -h * 0.3)
				])
				draw_colored_polygon(pts, sh_col)
				
				# Contact shadow
				draw_circle(Vector2(0, 0), w/1.5, Color(0,0,0,0.5))
