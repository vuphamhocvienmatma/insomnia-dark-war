extends SceneTree
func _init():
	var emoji_font = load("res://assets/fonts/NotoColorEmoji.ttf")
	ThemeDB.fallback_font.fallbacks.append(emoji_font)
	print("Fallbacks count: ", ThemeDB.fallback_font.fallbacks.size())
	quit()
