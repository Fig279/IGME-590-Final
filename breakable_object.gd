class_name BreakableObject
extends StaticBody3D
## Attach to the root of any in-world object that can be broken.
## When broken, it spawns pickup scene(s) and removes itself.

@export var drop_scene: PackedScene          ## The small pickup version (a different scene)
@export var drop_count: int = 1
@export var max_health: int = 3              ## Set to 1 for "breaks in one hit"
@export var scatter_radius: float = 0.3      ## Random spread of spawned drops
@export var pop_strength: float = 2.0        ## Small upward/outward impulse on drops

var health: int

func _ready() -> void:
	health = max_health

## Call this from the player's attack/tool logic.
func hit(damage: int = 1) -> void:
	health -= damage
	if health <= 0:
		break_object()

## Spawns the drops and destroys this object.
func break_object() -> void:
	if drop_scene == null:
		push_warning("%s has no drop_scene assigned." % name)
		queue_free()
		return

	var world := get_tree().current_scene
	for i in drop_count:
		var drop := drop_scene.instantiate() as Node3D
		world.add_child(drop)  # add first, then set global transform
		var offset := Vector3(
			randf_range(-scatter_radius, scatter_radius),
			0.2,
			randf_range(-scatter_radius, scatter_radius)
		)
		drop.global_position = global_position + offset
		if drop is RigidBody3D:
			var impulse := Vector3(offset.x, 1.0, offset.z).normalized() * pop_strength
			drop.apply_central_impulse(impulse)
	queue_free()
