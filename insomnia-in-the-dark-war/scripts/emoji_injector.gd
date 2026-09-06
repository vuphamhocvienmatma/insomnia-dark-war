extends Node
func _ready():
	var emoji_font = preload("res://assets/fonts/NotoColorEmoji.ttf")
	if emoji_font != null:
		var fallbacks = ThemeDB.fallback_font.fallbacks
		if not emoji_font in fallbacks:
			fallbacks.append(emoji_font)
			ThemeDB.fallback_font.fallbacks = fallbacks
