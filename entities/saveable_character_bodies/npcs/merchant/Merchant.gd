extends NonPlayerCharacter
class_name Merchant

func _ready() -> void:
	super()
	scene_path = "res://entities/saveable_character_bodies/npcs/merchant/Merchant.tscn"
	talkable = true
	tradeable = true
	
	character_data = CharacterFactory.create_merchant_character_data()
	inventory_data = InventoryFactory.create_merchant_inventory_data()

func interact(player: Player):
	start_dialogue("default_merchant_timeline")
