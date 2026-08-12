extends Node2D


func _draw() -> void:
	draw_rect(
		Rect2(-6, -20, 12, 40),
		Color(0.45, 0.25, 0.1)
	)

	draw_circle(
		Vector2(0, -30),
		22.0,
		Color(0.1, 0.6, 0.2)
	)
