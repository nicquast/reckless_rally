extends Label

@export
var car_object: Car


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if car_object != null:
		text = "RPM: %02d" % car_object.rpm
