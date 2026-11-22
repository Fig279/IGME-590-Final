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

var _time: float = 0.0



func _ready() -> void:
	
	# Keep the body upright so it doesn't tumble; only the visual spins
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true
	
	
	pickup_area.monitoring = false
	pickup_area.body_entered.connect(_on_body_entered)
	get_tree().create_timer(pickup_delay).timeout.connect(_enable_pickup)

func _process(delta: float) -> void:
	
	# slowly bob, rotate
	_time += delta
	visual.rotate_y(spin_speed * delta)
	visual.position.y = hover_height + sin(_time * bob_speed) * bob_amount

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
