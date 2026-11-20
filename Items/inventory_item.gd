extends TextureRect
class_name InventoryItem

# the anchor cell will always be 0,0 and the other coordinates are relative to the anchor
@export var shapeCells : Array[Vector2i]

# grid spot that the top left of this item occupies
var anchorSpot : Vector2i = Vector2i(-99, -99)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	custom_minimum_size = size
	
	CenterPivot()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# move the items pivot point to its center so that it rotates around itself
func CenterPivot():
	# center the pivot
	pivot_offset.x = size.x / 2
	pivot_offset.y = size.y / 2

# rotates this object 90 degrees
func RotateShapeCells():
	rotation_degrees += 90
	
	# reset to 0 if a full loop was made
	if rotation_degrees == 360.0:
		rotation_degrees = 0

	# rotates the shape cells to be accurate to the new rotation
	for i in range(0, shapeCells.size()):
		var currentCoordinate = shapeCells[i]
		shapeCells[i].x = currentCoordinate.y * -1
		shapeCells[i].y = currentCoordinate.x
	
# Create the texture for the item
func genetate_texture() -> void:
	var image: Image = preload("res://Items/Sprites/box.png").get_image()
	var cellSize = 70
	var numberOfCells = shapeCells.size()
	var imageSize: Vector2 = get_image_size()
	print(imageSize)
	
	var finalImage = Image.create(imageSize.x, imageSize.y, false,Image.FORMAT_RGBA8)
	
	#finalImage.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i.ZERO)
	#finalImage.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i(70, 0))
	for i in range(0, shapeCells.size()):
		var x = shapeCells[i].x * cellSize
		var y = shapeCells[i].y * cellSize
		
		finalImage.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i(x, y))
	
	custom_maximum_size = finalImage.get_size()
	custom_minimum_size = finalImage.get_size()
	size = finalImage.get_size()
	self.texture = ImageTexture.create_from_image(finalImage)

func get_image_size() -> Vector2:
	var returnVector: Vector2 = Vector2.ZERO
	
	for i in range(0, shapeCells.size()):
		if shapeCells[i].x > returnVector.x:
			returnVector.x = shapeCells[i].x
		
		if shapeCells[i].y > returnVector.y:
			returnVector.y = shapeCells[i].y
	
	returnVector.x += 1
	returnVector.x *= 70
	returnVector.y += 1
	returnVector.y *= 70
	
	return returnVector
