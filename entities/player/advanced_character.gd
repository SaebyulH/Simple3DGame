extends SaveableCharacterBody3D
class_name AdvancedCharacter


# Universal
enum MoveMode {WALK, SPRINT, CROUCH}
const DEFAULT_SKIN_ROTATION := Vector3(0, PI, 0)
const SNAP_FIRST_PERSON_DISTANCE := 1
const SPRING_EXTENDED_LENGTH := 1.8
const GRAVITY := 9.8
const SPRINT_FACTOR := 1.33
const CROUCH_FACTOR := 0.66
const INTERACT_DISTANCE := 2.0 # Interact Distance for interactable props


# Universal
var y_velocity := 0.0
var is_aiming := false
var can_shoot: bool = true
var inventory_data: InventoryData = InventoryData.new()
var character_data : CharacterData = CharacterData.new()
var move_mode := MoveMode.WALK
var interact_target: Node = null


######################################################
# Universal
@onready var processor : Node
@onready var skin := $Skin/MaxSkin
@onready var animation_node := $Skin/MaxSkin/Animation
@onready var raycast := $Head/RayCast3D
@onready var equipped_item := $Skin/MaxSkin/Max_Shooter/max/Skeleton3D/HandBone/EquippedItem  # Update path as needed
@onready var muzzle_flash := $Skin/MaxSkin/Max_Shooter/max/Skeleton3D/HandBone/MuzzleFlash
@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3D
@onready var head := $Head
@export var destination_node : Node3D

@onready var initial_timer := $InitialShotTimer
@onready var between_timer := $BetweenShotTimer


# Ready empty for now ##########################################################
func _ready() -> void:
	processor = get_parent().get_parent().get_node("Processor")
	character_data = CharacterFactory.create_advanced_npc_character_data()
	inventory_data = InventoryFactory.create_advanced_npc_inventory_data()
	unimmobilize()
	update_equipped_item()
	#hud.update_ammo_label(inventory_data)
	skin.rotation = DEFAULT_SKIN_ROTATION
	

# Process functions ############################################################
func _process(delta):
	pass
	#
	## Interactions
	#check_for_interactable()
	
	# Camera
func _physics_process(delta):
	if not is_on_floor():
		y_velocity -= GRAVITY * delta
	else:
		y_velocity = 0

	is_aiming = inventory_data.item_mode == InventoryData.ItemMode.ACTIVE and not inventory_data.items.is_empty()

	if character_data.can_move:
		var direction = Vector3()
		navigation_agent.target_position = destination_node.global_position
		direction = navigation_agent.get_next_path_position() - global_position

		# Rotate body (Y axis only)
		var look_dir = destination_node.global_position - global_position
		look_dir.y = 0
		if look_dir.length_squared() > 0.01:
			look_at(global_position + look_dir.normalized(), Vector3.UP)

		# ✅ Rotate head on X axis (pitch) toward destination
		var head_pos = head.global_position
		var to_target = destination_node.global_position - head_pos
		var flat_distance = Vector2(to_target.x, to_target.z).length()
		var pitch_angle = atan2(to_target.y, flat_distance)  # ✅ Corrected: positive looks down

		# Smoothly rotate head (optional)
		head.rotation.x = lerp_angle(head.rotation.x, pitch_angle, delta * 5.0)
		
		
		# Check if player is within weapon range, then fire
		var item = inventory_data.get_current_item()
		if item and destination_node:  # destination_node is assumed to be the player
			var distance_to_target = global_position.distance_to(destination_node.global_position)
			if distance_to_target <= item.range:
				move_mode = MoveMode.CROUCH
				perform_primary_fire()
			else:
				move_mode = MoveMode.SPRINT
		# Move
		velocity = direction.normalized() * get_effective_speed()
		velocity.y = y_velocity
		move_and_slide()
	else:
		velocity = Vector3.ZERO
		velocity.y = y_velocity
		move_and_slide()

	
func get_effective_speed() -> float:
	var factor = (SPRINT_FACTOR if move_mode == MoveMode.SPRINT else (CROUCH_FACTOR if move_mode == MoveMode.CROUCH else 1))
	return character_data.speed * factor

# Controls #####################################################################

# Checks for interactible inside of a range 
func check_for_interactable():
	# This is so that in 3rd person we have more reach
	raycast.target_position = Vector3.FORWARD * (INTERACT_DISTANCE + SPRING_EXTENDED_LENGTH)
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target and target.has_method("interact"):
			interact_target = target
			var target_name = ""
			var verb = "Interact"
			if target.has_method("get_display_name"):
				target_name = target.get_display_name()
			elif "display_name" in target:
				target_name = target.display_name
			else:
				target_name = target.name
			
			if target.has_method("get_interact_verb"):
				verb = target.get_interact_verb()
			if target and target.has_method("trade") and target.tradeable:
				interact_target = target
			return
		
	# If nothing valid hit
	interact_target = null
	
# Save functions ###################################################################################
func get_save_data() -> Dictionary:
	var data = super()
	# Universal
	#data["position"] = global_transform.origin
	#data["velocity"] = velocity
	#data["rotation"] = global_rotation
	data["scene_path"] = "res://entities/player/Player.tscn"
	data["move_mode"] = move_mode
	data["inventory_data"] = inventory_data
	data["character_data"] = character_data
	
	# Player Specific
	data["head_rotation_x"] = $Head.rotation.x
	return data

#TODO: Fix to use composition
func apply_save_data(data: Dictionary):
	super(data)
	
	# Universal
	#global_transform.origin = data["position"]
	#velocity = data["velocity"]
	#rotation = data["rotation"]
	if data.has("move_mode"):
		move_mode = data["move_mode"]
	if data.has("inventory_data"):
		inventory_data = data["inventory_data"]
	if data.has("character_data"):
		character_data = data["character_data"]
		
		#Player Specific
	if data.has("head_rotation_x"):
		$Head.rotation.x = data["head_rotation_x"]
	
	# Set up rest based on the data
	update_equipped_item()

# Gameplay Functions ###############################################################################
func change_health(amount: int):
	character_data.change_health(amount)
	if character_data.health <= 0:
		die()
	
func die():
	for item in inventory_data.items:
		processor.spawn_pickup_near_character(item, self)
	queue_free()

func change_wealth(amount: int):
	if character_data.wealth + amount < 0:
		print("wealth unchanged, player would be broke")
	else:
		character_data.wealth += amount
		var status = "enriched" if (amount >= 0) else "impoverished"
		print("Player " + status + " by " + str(abs(amount)) + " dollars.")
		if character_data.wealth + amount < 0:
			print("player is broke")


func perform_secondary_fire():
	if inventory_data.items.is_empty():
		is_aiming = false
	else:
		if not inventory_data.item_mode == InventoryData.ItemMode.ACTIVE:
			inventory_data.item_mode = InventoryData.ItemMode.ACTIVE
			update_equipped_item()


# Checks for object in range of current item, then shoots if in range
func perform_primary_fire() -> void:
	if not can_shoot or not is_aiming:
		return
	
	if inventory_data.items.is_empty():
		is_aiming = false
	else:
		if not inventory_data.item_mode == InventoryData.ItemMode.ACTIVE:
			is_aiming = true
			inventory_data.item_mode = InventoryData.ItemMode.ACTIVE
			update_equipped_item()

	if inventory_data.current_index < 0 or inventory_data.current_index >= inventory_data.get_size():
		print("No item equipped")
		return
	
	can_shoot = false  # block further shots
	await fire_weapon_with_delay()
	
func create_local_timer(wait_time: float) -> void:
	var timer := Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = true
	add_child(timer)
	timer.start()
	await timer.timeout
	timer.queue_free()


## The coroutine for firing after initial delay
func fire_weapon_with_delay() -> void:
	var item = inventory_data.get_current_item()
	
	# Wait initial shooting delay BEFORE firing
	await create_local_timer(item.initial_shooting_delay)


	# Do raycast
	raycast.target_position = Vector3.FORWARD * item.range
	raycast.force_raycast_update()

	var result: bool = inventory_data.shoot_current_weapon()

	if result:
		#hud.update_ammo_label(inventory_data)
		
		$Skin/MaxSkin/Max_Shooter/max/Skeleton3D/HandBone/GunSound.stream = load(item.sound_path)
		$Skin/MaxSkin/Max_Shooter/max/Skeleton3D/HandBone/GunSound.play()
		animation_node.shoot()

		if item.uses_ammo:
			var weapon = equipped_item.get_child(0) if equipped_item.get_child_count() > 0 else null

			if weapon and weapon.has_node("MuzzleOrigin"):
				var muzzle = weapon.get_node("MuzzleOrigin")
				muzzle_flash.global_position = muzzle.global_position
				muzzle_flash.global_rotation = muzzle.global_rotation
				muzzle_flash.fire_weapon()

		if raycast.is_colliding():
			var target = raycast.get_collider()
			if target and target.has_method("change_health"):
				target.change_health(-item.damage)
				print("Attacked ", target, " for ", item.damage, " damage")

	# Wait between shots (non-blocking)
	await create_local_timer(item.between_shooting_delay)

	can_shoot = true


# This updates the item that the player has equipped
func update_equipped_item():
	if inventory_data.item_mode == InventoryData.ItemMode.ACTIVE and inventory_data.current_index >= 0 and inventory_data.current_index < inventory_data.get_size():
		var item = inventory_data.get_current_item()
		equipped_item.equip_item(item)
		print("visually equipped" + item.display_name)
	else:
		equipped_item.equip_item(null)
		print("visually unequipped any item")

func set_inventory_selection(index: int):
	inventory_data.set_current_index(index)
	inventory_data.item_mode = InventoryData.ItemMode.ACTIVE
	update_equipped_item()

func drop_current_item():
	if inventory_data.current_index >= 0:
		processor.spawn_pickup_near_character(inventory_data.remove_current_item(), self)
		update_equipped_item()

func holster():
	if(inventory_data.item_mode == InventoryData.ItemMode.ACTIVE):
		inventory_data.item_mode = InventoryData.ItemMode.HOLSTER
		is_aiming = false
		print("item holstered but still active")
	elif(inventory_data.item_mode == InventoryData.ItemMode.HOLSTER):
		equipped_item.equip_item(null)
		inventory_data.item_mode = InventoryData.ItemMode.INACTIVE
		print("unequipped any item")

func immobilize():
	character_data.can_move = false

func unimmobilize():
	character_data.can_move = true
####################################################################################################
