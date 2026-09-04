extends Node

signal decorations_changed(cozy_score: int)

var unlocked_decorations: Dictionary = {
	"cozy_rug": false,
	"disco_ball": false,
	"retro_poster": false,
	"pastel_lights": false,
	"bp_radio": false,
	"bp_stove": false,
	"bp_greenhouse": false,
	"tape_rainy": false
}

var cozy_score: int = 0
var light_color_theme: String = "warm_gold" # "warm_gold", "pastel_pink", "cyan_neon"


func _ready() -> void:
	calculate_cozy_score()


func unlock_item(item_id: String) -> void:
	unlocked_decorations[item_id] = true
	if item_id == "pastel_lights":
		light_color_theme = "pastel_pink"
	calculate_cozy_score()

	# If greenhouse unlocked, tell level setup to add greenhouse pots!
	if item_id == "bp_greenhouse":
		var ls: Node = get_tree().root.find_child("LevelSetup", true, false)
		if ls != null and ls.has_method("spawn_greenhouse_pots"):
			ls.call("spawn_greenhouse_pots")


func calculate_cozy_score() -> int:
	var score: int = 0
	if unlocked_decorations.get("cozy_rug", false):
		score += 20
	if unlocked_decorations.get("disco_ball", false):
		score += 25
	if unlocked_decorations.get("retro_poster", false):
		score += 15
	if unlocked_decorations.get("pastel_lights", false):
		score += 20
	if unlocked_decorations.get("bp_radio", false):
		score += 10
	if unlocked_decorations.get("bp_stove", false):
		score += 15
	if unlocked_decorations.get("bp_greenhouse", false):
		score += 15

	cozy_score = score
	decorations_changed.emit(cozy_score)
	return cozy_score


func get_cat_speed_bonus() -> float:
	return 1.20 if cozy_score >= 40 else 1.0


func has_radio() -> bool:
	return unlocked_decorations.get("bp_radio", false)


func has_super_stove() -> bool:
	return unlocked_decorations.get("bp_stove", false)
