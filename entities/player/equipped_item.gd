extends Node3D
class_name EquippedItem

func equip_item(item_data: ItemData) -> void:
	# Remove previously equipped items
	for child in get_children():
		child.queue_free()
		
	if item_data == null or item_data.view_model == null:
		return
		
	# Equip new item
	var instance := item_data.view_model.instantiate()
	add_child(instance)
