extends Node2D

@onready var sphere: Node2D = $Sphere
@onready var lp: Node2D = $Sphere/LP

# TypingManager is a sibling of World under Main.
@onready var typing_manager: Node = get_parent().get_node("TypingManager")

var rotation_speed: float = 0.0
var target_rotation_speed: float = 0.0

var max_rotation_speed: float = 1.5
var acceleration: float = 2.0
var deceleration: float = 0.3

var planet_rotation: float = 0.0

func _ready() -> void:

	print("WORLD READY")

	if typing_manager != null:
		print("TypingManager connected successfully.")
	else:
		print("WARNING: TypingManager NOT found.")

func _process(delta: float) -> void:

	var typing_activity: float = 0.0

	if typing_manager != null:
		typing_activity = typing_manager.typing_activity

	target_rotation_speed = (
		typing_activity *
		max_rotation_speed
	)

	if rotation_speed < target_rotation_speed:

		rotation_speed = move_toward(
			rotation_speed,
			target_rotation_speed,
			acceleration * delta
		)

	else:

		rotation_speed = move_toward(
			rotation_speed,
			target_rotation_speed,
			deceleration * delta
		)

	planet_rotation += rotation_speed * delta

	sphere.rotation = planet_rotation

func _input(event: InputEvent) -> void:

	if event is InputEventKey:

		if event.pressed and not event.echo:

			if event.keycode == KEY_SPACE:

				if lp != null:

					lp.start_jump()
