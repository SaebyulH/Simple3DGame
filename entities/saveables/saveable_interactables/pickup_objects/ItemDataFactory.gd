extends Node

func create_default_item() -> ItemData:
	var item_data = ItemData.new()
	item_data.display_name = ""
	item_data.mass = 0
	item_data.value = 0
	item_data.uses_ammo = false
	item_data.range = 0
	item_data.damage = 0
	item_data.scene_path = "res://entities/saveables/Saveable.tscn"
	item_data.view_model = load("res://entities/player/viewmodels/scrap_metal_model.tscn")
	return item_data

func create_scrap_metal() -> ItemData:
	var item_data = ItemData.new()
	item_data.display_name = "Scrap Metal" #Just in case didnt do it in the editor
	item_data.mass = 15.0
	item_data.value = 1
	item_data.uses_ammo = false
	item_data.range = 2
	item_data.damage = 5
	item_data.scene_path = "res://entities/saveables/saveable_interactables/pickup_objects/scrap_metal/scrap_metal.tscn"
	item_data.view_model = load("res://entities/player/viewmodels/scrap_metal_model.tscn")
	return item_data

func create_shit_pistol() -> ItemData:
	var item_data = ItemData.new()
	item_data.display_name = "Shit Pistol" #Just in case didnt do it in the editor
	item_data.mass = 20.0
	item_data.value = 49.99
	item_data.uses_ammo = false
	item_data.range = 20
	item_data.damage = 10
	item_data.scene_path = "res://entities/saveables/saveable_interactables/pickup_objects/shit_pistol/shit_pistol.tscn"
	item_data.view_model = load("res://entities/player/viewmodels/shit_pistol_model.tscn")
	return item_data
	
func create_shit_rifle() -> ItemData:
	var item_data = ItemData.new()
	item_data.display_name = "Shit Rifle" #Just in case didnt do it in the editor
	item_data.mass = 25.0
	item_data.value = 74.99
	item_data.uses_ammo = false
	item_data.range = 35
	item_data.damage = 18
	item_data.scene_path = "res://entities/saveables/saveable_interactables/pickup_objects/shit_rifle/shit_rifle.tscn"
	item_data.view_model = load("res://entities/player/viewmodels/shit_rifle_model.tscn")
	return item_data
	
	
	
