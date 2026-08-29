extends Node2D

const SOCKET_COL := Color(0.3, 0.8, 1.0, 0.7)

func _draw() -> void:
	var half := 12.0
	var corners: Array[Vector2] = [
		Vector2(-half, -half), Vector2(half, -half),
		Vector2(half, half), Vector2(-half, half)
	]
	for i in 4:
		var a: Vector2 = corners[i]
		var b: Vector2 = corners[(i + 1) % 4]
		var d: Vector2 = b - a
		draw_line(a, a + d * 0.35, SOCKET_COL, 2.0)
		draw_line(a + d * 0.65, b, SOCKET_COL, 2.0)
