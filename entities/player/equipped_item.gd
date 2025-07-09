extends Node3D
class_name EquippedItem

var current_item_data: ItemData = null
var equipped_scene_instance: Node3D = null

func equip_item(item_data: ItemData):
	# Remove previously equipped scene
	if equipped_scene_instance and equipped_scene_instance.is_inside_tree():
		equipped_scene_instance.queue_free()
		equipped_scene_instance = null

	current_item_data = item_data

	# Equip new item if valid
	if item_data and item_data.item_scene:
		equipped_scene_instance = item_data.item_scene.instantiate()
		add_child(equipped_scene_instance)
		equipped_scene_instance.owner = self  # Optional: needed for editing from editor
