extends Node

var vision: bool = false # Other scripts use this to know if vision is on or off
var label: Label

var isPaused: bool = false

func _ready() -> void:
	label = $"/root/Node3D/Control/VisionText"
	label.text = "Vision: %s" % vision
	
func _process(delta: float) -> void:
	# Turn vision on or off on button press
	if Input.is_action_just_pressed("vision") and !isPaused:
		vision = !vision
		label.text = "Vision: %s" % vision


func _on_character_toggle_paused(_isPaused: bool) -> void:
	isPaused = _isPaused
	print(isPaused)
