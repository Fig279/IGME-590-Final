extends GridContainer
class_name GridManager

const gridSpot : PackedScene = preload("res://GridInventory/grid_spot.tscn")

# number of columns and rows in the grid
@export var gridWidth: int = 5
@export var gridHeight: int = 4

# the width and length of every spot on the grid
@export var spotSize : float = 100

# holds a reference to each gridSpot
var gridSpots : Array[Array]

# spots the player held item may be looking to be placed into
var prospectiveSpots : Array[GridSpot]

# true if the player can place an item currently by immedietely clicking, false otherwise
var canPlaceItem : bool = false
enum SpotState { Valid, Invalid, Normal }

@export var playerManagerInventory: PlayerManagerInventory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# makes sure that the grid containers settings match the intended grid size
	columns = gridWidth

	
	# set the size of the array to match the grid
	gridSpots.resize(gridWidth)
	for c in range(0, gridWidth):
		gridSpots[c].resize(gridHeight)
	
	var spotNumber : int = 0
	
	# fill the grid with spot
	for r in range(0, gridHeight):
		for c in range(0, gridWidth):
			gridSpots[c][r] = CreateGridSpot(spotNumber, r, c)
			spotNumber += 1
			

# creates a grid spot at the specified row and column
func CreateGridSpot(spotNumber: int, row: int, column : int) -> GridSpot:
	var newSpot = gridSpot.instantiate()
	add_child(newSpot)
	newSpot.spotNumber = spotNumber
	 
	# assign each spot a unique number 
	# this will be used to identify what spot sent the signal
	newSpot.mouse_entered.connect(SpotEntered.bind(column, row))
	newSpot.mouse_exited.connect(SpotExited)
	newSpot.row = row
	newSpot.column = column
	
	newSpot.SetSize(spotSize)

	return newSpot

# called when the mouse enteres a grid spot
func SpotEntered(column: int, row: int):
	
	# if the player is holding an item, check if they can place it with this as the anchor spot
	playerManagerInventory.FocusSpot(gridSpots[column][row])
	if playerManagerInventory.heldItem != null:
		CheckIfItemCanBePlaced(gridSpots[column][row], playerManagerInventory.heldItem)

# called when the mouse leaves a grid spot
func SpotExited():
	
	# no longer focusing on a spot, can't place an item
	playerManagerInventory.UnfocusSpot()
	canPlaceItem = false
	
	# unhighlight spots
	HighlightSpots(SpotState.Normal)
	
	prospectiveSpots.clear()
	

# checks the anchor spot and surrounding spots against the item spaceCells to see if the item can be placed here
func CheckIfItemCanBePlaced(anchorSpot: GridSpot, item: InventoryItem):
	# reset and clear last prospective slots if they still exist
	HighlightSpots(SpotState.Normal)
	prospectiveSpots.clear()
	
	# gets all of spots on the grid by column and row coordinates that would be needed to palce this item
	var neededSpots : Array[Vector2i] = FindNeededSpots(anchorSpot, item)
	var isValidPlacement : bool = true
	
	# check each cell of the item against where it would go on the grid to see if they are all open
	for spot in neededSpots:
		
		# check if this grid spot exists
		if spot.x < 0 || spot.y < 0 || gridWidth - 1 < spot.x || gridHeight - 1 < spot.y:
			isValidPlacement = false
			
			# bail from this iteration so it doesn't crash
			continue
		else:
			# since this spot exists, it is one of the ones the item is looking to slot into
			prospectiveSpots.append(gridSpots[spot.x][spot.y])
		
		# if it exists, check if its empty
		if gridSpots[spot.x][spot.y].itemInside != null:
			# this isn't a valid spot
			isValidPlacement = false
	
	canPlaceItem = isValidPlacement
	
	if isValidPlacement:
		HighlightSpots(SpotState.Valid)
	else:
		HighlightSpots(SpotState.Invalid)

# used to give the user feedback on if placement would work here by highlighting prospectiveSlots red or green
func HighlightSpots(highlightReason: SpotState):
	var highlightColor : Color
	
	# acts like a dictionary to find proper highlight
	match highlightReason:
		SpotState.Valid:
			highlightColor = Color(0.75, 0.869, 0.49, 1.0)
		SpotState.Invalid:
			highlightColor = Color(0.749, 0.384, 0.49, 1.0)
		# default case
		_:
			highlightColor = Color(1.0, 1.0, 1.0, 1.0)
	
	# highlight each spot with selected color
	for spot in prospectiveSpots:
		spot.HighlightSelf(highlightColor)

# returns the coords of all spots needed to place the given item in the given anchor spot
func FindNeededSpots(anchorSpot: GridSpot, item: InventoryItem) -> Array[Vector2i]:
	
	var neededSpots : Array[Vector2i]
	var itemShape = item.shapeCells
	
	# add every cell coord that would need to exist and be empty to array
	for cell in itemShape:
		neededSpots.append(Vector2i(anchorSpot.column + cell.x, anchorSpot.row + cell.y))
	
	return neededSpots

# tells each prospective slot they are now full, 
func PlayerPlaceItemInGrid(anchorSpot: GridSpot, item: InventoryItem):
	if canPlaceItem:
		
		# find topmost and leftmost spot that the item will be placed in
		var currentBestSpot = prospectiveSpots[0]
		for spot in prospectiveSpots:
			if spot.column + spot.row < currentBestSpot.column + currentBestSpot.row:
				currentBestSpot = spot
				
		currentBestSpot.AddItemAsChild(item)
		canPlaceItem = false
		
		# assign this spots coords as the anchor spot
		item.anchorSpot = Vector2i(anchorSpot.column, anchorSpot.row)

		# tell all spots what item they are holding
		for spot in prospectiveSpots:
			spot.itemInside = item
		
		# reset color to white
		HighlightSpots(SpotState.Normal)

# used if there is need for code to directly place items instead of player
# currently unused
func ManualPlaceItemInGrid(anchorSpot: GridSpot, item: InventoryItem):
	# populate prospective spots
	CheckIfItemCanBePlaced(anchorSpot, item)
	
	anchorSpot.AddItemAsChild(item)
	item.anchorSpot = Vector2i(anchorSpot.column, anchorSpot.row)
	
	for spot in prospectiveSpots:
		spot.itemInside = item
	
	SpotExited()
	
# tells all spots occupied by the item that they are now empty
func PickupItem(item: InventoryItem):
	
	# get all spots this item is in
	var occupiedSpots : Array[Vector2i] = FindNeededSpots(gridSpots[item.anchorSpot.x][item.anchorSpot.y], item)
	
	# tell them they are now empty
	for spot in occupiedSpots:
		gridSpots[spot.x][spot.y].itemInside = null
	
	CheckIfItemCanBePlaced(gridSpots[playerManagerInventory.focusedSpot.column][playerManagerInventory.focusedSpot.row], item)

# Call this when an item's stack reaches 0 while placed on the grid
func RemoveItemFromGrid(item: InventoryItem) -> void:
	if item == null:
		return
	
	if item.anchorSpot.x >= 0 and item.anchorSpot.y >= 0:
		var occupied_spots: Array[Vector2i] = FindNeededSpots(gridSpots[item.anchorSpot.x][item.anchorSpot.y], item)
		for spot in occupied_spots:
			if spot.x >= 0 and spot.y >= 0 and spot.x < gridWidth and spot.y < gridHeight:
				if gridSpots[spot.x][spot.y].itemInside == item:
					gridSpots[spot.x][spot.y].itemInside = null
	
	item.queue_free()
