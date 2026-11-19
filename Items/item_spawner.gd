extends Button

# all current item prefabs
const inventoryItems : Array[PackedScene] = [preload("res://Items/ItemScenes/inventory_item_gunther.tscn"), preload("res://Items/ItemScenes/inventory_item_hornet.tscn"),preload("res://Items/ItemScenes/inventory_item_labubu.tscn"),preload("res://Items/ItemScenes/inventory_item_lego.tscn"),preload("res://Items/ItemScenes/inventory_item_magnet.tscn")]
@export var playerManager : PlayerManagerInventory


# give a random item to the player to hold
# doesn't work if the player is already holding something
func _on_item_spawner_pressed() -> void:
	if playerManager.heldItem == null:
		
		var newItem = inventoryItems[randi_range(0, inventoryItems.size() - 1)].instantiate()
		playerManager.PickupSpawnedItem(newItem)
