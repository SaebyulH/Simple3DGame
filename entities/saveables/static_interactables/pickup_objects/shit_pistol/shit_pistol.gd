extends PickupObject

func _ready():
	super()

	item_data.display_name = "Shit Pistol"
	item_data.mass = 2.5
	item_data.value = 2
	item_data.uses_ammo = false
	item_data.range = 20
	item_data.damage = 10
	item_data.health = 100
	item_data.item_scene = load("res://entities/player/viewmodels/shit_pistol_model.tscn")
