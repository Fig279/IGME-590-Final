extends Node2D
class_name PlayerManagerInventory

# active instance of this manager
static var playerManagerInventory: PlayerManagerInventory
@export var gridManager :GridManager

# singleton 
func _enter_tree() -> void:
	if playerManagerInventory == null:
		playerManagerInventory = self
	else:
		# destroy duplicate
		queue_free()

var isHoldingItem : bool = false
var heldItem : InventoryItem = null
var focusedSpot : GridSpot = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isHoldingItem:
		heldItem.position.x = get_global_mouse_position().x - (heldItem.size.x / 2)
		heldItem.position.y = get_global_mouse_position().y - (heldItem.size.y / 2)

# called when the mouse enters a spot, denotes that the mouse is over this spot
func FocusSpot(newlyFocusedSpot: GridSpot):
	focusedSpot = newlyFocusedSpot
	
# called when the mouse leaves a spot, denotes that the mouse is no longer over this spot
func UnfocusSpot():
	focusedSpot = null

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("Click"):
		# if they player is looking at a spot with an item and holding nothings
		if focusedSpot != null && !heldItem && focusedSpot.itemInside != null:
			# pickup the item
			PickupGridItem(focusedSpot.itemInside)
		elif focusedSpot != null && heldItem:
			AttemptPlaceItem()
	# when rotate button is clicked
	elif event.is_action_pressed("Rotate"):
		if heldItem:
			RotateItem()
			
			# if over the grid, recheck if we can place this item
			if focusedSpot != null:
				gridManager.CheckIfItemCanBePlaced(focusedSpot, heldItem)

# tell the item to rotate
func RotateItem():
	heldItem.RotateShapeCells()

func PickupGridItem(newItem: InventoryItem):
	heldItem = newItem;
	isHoldingItem = true;
	
	# the spot is no longer holding the item
	focusedSpot.itemInside = null;
	
	# now a child of ther player manager
	heldItem.reparent.call_deferred(self, false)
	
	gridManager.PickupItem(heldItem)

func PickupSpawnedItem(newItem: InventoryItem):
	heldItem = newItem;
	isHoldingItem = true;
	
	# now a child of ther player manager
	add_child(newItem)
	

func AttemptPlaceItem():
	if gridManager.canPlaceItem:
		gridManager.PlayerPlaceItemInGrid(focusedSpot, heldItem)
		heldItem = null
		isHoldingItem = false
