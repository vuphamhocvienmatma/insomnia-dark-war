extends SceneTree

func _init():
	var emoji_font = FontFile.new()
	emoji_font.load_dynamic_font("res://assets/fonts/NotoColorEmoji.ttf")
	ResourceSaver.save(emoji_font, "res://assets/fonts/NotoColorEmoji.tres")

	var main_font = FontFile.new()
	main_font.load_dynamic_font("res://assets/fonts/CourierPrime.ttf")
	main_font.fallbacks.append(emoji_font)
	ResourceSaver.save(main_font, "res://assets/fonts/MainFont.tres")
	
	var theme = Theme.new()
	theme.default_font = main_font
	ResourceSaver.save(theme, "res://assets/theme.tres")
	
	print("Resources created successfully.")
	quit()
