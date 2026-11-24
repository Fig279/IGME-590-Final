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

const ITEM_SCENE : PackedScene = preload("res://Items/ItemScenes/inventory_item.tscn") 
const AMMO_TEXTURE : Texture2D = preload("res://Items/Sprites/box.png")

@export var starting_ammo: int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_spawn_starting_ammo")


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
	if newItem.get_parent() != null:
		heldItem.reparent.call_deferred(self, false)
	elif heldItem.get_parent() == null:
		call_deferred("add_child", heldItem)
	
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

#region Ammo Handling
func _spawn_starting_ammo() -> void:
	if starting_ammo <= 0 or gridManager == null or gridManager.gridSpots.is_empty():
		return
	
	var ammo_item: InventoryItem = ITEM_SCENE.instantiate()
	add_child(ammo_item)
	ammo_item.is_ammo = true
	ammo_item.stack_count = starting_ammo
	ammo_item.shapeCells = [Vector2i(0, 0)]
	ammo_item.texture = AMMO_TEXTURE
	ammo_item.custom_minimum_size = Vector2(gridManager.spotSize, gridManager.spotSize)
	ammo_item.custom_maximum_size = Vector2(gridManager.spotSize, gridManager.spotSize)
	ammo_item.size = Vector2(gridManager.spotSize, gridManager.spotSize)
	
	gridManager.ManualPlaceItemInGrid(gridManager.gridSpots[0][0], ammo_item)
	ammo_item.update_stack_display()

func has_ammo() -> bool:
	return _find_ammo_item() != null

func consume_ammo() -> bool:
	var ammo_item := _find_ammo_item()
	if ammo_item == null:
		return false
	
	var spent := ammo_item.consume_one()
	if not spent:
		return false
	
	# If stack is depleted, remove from grid 
	if ammo_item.stack_count <= 0:
		if heldItem == ammo_item:
			heldItem = null
			isHoldingItem = false
			ammo_item.queue_free()
		elif gridManager != null:
			gridManager.RemoveItemFromGrid(ammo_item)
	
	return true

func _find_ammo_item() -> InventoryItem:
	# Check held item first
	if heldItem != null and heldItem.is_ammo and heldItem.stack_count > 0:
		return heldItem
	
	if gridManager == null:
		return null
	
	# Scan grid spots for an ammo stack
	for c in range(gridManager.gridSpots.size()):
		for r in range(gridManager.gridSpots[c].size()):
			var spot: GridSpot = gridManager.gridSpots[c][r]
			if spot != null and spot.itemInside != null:
				var item := spot.itemInside
				if item.is_ammo and item.stack_count > 0:
					return item
	
	return null
#endregion
