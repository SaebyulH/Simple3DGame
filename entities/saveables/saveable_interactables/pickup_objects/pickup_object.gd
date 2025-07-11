extends SaveableInteractable
class_name PickupObject

@export var item_data: ItemData = ItemData.new()

func _ready():
	super()
	var scene_path := "res://entities/saveables/Saveable.tscn"
	# Set default item data if empty
	if not item_data.display_name:
		item_data.display_name = display_name
		item_data.mass = 0
		item_data.value = 0
		item_data.uses_ammo = false
		item_data.range = 0
		item_data.damage = 0
		#item_data.health = 100
		item_data.item_scene = load("res://entities/player/viewmodels/scrap_metal_model.tscn")

func get_interact_verb() -> String:
	return "Pick Up"

func interact(player):
	#if not item_data:
		#print("⚠️ No item_data assigned to '%s'" % name)
		#return

	if player.inventory_data:
		if player.inventory_data.add_item(get_save_data()):
			player.update_equipped_item()
			print("Picked up: %s" % item_data.display_name)
			#visible = false
			#$CollisionShape3D.disabled = true  # Optional: disable collisions
			queue_free()
		else:
			print("not hidden, pickup too massive")
	else:
		print("⚠️ Player has no inventory_data!")

	# Instead of queue_free(), just hide


#func respawn(position: Vector3):
	#var data = get_save_data()
	#data["position"] = position
	#apply_save_data(data)

func get_save_data() -> Dictionary:
	var data = super()
	data["item_data"] = item_data
	return data

func apply_save_data(data: Dictionary) -> void:
	super(data)
	if data.has("item_data"):
		item_data = data["item_data"]
	#if data.get("picked_up", false):
		#visible = false
		#if has_node("CollisionShape3D"):
			#$CollisionShape3D.disabled = true
	#else:
		#visible = true
		#if has_node("CollisionShape3D"):
			#$CollisionShape3D.disabled = false
		

func get_display_name() -> String:
	return item_data.display_name
