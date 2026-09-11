extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var ground_y: float = 0.0

var left_margin: float = 80.0
var right_margin: float = 80.0

enum MovementState {
	IDLE,
	WALKING,
	RUNNING,
	SLEEPING
}

var movement_state: MovementState = MovementState.IDLE

var direction: float = 1.0

var walk_speed: float = 45.0
var run_speed: float = 100.0

var behavior_timer: float = 0.0
var next_behavior_time: float = 3.0

var idle_timer: float = 0.0

var min_behavior_time: float = 3.0
var max_behavior_time: float = 8.0
  
var lookaround_timer: float = 0.0
var lookaround_min_time: float = 10.0
var lookaround_max_time: float = 30.0

var next_lookaround_time: float = 15.0

var yawn_timer: float = 0.0
var yawn_time: float = 60.0

var sleeping: bool = false

var sleep_min_time: float = 20.0
var sleep_max_time: float = 40.0

var sleep_timer: float = 0.0
var sleep_duration: float = 30.0

var playing_special_animation: bool = false

var height: float = 0.0
var max_jump_height: float = 30.0

var is_jumping: bool = false
var jump_time: float = 0.0
var jump_duration: float = 0.8

func _ready() -> void:

	randomize()

	ground_y = get_viewport_rect().size.y - 100.0

	position = Vector2(
		get_viewport_rect().size.x / 2.0,
		ground_y
	)

	direction = 1.0

	next_behavior_time = randf_range(
		min_behavior_time,
		max_behavior_time
	)

	next_lookaround_time = randf_range(
		lookaround_min_time,
		lookaround_max_time
	)

	play_animation("idle")

	print("KNIGHT READY")

func play_animation(animation_name: String) -> void:

	if sprite == null:
		return

	if not sprite.sprite_frames.has_animation(animation_name):
		print("WARNING: Knight is missing animation: ", animation_name)
		return

	if sprite.animation == animation_name and sprite.is_playing():
		return

	sprite.play(animation_name)

func play_special_animation(animation_name: String) -> void:

	if sprite == null:
		return

	if not sprite.sprite_frames.has_animation(animation_name):
		print("WARNING: Knight is missing animation: ", animation_name)
		return

	playing_special_animation = true

	sprite.play(animation_name)

func _on_animation_finished() -> void:

	if sprite == null:
		return

	if sprite.animation == "lookaround":

		playing_special_animation = false

		lookaround_timer = 0.0

		next_lookaround_time = randf_range(
			lookaround_min_time,
			lookaround_max_time
		)

		play_animation("idle")

		return

	if sprite.animation == "yawn":

		playing_special_animation = false

		yawn_timer = 0.0

		play_animation("idle")

		return

	if sprite.animation == "go2sleep":

		playing_special_animation = false

		sleeping = true

		movement_state = MovementState.SLEEPING

		sleep_timer = 0.0

		play_animation("sleep")

		return

	if sprite.animation == "wakeup2idle":

		playing_special_animation = false

		sleeping = false

		movement_state = MovementState.IDLE

		behavior_timer = 0.0

		idle_timer = 0.0

		play_animation("idle")

		return

	if sprite.animation == "jump":

		if not is_jumping:
			update_movement_animation()

		return

func start_jump() -> void:

	if is_jumping:
		return

	if sleeping:
		wake_up()

		return

	if playing_special_animation:
		return

	is_jumping = true
	jump_time = 0.0

	play_animation("jump")

func wake_up() -> void:

	if not sleeping:
		return

	sleeping = false

	sleep_timer = 0.0

	playing_special_animation = true

	play_animation("wakeup2idle")

func choose_new_behavior() -> void:

	behavior_timer = 0.0

	next_behavior_time = randf_range(
		min_behavior_time,
		max_behavior_time
	)

	var roll := randf()

	if roll < 0.25:

		movement_state = MovementState.IDLE

		return

	if roll < 0.70:

		movement_state = MovementState.WALKING

		if randf() < 0.5:
			direction *= -1.0

		return

	movement_state = MovementState.RUNNING

	if randf() < 0.5:
		direction *= -1.0

func _process(delta: float) -> void:

	if is_jumping:

		jump_time += delta

		var jump_progress := jump_time / jump_duration

		if jump_progress >= 1.0:

			jump_progress = 1.0
			is_jumping = false

		height = (
			sin(jump_progress * PI)
			* max_jump_height
		)

	else:

		height = 0.0

	if sleeping:

		sleep_timer += delta

		if sleep_timer >= sleep_duration:

			wake_up()

		update_position()

		return

	if playing_special_animation:

		update_position()

		return

	behavior_timer += delta


	if behavior_timer >= next_behavior_time:

		choose_new_behavior()

	if movement_state == MovementState.IDLE:

		idle_timer += delta
		lookaround_timer += delta
		yawn_timer += delta

	else:

		idle_timer = 0.0
		lookaround_timer = 0.0
		yawn_timer = 0.0

	if movement_state == MovementState.IDLE:

		if lookaround_timer >= next_lookaround_time:

			play_special_animation("lookaround")

			update_position()

			return

	if movement_state == MovementState.IDLE:

		if yawn_timer >= yawn_time:

			play_special_animation("yawn")

			update_position()

			return

	if movement_state == MovementState.IDLE:

		if idle_timer >= 15.0:

			if randf() < 0.01:

				play_special_animation("go2sleep")

				update_position()

				return

	match movement_state:

		MovementState.IDLE:

			pass


		MovementState.WALKING:

			position.x += (
				direction
				* walk_speed
				* delta
			)


		MovementState.RUNNING:

			position.x += (
				direction
				* run_speed
				* delta
			)

	var screen_width := get_viewport_rect().size.x

	var left_edge := left_margin
	var right_edge := screen_width - right_margin


	if position.x <= left_edge:

		position.x = left_edge
		direction = 1.0


	if position.x >= right_edge:

		position.x = right_edge
		direction = -1.0

	update_movement_animation()

	update_position()

func update_movement_animation() -> void:

	if sprite == null:
		return

	if playing_special_animation:
		return

	if is_jumping:
		return

	if sleeping:
		return


	match movement_state:

		MovementState.IDLE:

			play_animation("idle")


		MovementState.WALKING:
			play_animation("walk2run")


		MovementState.RUNNING:

			play_animation("run")


		MovementState.SLEEPING:

			play_animation("sleep")

func update_position() -> void:

	var screen_height := get_viewport_rect().size.y

	ground_y = screen_height - 100.0

	position.y = ground_y - height

	if sprite:

		if direction > 0.0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true

func _input(event: InputEvent) -> void:

	if event is InputEventKey:

		if event.pressed and not event.echo:

			if event.keycode == KEY_ENTER:

				start_jump()
