extends TextureRect
class_name InventoryItem

# the anchor cell will always be 0,0 and the other coordinates are relative to the anchor
@export var shapeCells : Array[Vector2i]

# grid spot that the top left of this item occupies
var anchorSpot : Vector2i = Vector2i(-99, -99)

@export var is_ammo: bool = false
@export var stack_count: int = 1
@export var max_stack: int = 99

var count_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	custom_minimum_size = size
	CenterPivot()
	
	# if you attach a Label child named "StackLabel" in the scene, update it
	count_label = get_node_or_null("StackLabel")
	update_stack_display()

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
	
# Create the texture for the item by putting multiple instances of the box image
# based on the shapeCell
func genetate_texture() -> void:
	# Setting up
	var image: Image = preload("res://Items/Sprites/box.png").get_image()
	var cellSize = 70
	
	# THIS IS WHERE YOU GENERATE THE SHAPE
	shapeCells = generate_shape_cell(3)
	
	var numberOfCells = shapeCells.size()
	var imageSize: Vector2 = get_image_size()
	print(imageSize)
	
	# Create the image where all the squares will be stored
	var finalImage = Image.create(imageSize.x, imageSize.y, false,Image.FORMAT_RGBA8)
	
	# Place the boxes in the new texture
	for i in range(0, shapeCells.size()):
		var x = shapeCells[i].x * cellSize
		var y = shapeCells[i].y * cellSize
		
		finalImage.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i(x, y))
	
	# Messing with the size because it won't work otherwise
	custom_maximum_size = finalImage.get_size()
	custom_minimum_size = finalImage.get_size()
	size = finalImage.get_size()
	
	# Make the new image with all the boxes the new texture
	self.texture = ImageTexture.create_from_image(finalImage)

func generate_shape_cell(number: int) -> Array[Vector2i]:
	var newShape: Array[Vector2i]
	
	match number:
		# Vertical line
		1:
			newShape.append(Vector2i(0, 0))
			newShape.append(Vector2i(0, 1))
		
		# Horizontal line
		2:
			newShape.append(Vector2i(0, 0))
			newShape.append(Vector2i(1, 0))
		
		# L shape
		3:
			newShape.append(Vector2i(0, 0))
			newShape.append(Vector2i(0, 1))
			newShape.append(Vector2i(1, 1))
		# Single cell
		_: 
			newShape.append(Vector2i(0, 0))
	
	return newShape
# Returns the size of new image based on the cell positioning.
# Similar to how collision boxes are generated
func get_image_size() -> Vector2:
	var returnVector: Vector2 = Vector2.ZERO
	
	# Get the furthest x and y value by going through every cell
	for i in range(0, shapeCells.size()):
		if shapeCells[i].x > returnVector.x:
			returnVector.x = shapeCells[i].x
		
		if shapeCells[i].y > returnVector.y:
			returnVector.y = shapeCells[i].y
	
	# Adding 1 because arrays start counting from 0.
	# Multiply by the size of one cell
	returnVector.x += 1
	returnVector.x *= 70
	returnVector.y += 1
	returnVector.y *= 70
	
	return returnVector

#region Stacking Items Logic

func update_stack_display() -> void:
	if count_label != null:
		count_label.visible = is_ammo and stack_count > 0
		count_label.text = str(stack_count)

func add_to_stack(amount: int) -> int:
	if amount <= 0:
		return 0
	var space_left := max_stack - stack_count
	var added := mini(space_left, amount)
	stack_count += added
	update_stack_display()
	return amount - added # returns any remainder that didn't fit

func consume_one() -> bool:
	if stack_count <= 0:
		return false
	stack_count -= 1
	update_stack_display()
	return true

#endregion
