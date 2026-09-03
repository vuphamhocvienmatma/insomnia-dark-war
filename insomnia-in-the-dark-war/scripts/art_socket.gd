extends Node2D

const SOCKET_COL: Color = Color(0.85, 0.72, 0.45, 0.4)
const PEG_COL: Color = Color(0.35, 0.25, 0.18, 0.7)

func _draw() -> void:
	var half: float = 12.0
	draw_circle(Vector2.ZERO, 3.0, PEG_COL)
	var corners: Array[Vector2] = [
		Vector2(-half, -half), Vector2(half, -half),
		Vector2(half, half), Vector2(-half, half)
	]
	for i in 4:
		var a: Vector2 = corners[i]
		var b: Vector2 = corners[(i + 1) % 4]
		var d: Vector2 = b - a
		draw_line(a, a + d * 0.35, SOCKET_COL, 1.5)
		draw_line(a + d * 0.65, b, SOCKET_COL, 1.5)
