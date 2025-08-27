extends Node
class_name ItemDataFactory

static func create_default_item() -> ItemData:
	var item_data = ItemData.new()
	item_data.item_type = ItemData.ItemType.MISC
	item_data.display_name = ""
	item_data.mass = 0
	item_data.value = 0
	item_data.uses_ammo = false
	item_data.ammo_type = AmmoDataFactory.create_default_ammo()
	item_data.mag_size = 0
	item_data.shooting_mode = ItemData.ShootingMode.NON_AUTO
	item_data.shooting_type = ItemData.ShootingType.HITSCAN
	
	
	item_data.first_shot_inaccuracy = 0.1
	item_data.subsequent_shot_inaccuracy = 0.4
	item_data.inaccuracy_reset_speed = 20
	
	
	item_data.initial_shooting_delay = 0.0
	item_data.between_shooting_delay = 1.0
	item_data.hitscan_range = 0
	item_data.damage = 0
	item_data.scene_path = "res://entities/saveable_rigid_bodies/saveable_interactable_rigid_bodies/pickup_objects/pickup_object.tscn"
	item_data.view_model_path = "res://entities/saveable_character_bodies/advanced_character_bodies/viewmodels/scrap_metal_model.tscn"
	item_data.sound_path = "res://assets/sword-slash.mp3"
	
	return item_data

static func create_scrap_metal() -> ItemData:
	var item_data = ItemData.new()
	item_data.item_type = ItemData.ItemType.MISC
	item_data.display_name = "Scrap Metal"
	item_data.mass = 15.0
	item_data.value = 1
	item_data.uses_ammo = false
	item_data.ammo_type = AmmoDataFactory.create_default_ammo()
	item_data.mag_size = 0
	item_data.shooting_mode = ItemData.ShootingMode.NON_AUTO
	item_data.shooting_type = ItemData.ShootingType.HITSCAN
	
	item_data.first_shot_inaccuracy = 0.1
	item_data.subsequent_shot_inaccuracy = 0.4
	item_data.inaccuracy_reset_speed = 20
	
	
	
	item_data.initial_shooting_delay = 0.18
	item_data.between_shooting_delay = 0.5
	item_data.hitscan_range = 2
	item_data.damage = 5
	item_data.scene_path = "res://entities/saveable_rigid_bodies/saveable_interactable_rigid_bodies/pickup_objects/scrap_metal/scrap_metal.tscn"
	item_data.view_model_path = "res://entities/saveable_character_bodies/advanced_character_bodies/viewmodels/scrap_metal_model.tscn"
	item_data.sound_path = "res://assets/sword-slash.mp3"
	
	return item_data

static func create_shit_pistol() -> ItemData:
	var item_data = ItemData.new()
	item_data.item_type = ItemData.ItemType.PISTOL
	item_data.display_name = "Shit Pistol"
	item_data.mass = 20.0
	item_data.value = 49.99
	item_data.uses_ammo = true
	item_data.ammo_type = AmmoDataFactory.create_revolver_ammo()
	item_data.mag_size = 8
	item_data.shooting_mode = ItemData.ShootingMode.SEMI_AUTO
	item_data.shooting_type = ItemData.ShootingType.HITSCAN
	
	
	
	item_data.first_shot_inaccuracy = 0.1
	item_data.subsequent_shot_inaccuracy = 0.4
	item_data.inaccuracy_reset_speed = 20
	
	item_data.initial_shooting_delay = 0.6
	item_data.between_shooting_delay = 0.6
	item_data.hitscan_range = 10
	item_data.damage = 75
	item_data.scene_path = "res://entities/saveable_rigid_bodies/saveable_interactable_rigid_bodies/pickup_objects/shit_pistol/shit_pistol.tscn"
	item_data.view_model_path = "res://entities/saveable_character_bodies/advanced_character_bodies/viewmodels/shit_pistol_model.tscn"
	item_data.sound_path = "res://assets/gun-shot-359196.mp3"
	
	
	return item_data

static func create_shit_rifle() -> ItemData:
	var item_data = ItemData.new()
	item_data.item_type = ItemData.ItemType.RIFLE
	item_data.display_name = "Shit Rifle"
	item_data.mass = 25.0
	item_data.value = 74.99
	item_data.uses_ammo = true
	item_data.ammo_type = AmmoDataFactory.create_rifle_ammo()
	item_data.mag_size = 30
	item_data.shooting_mode = ItemData.ShootingMode.AUTO
	item_data.shooting_type = ItemData.ShootingType.HITSCAN
	
	item_data.first_shot_inaccuracy = 0.1
	item_data.subsequent_shot_inaccuracy = 0.4
	item_data.inaccuracy_reset_speed = 20
	
	
	
	item_data.initial_shooting_delay = 0.0
	item_data.between_shooting_delay = 0.4
	item_data.hitscan_range = 100
	item_data.damage = 50
	item_data.scene_path = "res://entities/saveable_rigid_bodies/saveable_interactable_rigid_bodies/pickup_objects/shit_rifle/shit_rifle.tscn"
	item_data.view_model_path = "res://entities/saveable_character_bodies/advanced_character_bodies/viewmodels/shit_rifle_model.tscn"
	item_data.sound_path = "res://assets/submachine-gun-79846.mp3"
	
	return item_data

static func create_shit_grenade_launcher() -> ItemData:
	var item_data = ItemData.new()
	item_data.item_type = ItemData.ItemType.RIFLE
	item_data.display_name = "Shit Grenade Launcher"
	item_data.mass = 125.0
	item_data.value = 74.99
	item_data.uses_ammo = true
	item_data.ammo_type = AmmoDataFactory.create_grenade_ammo()
	item_data.mag_size = 30
	item_data.shooting_mode = ItemData.ShootingMode.AUTO
	item_data.shooting_type = ItemData.ShootingType.PROJECTILE
	
	item_data.first_shot_inaccuracy = 0.1
	item_data.subsequent_shot_inaccuracy = 0.4
	item_data.inaccuracy_reset_speed = 20
	
	item_data.initial_shooting_delay = 0.0
	item_data.between_shooting_delay = 1
	item_data.hitscan_range = 35
	item_data.damage = 50
	item_data.scene_path = "res://entities/saveable_rigid_bodies/saveable_interactable_rigid_bodies/pickup_objects/shit_grenade_launcher/shit_grenade_launcher.tscn"
	item_data.view_model_path = "res://entities/saveable_character_bodies/advanced_character_bodies/viewmodels/shit_grenade_launcher_model.tscn"
	item_data.sound_path = "res://assets/tf2-grenade-launcher-shoot.mp3"
	item_data.projectile_path = "res://entities/saveable_rigid_bodies/projectiles/grenade.tscn"
	
	
	return item_data


# ACTUAL ITEMS

static func create_glock() -> ItemData:
	var item_data = ItemData.new()
	item_data.item_type = ItemData.ItemType.PISTOL
	item_data.display_name = "Glock"
	item_data.mass = 0.85
	item_data.value = 599.99
	item_data.uses_ammo = true
	item_data.ammo_type = AmmoDataFactory.create_revolver_ammo()
	item_data.mag_size = 8
	item_data.shooting_mode = ItemData.ShootingMode.SEMI_AUTO
	item_data.shooting_type = ItemData.ShootingType.HITSCAN

	item_data.first_shot_inaccuracy = 0.6
	item_data.subsequent_shot_inaccuracy = 7
	item_data.inaccuracy_reset_speed = 23




	item_data.initial_shooting_delay = 0.0
	item_data.between_shooting_delay = 0.2
	item_data.hitscan_range = 30
	item_data.damage = 55
	item_data.scene_path = "res://entities/saveable_rigid_bodies/saveable_interactable_rigid_bodies/pickup_objects/glock/glock.tscn"
	item_data.view_model_path = "res://entities/saveable_character_bodies/advanced_character_bodies/viewmodels/glock_model.tscn"
	item_data.sound_path = "res://assets/gun-shot-359196.mp3"
	
	item_data.animation_name = "glock"
	return item_data

static func create_ak() -> ItemData:
	var item_data = ItemData.new()
	item_data.item_type = ItemData.ItemType.RIFLE
	item_data.display_name = "AK-47"
	item_data.mass = 0.85
	item_data.value = 699.99
	item_data.uses_ammo = true
	item_data.ammo_type = AmmoDataFactory.create_rifle_ammo()
	item_data.mag_size = 8
	item_data.shooting_mode = ItemData.ShootingMode.AUTO
	item_data.shooting_type = ItemData.ShootingType.HITSCAN
	
	item_data.first_shot_inaccuracy = 0.4
	item_data.subsequent_shot_inaccuracy = 4.7
	item_data.inaccuracy_reset_speed = 18



	item_data.initial_shooting_delay = 0.0
	item_data.between_shooting_delay = 0.1
	item_data.hitscan_range = 30
	item_data.damage = 55
	item_data.scene_path = "res://entities/saveable_rigid_bodies/saveable_interactable_rigid_bodies/pickup_objects/ak/ak.tscn"
	item_data.view_model_path = "res://entities/saveable_character_bodies/advanced_character_bodies/viewmodels/ak_model.tscn"
	item_data.sound_path = "res://assets/submachine-gun-79846.mp3"
	
	item_data.animation_name = "ak"
	return item_data


static func create_crowbar() -> ItemData:
	var item_data = ItemData.new()
	item_data.item_type = ItemData.ItemType.MISC
	item_data.display_name = "Crowbar"
	item_data.mass = 1.2
	item_data.value = 34.99
	item_data.uses_ammo = false
	item_data.ammo_type = AmmoDataFactory.create_default_ammo()
	item_data.mag_size = 8
	item_data.shooting_mode = ItemData.ShootingMode.AUTO
	item_data.shooting_type = ItemData.ShootingType.HITSCAN

	item_data.first_shot_inaccuracy = 0.1
	item_data.subsequent_shot_inaccuracy = 0.4
	item_data.inaccuracy_reset_speed = 40
	
	item_data.initial_shooting_delay = 0.3
	item_data.between_shooting_delay = 0.2
	item_data.hitscan_range = 1.5
	item_data.damage = 55
	item_data.scene_path = "res://entities/saveable_rigid_bodies/saveable_interactable_rigid_bodies/pickup_objects/crowbar/crowbar.tscn"
	item_data.view_model_path = "res://entities/saveable_character_bodies/advanced_character_bodies/viewmodels/crowbar_model.tscn"
	item_data.sound_path = "res://assets/sword-slash.mp3"
	
	item_data.animation_name = "crowbar"
	return item_data
