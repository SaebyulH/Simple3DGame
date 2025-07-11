extends PickupObject

func _ready():
	super()
	scene_path = "res://entities/saveables/saveable_interactables/pickup_objects/shit_pistol/shit_pistol.tscn"
	
	item_data.display_name = "Shit Pistol" #Just in case didnt do it in the editor
	item_data.mass = 20.0
	item_data.value = 49.99
	item_data.uses_ammo = false
	item_data.range = 20
	item_data.damage = 10
	#item_data.health = 100
	item_data.item_scene = load("res://entities/player/viewmodels/shit_pistol_model.tscn")

func get_save_data() -> Dictionary:
	return super()

func apply_save_data(data: Dictionary) -> void:
	super(data)
