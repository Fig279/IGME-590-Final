extends TextureRect
class_name GridSpot

var itemInside : InventoryItem = null
var spotNumber : int = -1

var row : int
var column : int

var spotSize : float = 100

# ensures this spots size will be locked to the standard spot size
func SetSize(desiredSize : float):
	spotSize = desiredSize
	custom_minimum_size.x = spotSize
	custom_minimum_size.y = spotSize
	
	custom_maximum_size.x = spotSize
	custom_maximum_size.y = spotSize

# change to specified color
func HighlightSelf(highlightColor : Color):
	self_modulate = highlightColor

# store of referenc of the item being held here, this is only called for the bestSpot
func AddItemAsChild(newItem: InventoryItem) -> void:
	itemInside = newItem
	newItem.position = Vector2.ZERO
	newItem.reparent.call_deferred(self, false)
	
	# account for anchor shifting with rotation
	# depending on what size is longer than the other, the offset needs to be inversed
	if newItem.size.x > newItem.size.y:
		if newItem.rotation_degrees == 90 || newItem.rotation_degrees == 270:
			newItem.position.x = newItem.position.x - spotSize / 2
			newItem.position.y = newItem.position.y + spotSize / 2
	elif newItem.size.y > newItem.size.x:
		if newItem.rotation_degrees == 90 || newItem.rotation_degrees == 270:
			newItem.position.x = newItem.position.x + spotSize / 2
			newItem.position.y = newItem.position.y - spotSize / 2
