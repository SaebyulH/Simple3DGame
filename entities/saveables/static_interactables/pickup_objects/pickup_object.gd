extends Saveable
class_name PickupObject

@export var item_data: ItemData = ItemData.new()

func _ready():
	super()  # Adds to "saveable" group

	# Set default item data if empty
	if not item_data.display_name:
		item_data.display_name = "Scrap Metal"
		item_data.mass = 2.5
		item_data.value = 1
		item_data.uses_ammo = false
		item_data.range = 2
		item_data.damage = 10
		item_data.health = 100
		item_data.item_scene = load("res://entities/player/viewmodels/scrap_metal_model.tscn")

func interact(player):
	if not item_data:
		print("⚠️ No item_data assigned to '%s'" % name)
		return

	if player.inventory_data:
		player.inventory_data.add_item(item_data)
		player.update_equipped_item()
		print("Picked up: %s" % item_data.display_name)
	else:
		print("⚠️ Player has no inventory_data!")

	# Instead of queue_free(), just hide
	visible = false
	$CollisionShape3D.disabled = true  # Optional: disable collisions


func get_save_data() -> Dictionary:
	var data = super()
	data["picked_up"] = !visible
	return data

func apply_save_data(data: Dictionary) -> void:
	super(data)
	if data.get("picked_up", false):
		visible = false
		if has_node("CollisionShape3D"):
			$CollisionShape3D.disabled = true


func get_display_name() -> String:
	return item_data.display_name
