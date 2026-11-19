extends Node

var vision: bool = false # Other scripts use this to know if vision is on or off
var label: Label

func _ready() -> void:
	label = $"../Control/VisionText"
	label.text = "Vision: %s" % vision
	
func _process(delta: float) -> void:
	# Turn vision on or off on button press
	if Input.is_action_just_pressed("vision"):
		vision = !vision
		label.text = "Vision: %s" % vision
