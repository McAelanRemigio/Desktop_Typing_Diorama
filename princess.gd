
extends Node2D
@onready var sphere: Node2D = get_parent()

@onready var typing_manager: Node = get_parent().get_parent().get_parent().get_node("TypingManager")

var radius: float = 200.0

var knight_local_angle: float:
	get:
		return (-PI / 2.0) - sphere.rotation

var normal_offset: float = 0.18

var knight_zone: float = 0.28

var ahead_limit: float = -0.28

var behind_limit: float = 0.28

var local_angle: float = 0.0

var angle: float = 0.0

var speed: float = 0.0

var normal_run_speed: float = 0.32
var happy_run_speed: float = 0.40
var tired_run_speed: float = 0.12

enum BehaviorState {
	WITH_KNIGHT,
	HAPPY_AHEAD,
	FALLING_BEHIND,
	EXHAUSTED,
	RETURNING
}

var behavior_state: BehaviorState = BehaviorState.WITH_KNIGHT

enum MovementState {
	IDLE,
	RUNNING,
	TIRED,
	EXHAUSTED
}

var movement_state: MovementState = MovementState.IDLE

var max_stamina: float = 25.0
var stamina: float = 25.0

var normal_stamina_drain: float = 2.5
var happy_stamina_drain: float = 4.0

var tired_threshold: float = 10.0

var stamina_recovery: float = 8.0
var recovery_threshold: float = 20.0

var exhausted_timer: float = 0.0
var minimum_ground_time: float = 8.0

var ready_to_return: bool = false

var happy_timer: float = 0.0
var happy_duration: float = 2.5

var happy_check_timer: float = 0.0
var happy_check_interval: float = 5.0

var height: float = 0.0
var max_jump_height: float = 30.0

var is_jumping: bool = false
var jump_time: float = 0.0
var jump_duration: float = 0.8
var jump_progress: float = 0.0

var idle_timer: float = 0.0
var idle_wait_time: float = 8.0

var near_knight: bool = false

func _ready() -> void:

	local_angle = knight_local_angle + normal_offset

	angle = local_angle

	stamina = max_stamina

	behavior_state = BehaviorState.WITH_KNIGHT
	movement_state = MovementState.IDLE

	speed = 0.0

	idle_wait_time = randf_range(6.0, 12.0)

	queue_redraw()

func start_jump() -> void:

	if is_jumping:
		return

	if behavior_state == BehaviorState.EXHAUSTED:
		return

	is_jumping = true
	jump_time = 0.0
	jump_progress = 0.0

func try_idle_behavior() -> void:

	if behavior_state != BehaviorState.WITH_KNIGHT:
		return

	if is_jumping:
		return

	start_jump()

	idle_timer = 0.0
	idle_wait_time = randf_range(6.0, 12.0)

func _process(delta: float) -> void:

	var typing_activity: float = 0.0

	if typing_manager != null:
		typing_activity = typing_manager.typing_activity

	if typing_activity <= 0.01:

		idle_timer += delta

	else:

		idle_timer = 0.0

	if behavior_state == BehaviorState.WITH_KNIGHT:

		movement_state = MovementState.RUNNING

		speed = 0.0

		local_angle = knight_local_angle + normal_offset

		if typing_activity > 0.01:

			stamina -= normal_stamina_drain * delta

			stamina = clamp(
				stamina,
				0.0,
				max_stamina
			)

			happy_check_timer += delta

			if happy_check_timer >= happy_check_interval:

				happy_check_timer = 0.0

				if randf() < 0.20:

					behavior_state = BehaviorState.HAPPY_AHEAD
					happy_timer = 0.0


			# Become tired.
			if stamina <= tired_threshold:

				behavior_state = BehaviorState.FALLING_BEHIND

		if typing_activity <= 0.01:

			if idle_timer >= idle_wait_time:

				try_idle_behavior()

	elif behavior_state == BehaviorState.HAPPY_AHEAD:

		movement_state = MovementState.RUNNING

		happy_timer += delta

		stamina -= happy_stamina_drain * delta

		stamina = clamp(
			stamina,
			0.0,
			max_stamina
		)

		local_angle -= happy_run_speed * delta


		var ahead_distance: float = wrapf(
			local_angle - knight_local_angle,
			-PI,
			PI
		)


		if ahead_distance <= ahead_limit:

			local_angle = knight_local_angle + ahead_limit

		if happy_timer >= happy_duration:

			behavior_state = BehaviorState.RETURNING


		# Low stamina overrides excitement.
		if stamina <= tired_threshold:

			behavior_state = BehaviorState.FALLING_BEHIND

	elif behavior_state == BehaviorState.FALLING_BEHIND:

		movement_state = MovementState.TIRED


		stamina -= normal_stamina_drain * delta

		stamina = clamp(
			stamina,
			0.0,
			max_stamina
		)


		var stamina_ratio: float = stamina / tired_threshold

		stamina_ratio = clamp(
			stamina_ratio,
			0.0,
			1.0
		)

		var current_tired_speed: float = lerp(
			0.02,
			tired_run_speed,
			stamina_ratio
		)

		local_angle += current_tired_speed * delta


		var behind_distance: float = wrapf(
			local_angle - knight_local_angle,
			-PI,
			PI
		)


		if behind_distance >= behind_limit:

			local_angle = knight_local_angle + behind_limit

		if stamina <= 0.0:

			stamina = 0.0

			behavior_state = BehaviorState.EXHAUSTED
			movement_state = MovementState.EXHAUSTED

			speed = 0.0

			exhausted_timer = 0.0
			ready_to_return = false

	elif behavior_state == BehaviorState.EXHAUSTED:

		movement_state = MovementState.EXHAUSTED

		speed = 0.0

		stamina += stamina_recovery * delta

		stamina = clamp(
			stamina,
			0.0,
			max_stamina
		)


		exhausted_timer += delta

		if exhausted_timer >= minimum_ground_time:

			if stamina >= recovery_threshold:

				ready_to_return = true


		if ready_to_return:

			var exhausted_distance: float = abs(
				wrapf(
					local_angle - knight_local_angle,
					-PI,
					PI
				)
			)


			if exhausted_distance <= knight_zone:

				behavior_state = BehaviorState.RETURNING
				movement_state = MovementState.TIRED

	elif behavior_state == BehaviorState.RETURNING:

		movement_state = MovementState.TIRED


		var target_angle: float = (
			knight_local_angle +
			normal_offset
		)


		var return_difference: float = wrapf(
			target_angle - local_angle,
			-PI,
			PI
		)


		var return_speed: float = 0.16

		if return_difference > 0.0:

			local_angle += return_speed * delta

		elif return_difference < 0.0:

			local_angle -= return_speed * delta


		var remaining_distance: float = abs(
			wrapf(
				target_angle - local_angle,
				-PI,
				PI
			)
		)


		if remaining_distance <= 0.05:

			local_angle = target_angle

			behavior_state = BehaviorState.WITH_KNIGHT
			movement_state = MovementState.RUNNING

			speed = 0.0

			ready_to_return = false

			idle_timer = 0.0
			idle_wait_time = randf_range(6.0, 12.0)

	angle = local_angle

	if is_jumping:

		jump_time += delta

		jump_progress = jump_time / jump_duration


		if jump_progress >= 1.0:

			jump_progress = 1.0
			is_jumping = false


		height = (
			sin(jump_progress * PI)
			* max_jump_height
		)

	else:

		jump_progress = 0.0
		height = 0.0

	var radial_direction: Vector2 = Vector2(
		cos(angle),
		sin(angle)
	)


	position = radial_direction * (
		radius + height
	)

	var proximity_difference: float = wrapf(
		knight_local_angle - local_angle,
		-PI,
		PI
	)


	near_knight = abs(
		proximity_difference
	) <= knight_zone


	queue_redraw()

func _draw() -> void:

	var display_size: float = 12.0


	if movement_state == MovementState.RUNNING:

		display_size = 14.0

	elif movement_state == MovementState.TIRED:

		display_size = 13.0

	elif movement_state == MovementState.EXHAUSTED:

		display_size = 11.0


	# Placeholder for future personality behavior.
	if near_knight:

		display_size = 20.0


	draw_circle(
		Vector2.ZERO,
		display_size,
		Color.GREEN
	)
