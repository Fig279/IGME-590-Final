extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var look_dir: Vector2
@onready var camera = $Camera3D
var camera_sens = 50

var element: Element = Element.new()
var label: Label

const bulletPrefab = preload("res://Vision Feature/Prefabs/bullet.tscn")

# pause menu fields
@export var pauseMenu : Control
var isPaused: bool = false

signal toggle_paused(isPaused: bool)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Set element stuff
	element.currentState = Element.State.Neutral
	label = $"../Control/ElementText"
	label.modulate.a = 0 # Make it invisible
	
	toggle_paused.connect(Global._on_character_toggle_paused)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !isPaused:
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


	if !isPaused:
		_rotate_camera(delta)
		move_and_slide()

func _input(event: InputEvent):
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01

# Rotate the camera based on mouse movement
func _rotate_camera(delta: float, sens_mod: float = 1.0):
	rotation.y -= look_dir.x * camera_sens * delta
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod * delta, -1.5, 1.5)
	look_dir = Vector2.ZERO
	
# Handling gameplay inputs
func _unhandled_input(event: InputEvent) -> void:
	
	# Toggle Pause when pause is pressed
	if Input.is_action_just_pressed("pause"):
		pauseMenu.visible = !pauseMenu.visible 
		isPaused = pauseMenu.visible
		
		emit_signal("toggle_paused", isPaused)
		
		# show cursor if pausing
		if isPaused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# hide cursor if unpasuing
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	
	# if the player is paused, ignore other input
	if isPaused:
		return
	
	# Swap elements is numbers 1 to 7 is pressed
	if event.is_action_pressed("swap"):
		# The keycode of the number keys 1 to 9 is the number plus 48. ex: 1 is keycode 49
		# Doing -48 gives us a single digit number that can be used by the enum
		element.currentState = event.keycode - 48
		print(Element.State.keys()[element.currentState])
		display_element()
		
	# Shoot bullet when proper button is pressed
	if event.is_action_pressed("shoot"):
		if element.currentState == Element.State.Neutral: # Can't shoot physical bullets
			return
		
		var inv := PlayerManagerInventory.playerManagerInventory
		if inv == null or not inv.has_ammo():
			print("Out of ammo!")
			return
		
		shoot_bullet(element)
	

# Display the player's current element
func display_element() -> void:
	label.text = Element.State.keys()[element.currentState]
	label.modulate = element.get_color()
	label.modulate.a = 1

# Generate the bullet
func shoot_bullet(element: Element):
	var inv := PlayerManagerInventory.playerManagerInventory
	if inv == null or not inv.consume_ammo():
		return
	
	# Instantiate bullet and shoot it forward
	var newBullet = bulletPrefab.instantiate()
	newBullet.set_values(element, -camera.global_basis.z, self.global_position + (-camera.global_basis.z * 1))
	get_tree().current_scene.add_child(newBullet)
