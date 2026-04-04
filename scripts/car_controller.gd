class_name Car extends VehicleBody3D

## If set will set the center of mass to the position of the given node
@export var center_of_mass_node:Node3D

## Defines the limit of wheel rotation for steering in radians
@export var steering_limit = deg_to_rad(30)

## Defines the speed at which the front wheels will rotate to the selected angle
@export var steering_speed = 2.5

## Defines the amount of power produced by the car as a function of RPM
@export var power_curve: Curve

## Defines the amount of braking pressure applied as a function of the brake input axis
@export var brake_pressure_curve: Curve

## Redline rpm
@export var max_rpm = 8000

## Multiplication factor for determining rpm acceleration
@export var throttle_multiplier = 800

## When letting off the accelerator defines how much rpm drops as a function of rpm
@export var rpm_damping_curve: Curve

## Aero drag coefficient for calculating RPM load
@export var drag_coefficient = 0.6

## 3d Audio Player with Engine Sound
@export var engine_sound_loop: AudioStream

@export var max_sound_pitch: float = 5.0

var engine_audio_player: AudioStreamPlayer3D

var rpm = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if center_of_mass_node != null:
		center_of_mass = center_of_mass_node.position
	
	# Setup audio player
	engine_audio_player = AudioStreamPlayer3D.new()
	engine_audio_player.stream = engine_sound_loop
	add_child(engine_audio_player)
	engine_audio_player.play()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var acceleration_input = Input.get_action_strength("Accelerate")
	var braking_input = Input.get_action_strength("Brake")
	var steering_input = Input.get_action_strength("Steer Left") - Input.get_action_strength("Steer Right")
	
	# Simplified rpm acceleration calculation clamp to values over 0 - this definitely needs some work...
	var rpm_acceleration = throttle_multiplier * acceleration_input * (1.0-(rpm/max_rpm))
	if acceleration_input == 0.0:
		rpm_acceleration = -rpm_damping_curve.sample(rpm)
	
	#apply rpm acceleration and clamp rpm between 0 and redline
	rpm += rpm_acceleration * delta
	rpm = clamp(rpm, 0, max_rpm)
	
	# set rpm to 0 if linear velocity is 0 and we are braking (this probably won't work great...)
	if (brake > 0 and linear_velocity.length() == 0):
		rpm = 0
	
	# Simulate moving a wheel by slowly transitioning from current steering angle to input steering angle
	steering = move_toward(steering, steering_input * steering_limit, delta * steering_speed)
	
	engine_force = power_curve.sample(rpm)
	brake = brake_pressure_curve.sample(braking_input * brake_pressure_curve.max_domain)
	
	if Input.is_action_just_pressed("Handbrake"):
		activate_handbrake()
	
	if Input.is_action_just_released("Handbrake"):
		deactivate_handbrake()
	
	adjust_engine_pitch()
	
func rpm_load_factor():
	return (linear_velocity.length() * drag_coefficient)

func activate_handbrake():
	$"Back Left Wheel".wheel_friction_slip /= 2
	$"Back Right Wheel".wheel_friction_slip /= 2
	
	$"Front Left Wheel".wheel_friction_slip *= 2
	$"Front Right Wheel".wheel_friction_slip *= 2
func deactivate_handbrake():
	$"Back Left Wheel".wheel_friction_slip *= 2
	$"Back Right Wheel".wheel_friction_slip *= 2
	
	$"Front Left Wheel".wheel_friction_slip /= 2
	$"Front Right Wheel".wheel_friction_slip /= 2
	
func adjust_engine_pitch():
	engine_audio_player.pitch_scale = lerpf(1, max_sound_pitch, (rpm/max_rpm))
	
	
