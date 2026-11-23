class_name PickupItem
extends RigidBody3D
# The player body must be in the "player" group.

## The 2D InventoryItem scene for the grid inventory
@export var inventory_item_scene: PackedScene   
## Prevents instant pickup the moment it spawns
@export var pickup_delay: float = 0.5           

@onready var pickup_area: Area3D = $PickupArea

@export_group("Float Animation")
## Resting height above the body
@export var hover_height: float = 0.25          
 ## How far it moves up and down
@export var bob_amount: float = 0.1            
@export var bob_speed: float = 2.0
@export var spin_speed: float = 1.5             

@onready var visual: Node3D = $Visual
@onready var mesh: MeshInstance3D = $Visual/MeshInstance3D
@onready var label: Label3D = $Label3D # Label that contains the pickup's information

var element: Element = Element.new()
var assetName: String
var value: int
var overlay: StandardMaterial3D # This is the material where the color will display

var _time: float = 0.0



func _ready() -> void:
	
	# Keep the body upright so it doesn't tumble; only the visual spins
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true
	
	# Initialize the information and making it invisible
	label.visible = false
	
	# Creating the overlay
	overlay = StandardMaterial3D.new()
	
	# Setting the transparency of this material to be the same as the alpha of the albedo_color
	overlay.albedo_color = Color(0, 0, 0, 0)
	overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	mesh.material_overlay = overlay
	
	pickup_area.monitoring = false
	pickup_area.body_entered.connect(_on_body_entered)
	get_tree().create_timer(pickup_delay).timeout.connect(_enable_pickup)

func _process(delta: float) -> void:
	
	# slowly bob, rotate
	_time += delta
	visual.rotate_y(spin_speed * delta)
	visual.position.y = hover_height + sin(_time * bob_speed) * bob_amount
	
	# Toggle vision mode
	if Input.is_action_just_pressed("vision") and !Global.isPaused:
		elementalVision()

# Called by the Asset that dropped this pickup so it keeps the same information
func set_values(newElement: Element, newName: String, newValue: int) -> void:
	element.currentState = newElement.currentState
	assetName = newName
	value = newValue
	
	# If vision is already on when this is dropped, show the information right away
	if Global.vision:
		elementalVision()

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

# Update the material and label information
func update_information():
	# Changing the color of the material overlay
	overlay.albedo_color = element.get_color()
		
	# Making label information
	var text = "Name: %s \n" % assetName
	text += "Element: %s \n" % Element.State.keys()[element.currentState]
	text += "Value: %s" % value
	label.text = text

func _enable_pickup() -> void:
	pickup_area.monitoring = true
	# Catch bodies already standing inside the area when it turned on
	for body in pickup_area.get_overlapping_bodies():
		_on_body_entered(body)

func _on_body_entered(body: Node3D) -> void:
	if not is_inside_tree() or not body.is_in_group("player"):
		return
	if inventory_item_scene == null:
		push_warning("%s has no inventory_item_scene assigned." % name)
		return

	var manager := PlayerManagerInventory.playerManagerInventory
	# No manager in the scene, or the cursor is already holding an item: leave this in the world
	if manager == null or manager.isHoldingItem:
		return

	var item := inventory_item_scene.instantiate() as InventoryItem
	manager.PickupSpawnedItem(item)
	queue_free()
