class_name Bullet

extends Area3D

var element: Element = Element.new()
var speed: int = 20
var direction: Vector3
var timer: float = 0 # Timer keeping track of how long the bullet has been active

func set_values(currentElement: Element, initalDirction: Vector3, position: Vector3) -> void:
	element.currentState = currentElement.currentState
	direction = initalDirction
	self.position = position
	
	# Create new material and assigning it
	var material = StandardMaterial3D.new()
	material.albedo_color = element.get_color()
	$MeshInstance3D.set_surface_override_material(0, material)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	timer += delta
	
	# Destroy the bullet once the timer reaches a certain value
	if timer > 5:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	# If bullet collides with an Asset change its color to bullet's element
	if body is Asset:
		body.change_element(element)
		
		if Global.vision:
			body.update_information()

	queue_free()
	pass # Replace with function body.
