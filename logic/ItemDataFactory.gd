extends Node

func create_default_item() -> ItemData:
	var item_data = ItemData.new()
	item_data.item_type = ItemData.ItemType.MISC
	item_data.display_name = ""
	item_data.mass = 0
	item_data.value = 0
	item_data.uses_ammo = false
	item_data.ammo_type = AmmoFactory.create_default_ammo()
	item_data.mag_size = 0
	item_data.shooting_mode = ItemData.ShootingMode.SAFETY
	item_data.initial_shooting_delay = 0.0
	item_data.between_shooting_delay = 1.0
	item_data.range = 0
	item_data.damage = 0
	item_data.scene_path = "res://entities/saveables/Saveable.tscn"
	item_data.view_model = load("res://entities/player/viewmodels/scrap_metal_model.tscn")
	item_data.sound_path = "res://assets/sword-slash.mp3"
	
	return item_data

func create_scrap_metal() -> ItemData:
	var item_data = ItemData.new()
	item_data.item_type = ItemData.ItemType.MISC
	item_data.display_name = "Scrap Metal"
	item_data.mass = 15.0
	item_data.value = 1
	item_data.uses_ammo = false
	item_data.ammo_type = AmmoFactory.create_default_ammo()
	item_data.mag_size = 0
	item_data.shooting_mode = ItemData.ShootingMode.SAFETY
	item_data.initial_shooting_delay = 0.18
	item_data.between_shooting_delay = 0.5
	item_data.range = 2
	item_data.damage = 5
	item_data.scene_path = "res://entities/saveables/saveable_interactables/pickup_objects/scrap_metal/scrap_metal.tscn"
	item_data.view_model = load("res://entities/player/viewmodels/scrap_metal_model.tscn")
	item_data.sound_path = "res://assets/sword-slash.mp3"
	
	return item_data

func create_shit_pistol() -> ItemData:
	var item_data = ItemData.new()
	item_data.item_type = ItemData.ItemType.PISTOL
	item_data.display_name = "Shit Pistol"
	item_data.mass = 20.0
	item_data.value = 49.99
	item_data.uses_ammo = true
	item_data.ammo_type = AmmoFactory.create_revolver_ammo()
	item_data.mag_size = 8
	item_data.shooting_mode = ItemData.ShootingMode.SEMI_AUTO
	item_data.initial_shooting_delay = 0.6
	item_data.between_shooting_delay = 0.4
	item_data.range = 20
	item_data.damage = 45
	item_data.scene_path = "res://entities/saveables/saveable_interactables/pickup_objects/shit_pistol/shit_pistol.tscn"
	item_data.view_model = load("res://entities/player/viewmodels/shit_pistol_model.tscn")
	item_data.sound_path = "res://assets/gun-shot-359196.mp3"
	
	return item_data

func create_shit_rifle() -> ItemData:
	var item_data = ItemData.new()
	item_data.item_type = ItemData.ItemType.RIFLE
	item_data.display_name = "Shit Rifle"
	item_data.mass = 25.0
	item_data.value = 74.99
	item_data.uses_ammo = true
	item_data.ammo_type = AmmoFactory.create_rifle_ammo()
	item_data.mag_size = 30
	item_data.shooting_mode = ItemData.ShootingMode.AUTO
	item_data.initial_shooting_delay = 0.0
	item_data.between_shooting_delay = 0.1
	item_data.range = 35
	item_data.damage = 50
	item_data.scene_path = "res://entities/saveables/saveable_interactables/pickup_objects/shit_rifle/shit_rifle.tscn"
	item_data.view_model = load("res://entities/player/viewmodels/shit_rifle_model.tscn")
	item_data.sound_path = "res://assets/submachine-gun-79846.mp3"
	
	return item_data
