extends NonPlayerCharacter
class_name BasicEnemy

var y_velocity := 0.0

func _ready() -> void:
	super()
	talkable = true
	tradeable = false
	character_data = CharacterFactory.create_basic_enemy_character_data()
	inventory_data = InventoryFactory.create_basic_enemy_inventory_data() #InventoryFactory.create_default_inventory_data()
	scene_path = "res://entities/saveable_character_bodies/npcs/basic_enemy/basic_enemy.tscn"

func _physics_process(delta):
	
	if not player:
		return
	
	var to_player = player.global_transform.origin - global_transform.origin
	to_player.y = 0

	var distance = to_player.length()
	if distance > 0.1:
		var direction = to_player.normalized()
		velocity = direction * character_data.speed
	else:
		velocity = Vector3.ZERO
	
	y_velocity -= 9.8 *delta
	velocity.y = y_velocity
	if distance <= 1.3:
		player.change_health(-1)
	move_and_slide()
