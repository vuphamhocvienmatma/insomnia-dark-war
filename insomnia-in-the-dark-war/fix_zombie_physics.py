import os
path = 'scripts/zombie_ai.gd'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

s = '''func _physics_process(_delta: float) -> void:
	queue_redraw()
	queue_redraw()
func _physics_process_actual(_delta: float) -> void:'''
r = '''func _physics_process(_delta: float) -> void:
	queue_redraw()'''
content = content.replace(s, r)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
