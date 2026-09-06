import re, os

def read_file(path):
    with open(path, 'r', encoding='utf-8') as f: return f.read()

def write_file(path, content):
    with open(path, 'w', encoding='utf-8') as f: f.write(content)

# 1. level_setup.gd
path = 'scripts/level_setup.gd'
if os.path.exists(path):
    content = read_file(path)
    content = re.sub(r'var _spawn_zombies:\s*Array\s*=\s*\[\]\n', '', content)
    content = content.replace('_spawn_zombies', '_spawned_zombies')
    write_file(path, content)

# 2. hud.gd
path = 'scripts/hud.gd'
if os.path.exists(path):
    content = read_file(path)
    # The tween logic was already addressed previously, but we ensure it's there.
    # We will remove solar_bar / clock dead code.
    content = re.sub(r'var solar_bar.*?\n', '', content)
    content = re.sub(r'func _on_solar_changed.*?(?=\nfunc )', '', content, flags=re.DOTALL)
    content = re.sub(r'if solar_bar != null.*?(?=\n\t\S|\n\S)', '', content, flags=re.DOTALL)
    write_file(path, content)

# 3. audio_manager.gd
path = 'scripts/audio_manager.gd'
if os.path.exists(path):
    content = read_file(path)
    content = re.sub(r'func _process.*?(?=\nfunc )', '', content, flags=re.DOTALL)
    if 'bgm_day.finished.connect' not in content:
        content = content.replace('bgm_day.play()', 'bgm_day.play()\n\t\t\tbgm_day.finished.connect(bgm_day.play)')
        content = content.replace('bgm_night.play()', 'bgm_night.play()\n\t\t\tbgm_night.finished.connect(bgm_night.play)')
    
    # Audio pooling for SFX
    if 'player.stream = stream' in content and 'sfx_pool[sfx_name] = player' in content:
        pooling_code = '''
	var pool = sfx_pool.get(sfx_name, [])
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
        content = re.sub(r'func play_sfx.*?\(sfx_name.*?-> void:.*?(?=\nfunc )', 'func play_sfx(sfx_name: String, pos: Vector2 = Vector2.ZERO) -> void:' + pooling_code, content, flags=re.DOTALL)
    write_file(path, content)

# 4. art_cabin_props.gd
path = 'scripts/art_cabin_props.gd'
if os.path.exists(path):
    content = read_file(path)
    if 'var _level_setup' not in content:
        content = content.replace('func _ready() -> void:', 'var _level_setup = null\nfunc _ready() -> void:\n\t_level_setup = get_node_or_null("/root/LevelSetup")')
        content = content.replace('get_node("/root/LevelSetup")', '_level_setup')
    write_file(path, content)

# 5. mailbox_manager.gd
path = 'scripts/mailbox_manager.gd'
if os.path.exists(path):
    content = read_file(path)
    content = re.sub(r'func _process.*?(?=\nfunc )', '', content, flags=re.DOTALL)
    if '_grant_rewards(gifts)' in content and 'target_letter["gift_claimed"] = true' not in content:
        content = content.replace('_grant_rewards(gifts)', 'target_letter["gift_claimed"] = true\n\t\t\t_grant_rewards(gifts)')
    write_file(path, content)

# 6. game_state.gd
path = 'scripts/game_state.gd'
if os.path.exists(path):
    content = read_file(path)
    if 'miracle_watering_can' not in content:
        relic_logic = '''
	if type == "miracle_watering_can":
		plant_harvest_bonus += 1
	elif type == "chromium_ak_barrel":
		turret_damage_multiplier += 0.25
	elif type == "night_vision_relic":
		turret_damage_multiplier += 0.25
'''
        content = content.replace('if relics_found.has(type):', 'if relics_found.has(type):\n\t\treturn\n\trelics_found.append(type)\n' + relic_logic)
    write_file(path, content)

# 7. camera_lofi.gd
path = 'scripts/camera_lofi.gd'
if os.path.exists(path):
    content = read_file(path)
    content = re.sub(r'if _player == null:.*?get_first_node_in_group.*?\n', '', content, flags=re.DOTALL)
    write_file(path, content)

print("Automated Python Script executed.")
