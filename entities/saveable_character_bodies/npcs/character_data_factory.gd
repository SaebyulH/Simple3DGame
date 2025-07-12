extends Node

func create_default_character_data() -> CharacterData:
	var character_data = CharacterData.new()
	character_data.speed = 1.0
	character_data.jump_force = 1.0
	character_data.health = 100
	character_data.max_health = 100
	character_data.display_name = "Default Character"
	character_data.wealth = 0
	return character_data

func create_player_character_data() -> CharacterData:
	var character_data = CharacterData.new()
	character_data.speed = 5.0
	character_data.jump_force = 5.0
	character_data.health = 100
	character_data.max_health = 100
	character_data.display_name = "Main Character"
	character_data.wealth = 0
	return character_data

func create_merchant_character_data() -> CharacterData:
	var character_data = CharacterData.new()
	character_data.speed = 5.0
	character_data.jump_force = 5.0
	character_data.health = 1000
	character_data.max_health = 1000
	character_data.display_name = "Merchant Character"
	character_data.wealth = 1000
	return character_data
