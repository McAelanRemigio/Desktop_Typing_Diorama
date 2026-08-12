extends Node2D


func _ready() -> void:

	print("WORLD VISUAL READY")


func _draw() -> void:

	draw_circle(
		Vector2.ZERO,
		200.0,
		Color.WHITE
	)
