extends VehicleBody3D

@export
var center_of_mass_node:Node3D

@export
var power = 100

@export
var steering_limit = deg_to_rad(30)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if center_of_mass_node != null:
		center_of_mass = center_of_mass_node.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var acceleration = Input.get_action_strength("Accelerate")
	var braking_input = Input.get_action_strength("Brake")
	
	var steering_input = Input.get_action_strength("Steer Left") - Input.get_action_strength("Steer Right")
	steering = move_toward(steering, steering_input * steering_limit, delta)
	
	engine_force = acceleration * power
	
	print_debug(engine_force)
	brake = braking_input 
