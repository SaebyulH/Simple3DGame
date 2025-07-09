extends PickupObject

func _ready():
	super()

	item_data.display_name = "Shit Rifle"
	item_data.mass = 5.0
	item_data.value = 4
	item_data.uses_ammo = false
	item_data.range = 35
	item_data.damage = 18
	item_data.health = 100
	item_data.item_scene = load("res://entities/player/viewmodels/shit_rifle_model.tscn")
