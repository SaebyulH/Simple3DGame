extends NonPlayerCharacter
class_name BasicEnemy

func _ready() -> void:
	super()
	scene_path = "res://entities/saveable_character_bodies/npcs/basic_enemy/basic_enemy.tscn"
	talkable = true
	tradeable = true
	inventory_data.add_item(ItemFactory.create_shit_pistol())
	inventory_data.add_item(ItemFactory.create_shit_pistol())
	inventory_data.add_item(ItemFactory.create_shit_pistol())
	inventory_data.add_item(ItemFactory.create_shit_pistol())
	inventory_data.add_item(ItemFactory.create_shit_pistol())
	inventory_data.add_item(ItemFactory.create_shit_rifle())
	inventory_data.add_item(ItemFactory.create_shit_rifle())
	inventory_data.add_item(ItemFactory.create_shit_rifle())
	inventory_data.add_item(ItemFactory.create_shit_rifle())
	inventory_data.add_item(ItemFactory.create_shit_rifle())
