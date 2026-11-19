class_name Asset

extends StaticBody3D

var element: Element = Element.new()
var assetName: String
var value: int
var overlay: StandardMaterial3D # This is the material where the color will display
var label: Label3D # Label that contains the asset's information

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	element.currentState = randi_range(0, 7) # Randomize element
	
	# Initialize the information and making it invisible
	assetName = name
	value = randi() % 100
	label = $Label3D
	label.visible = false
	
	# Creating the overlay
	overlay = StandardMaterial3D.new()
	
	# Setting the transparency of this material to be the same as the alpha of the albedo_color
	overlay.albedo_color = Color(0, 0, 0, 0)
	overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA 
	
	$MeshInstance3D.material_overlay = overlay


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Toggle vision mode
	if Input.is_action_just_pressed("vision") and !Global.isPaused:
		elementalVision()
	pass

# Toggle vision mode
func elementalVision():
	# Make hidden information visible when entering vision mode
	if Global.vision:
		update_information()
		label.visible = true
		
	# Hide information when leaving vision mode
	else:
		overlay.albedo_color = Color(0, 0, 0, 0)
		label.visible = false

# Change the assets element
func change_element(newElement: Element):
	element.currentState = newElement.currentState
	
# Update the material and label information
func update_information():
	# Changing the color of the material overlay
	overlay.albedo_color = element.get_color()
		
	# Making label information
	var text = "Name: %s \n" % assetName
	text += "Element: %s \n" % Element.State.keys()[element.currentState]
	text += "Value: %s" % value
	label.text = text
