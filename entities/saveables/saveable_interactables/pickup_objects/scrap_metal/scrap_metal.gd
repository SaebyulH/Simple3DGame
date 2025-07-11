extends PickupObject

func _ready():
	super()
	scene_path = "res://entities/saveables/saveable_interactables/pickup_objects/scrap_metal/scrap_metal.tscn"

	item_data.display_name = "Scrap Metal" #Just in case didnt do it in the editor
	item_data.mass = 15.0
	item_data.value = 1
	item_data.uses_ammo = false
	item_data.range = 2
	item_data.damage = 5
	#item_data.health = 100
	item_data.item_scene = load("res://entities/player/viewmodels/scrap_metal_model.tscn")

func get_save_data() -> Dictionary:
	return super()

func apply_save_data(data: Dictionary) -> void:
	super(data)
