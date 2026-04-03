extends Control

const MAX_ROTATION_DEG: float = 135
const MAX_ROTATION_RAD := deg_to_rad(MAX_ROTATION_DEG)

@export var rotation_speed = TAU * 2.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var steer_left_strength = Input.get_action_strength("Steer Left")
	var steer_right_strength = Input.get_action_strength("Steer Right")

	var wheel_centered = $Wheel.rotation == 0
	var no_key_input = steer_left_strength == 0 and steer_right_strength == 0
	if wheel_centered and no_key_input:
		return

	var steer_right_rad = steer_right_strength * MAX_ROTATION_RAD
	var steer_left_rad = steer_left_strength * MAX_ROTATION_RAD
	var steer_rad = steer_right_rad - steer_left_rad

	# ignore input when rotating non-centered wheel in the opposite direction
	# otherwise `rotate_toward` will wrap-around max rotation
	if steer_rad * $Wheel.rotation < 0:
		steer_rad = 0

	var new_rotation = rotate_toward(
		$Wheel.rotation,
		steer_rad,
		rotation_speed * delta
	)

	$Wheel.rotation = new_rotation
