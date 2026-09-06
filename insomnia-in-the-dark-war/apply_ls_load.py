import os
path = 'scripts/level_setup.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s = '''	if data.has("current_night_mutation"):
		current_night_mutation = str(data["current_night_mutation"])
	update_merchant_dog_visibility()'''
r = '''	if data.has("current_night_mutation"):
		current_night_mutation = str(data["current_night_mutation"])
	update_merchant_dog_visibility()
	_update_ground_state_from_weather()'''
content = content.replace(s, r)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
