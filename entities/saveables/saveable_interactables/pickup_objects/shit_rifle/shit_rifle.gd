extends PickupObject

func _ready():
	super()
	scene_path = "res://entities/saveables/saveable_interactables/pickup_objects/shit_rifle/shit_rifle.tscn"

	item_data.display_name = "Shit Rifle" #Just in case didnt do it in the editor
	item_data.mass = 25.0
	item_data.value = 74.99
	item_data.uses_ammo = false
	item_data.range = 35
	item_data.damage = 18
	#item_data.health = 100
	item_data.item_scene = load("res://entities/player/viewmodels/shit_rifle_model.tscn")

func get_save_data() -> Dictionary:
	return super()

func apply_save_data(data: Dictionary) -> void:
	super(data)
