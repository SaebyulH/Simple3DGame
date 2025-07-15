extends NonPlayerCharacter
class_name ArmedEnemy

@onready var equipped_item : Node3D


func _ready() -> void:
	super()
	talkable = true
	tradeable = true
	character_data = CharacterFactory.create_armed_enemy_character_data()
	inventory_data = InventoryFactory.create_armed_enemy_inventory_data()
	scene_path = "res://entities/saveable_character_bodies/npcs/armed_enemy/ArmedEnemy.tscn"
	equipped_item = $Skin/MaxSkin/Max_Stealth_Shooter/max/Skeleton3D/Hand/EquippedItem
	update_equipped_item()

func update_equipped_item():
	if inventory_data.current_index >= 0 and inventory_data.current_index < inventory_data.get_size():
		var item = inventory_data.get_current_item()
		equipped_item.equip_item(item)
		print("equipped" + item.display_name)
	else:
		equipped_item.equip_item(null)
		print("unequipped any item")


func _physics_process(delta):
	if not player:
		return

	var to_player = player.global_transform.origin - global_transform.origin
	to_player.y = 0  # Ignore vertical difference for rotation

	var distance = to_player.length()
	if distance > 0.1:
		var direction = to_player.normalized()
		velocity = direction * character_data.speed

		# Make the character face the player
		look_at(player.global_transform.origin, Vector3.UP)
	else:
		velocity = Vector3.ZERO

	if distance <= 2:
		player.change_health(-1)

	move_and_slide()
