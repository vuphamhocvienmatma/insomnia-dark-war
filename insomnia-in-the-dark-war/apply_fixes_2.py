import re, os

# Try pooling logic again for Audio Manager since the previous regex failed
path = 'scripts/audio_manager.gd'
if os.path.exists(path):
    with open(path, 'r', encoding='utf-8') as f: content = f.read()
    
    pooling_code = '''func play_sfx(sfx_name: String, pos: Vector2 = Vector2.ZERO) -> void:
	var pool: Array = sfx_pool.get(sfx_name, [])
	var player: AudioStreamPlayer = null
	for p in pool:
		if not p.playing:
			player = p
			break
	if player == null:
		player = AudioStreamPlayer.new()
		add_child(player)
		pool.append(player)
		sfx_pool[sfx_name] = pool
	var sfx_path: String = "res://assets/sfx/" + sfx_name + ".ogg"
	if not ResourceLoader.exists(sfx_path):
		sfx_path = "res://assets/sfx/" + sfx_name + ".wav"
	if ResourceLoader.exists(sfx_path):
		var stream: AudioStream = load(sfx_path) as AudioStream
		if stream != null:
			player.stream = stream
			player.play()
'''
    content = re.sub(r'func play_sfx.*?\(sfx_name.*', pooling_code, content, flags=re.DOTALL)
    
    with open(path, 'w', encoding='utf-8') as f: f.write(content)

print("Audio Pooling applied")
