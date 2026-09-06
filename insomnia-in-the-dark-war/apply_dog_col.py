import os
path = 'scripts/merchant_dog.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s = '''func _ready() -> void:
	add_to_group("merchant_dog")'''
r = '''func _ready() -> void:
	add_to_group("merchant_dog")
	collision_layer = 16 # Layer 5 (NPC)
	collision_mask = 1   # Mask 1 (Player)'''
content = content.replace(s, r)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
