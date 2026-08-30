extends Area2D

func _ready() -> void:
	add_to_group("safe_zone")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	print("Vào vùng an toàn")
