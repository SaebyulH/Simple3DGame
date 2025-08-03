extends SaveableInteractableRigidBody3D
class_name PickupObject

@export var item_data: ItemData = ItemData.new()

func _ready():
	super()
	setup_item_data(ItemDataFactory.create_default_item())
	
func setup_item_data(data: ItemData):
	item_data = data
	scene_path = item_data.scene_path
	display_name = item_data.display_name
	
func get_interact_verb() -> String:
	return "Pick Up"

func interact(player):
	if player.inventory_data:
		if player.inventory_data.add_item(item_data):
			print(name, ": ", item_data.display_name, " added to player inventory")
			player.hud.update_ammo_label(player.inventory_data)
			
			print(name, ": ammo label updated")
			player.inventory_data.current_index = player.inventory_data.items.size() -1
			player.update_equipped_item()
			
			print(name, ": deleting self")
			queue_free()
		else:
			print(name, ": pickup cannot be added to inventory, and remains in scene")
	else:
		print(name, ": ERROR: Player has no inventory_data!")


func get_save_data() -> Dictionary:
	var data = super()
	data["item_data"] = item_data
	return data

func apply_save_data(data: Dictionary) -> void:
	super(data)
	if data.has("item_data"):
		setup_item_data(data["item_data"])
		
func apply_save_data_from_item_data(data: ItemData):
	setup_item_data(data)





#func get_display_name() -> String:
	#return item_data.display_name
