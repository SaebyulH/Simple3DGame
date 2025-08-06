extends SaveableCharacterBody3D
class_name AdvancedCharacter

# Universal
enum MoveMode {WALK, SPRINT, CROUCH}
enum HoldMode {HOLSTER, HOLD, AIM, SCOPE}
const DEFAULT_SKIN_ROTATION := Vector3(0, 0, 0)
const SNAP_FIRST_PERSON_DISTANCE := 1
const SPRING_EXTENDED_LENGTH := 2.7 #1.8
const GRAVITY := 9.8
const SPRINT_FACTOR := 1.33
const CROUCH_FACTOR := 0.66
const INTERACT_DISTANCE := 2.0 # Interact Distance for interactable props

const ACCELERATION := 1.0

# Universal
var display_name :String
var y_velocity := 0.0
var can_shoot: bool = true
var inventory_data: InventoryData = InventoryData.new()
var character_data : CharacterData = CharacterData.new()
var move_mode := MoveMode.WALK
var hold_mode := HoldMode.AIM
var interact_target: Node = null
var trade_target: Node = null

var hostile := false

@export var dialogic_name := "THIS MUST MATCH THE DISPLAY NAME OF AN EXISTING DIALOGIC CHARACTER"
######################################################
# Universal
@onready var processor: Node = get_parent().get_parent().get_node("Processor")
@onready var skin:= $Skin/MaxSkin
@onready var animation_node := $Skin/MaxSkin/NewAnimation

@onready var interact_raycast : RayCast3D #= $Head/InteractRayCast3D
@onready var attack_raycast : RayCast3D #= $Head/AttackRayCast3D2

#@onready var equipped_item := $Skin/MaxSkin/Human_Ultimate_Lipsync/rig/Skeleton3D/HandBone/EquippedItem  # Update path as needed
@onready var muzzle_flash := $Skin/MaxSkin/Human_Ultimate_Lipsync/rig/Skeleton3D/HandBone/MuzzleFlash
@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3D
@onready var head := $Head


# This is what will be attacked. TODO make this more universal
@export var destination_node : AdvancedCharacter

@onready var initial_timer := $InitialShotTimer
@onready var between_timer := $BetweenShotTimer

@onready var gun_sound := $Skin/MaxSkin/Human_Ultimate_Lipsync/rig/Skeleton3D/HandBone/GunSound
@onready var hit_sound := $Skin/MaxSkin/Human_Ultimate_Lipsync/rig/Skeleton3D/HeadBone/HitSound

@onready var selfie_cam := $SelfieCamera
@onready var ots_cam := $OTSCamera


var dialogic_current_speaker :String
# Ready empty for now ##########################################################
func _ready() -> void:
	super()
	add_to_group("characters")
	setup_uninitialized_variables()
	update_equipped_item()
	
	
	setup_dialogic_signals()
	setup_skin()
	unimmobilize()
	

func setup_uninitialized_variables():
	character_data = CharacterDataFactory.create_advanced_npc_character_data()
	inventory_data = InventoryDataFactory.create_advanced_npc_inventory_data()
	display_name = dialogic_name
	interact_raycast = get_node_or_null("Head/InteractRayCast3D")
	attack_raycast = get_node_or_null("Head/AttackRayCast3D")

func setup_skin():
	skin.rotation = DEFAULT_SKIN_ROTATION
	animation_node.randomize_character()

func setup_dialogic_signals():
	# Dialogic Signals
	Dialogic.signal_event.connect(DialogicSignal)
	Dialogic.timeline_started.connect(func(): 
		character_data.can_move = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		processor.in_dialogue = true
		)
	Dialogic.timeline_ended.connect(func(): 
		character_data.can_move = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		processor.in_dialogue = false
		CameraManager.reset_cam()
		)
	Dialogic.Text.speaker_updated.connect(
		func(speaker: DialogicCharacter):
			#if the speaker exists in dialogic
			if speaker and speaker.display_name:
				dialogic_current_speaker = speaker.display_name
				CameraManager.auto_camera(speaker.display_name)
	)
	Dialogic.Text.animation_textbox_new_text.connect(func():
		animation_node.set_random_expression()
	)




	
func DialogicSignal(arg: String):
	if arg == "hostile":
		if dialogic_current_speaker == dialogic_name:
			hostile = true
			print(name, ": NOW HOSTILE")
		
	if arg == "test_lipsync":
		if dialogic_current_speaker == dialogic_name:
			$AudioStreamPlayerLipsync3D.play_lipsync(preload("res://assets/test_wav_voicelines/Harvard list 01.wav-lipsync.tres"))
	if arg == "pullout":
		if dialogic_current_speaker == dialogic_name:
			perform_pullout()
	if arg == "reload":
		if dialogic_current_speaker == dialogic_name:
			perform_reload()
	if arg == "inspect":
		if dialogic_current_speaker == dialogic_name:
			perform_inspect()
	if arg == "pullout":
		if dialogic_current_speaker == dialogic_name:
			perform_pullout()
	if arg == "primary_fire":
		if dialogic_current_speaker == dialogic_name:
			perform_primary_fire()
	if arg == "randomize":
		if dialogic_current_speaker == dialogic_name:
			animation_node.randomize_character()
	
# Talking to the character
func interact(player: AdvancedCharacter):
	interact_target = player
	var to_target = interact_target.global_transform.origin - global_transform.origin
	to_target.y = 0  # Ignore vertical difference to only rotate on Y axis

	if to_target.length_squared() > 0.001:  # Avoid NaNs when vectors are too small
		look_at(global_transform.origin + to_target.normalized(), Vector3.UP)
	
	if dialogic_name == "Advanced Character":
		Dialogic.start("advanced_npc_autocam_timeline")
	elif dialogic_name == "Harvard Lister":
		Dialogic.start("test_lipsync_timeline")
	elif dialogic_name == "Animation Demonstration Character":
		Dialogic.start("animation_demonstration_timeline")

	#interact_target = player
	print(name, ": Started Dialogic")

func get_interact_verb() -> String:
	return "Talk"

func set_selfie_cam():
	selfie_cam.set_current(true)

func set_ots_cam():
	var to = interact_target.head if interact_target.head else interact_target
	ots_cam.look_at(to.global_position + Vector3(0, -0.3, 0))
	ots_cam.set_current(true)



func _on_audio_stream_player_lipsync_mouth_shape_changed(mouth_shape: int) -> void:
	var lip_shape :String = "X"
	match mouth_shape:
		0: # Rest position
			lip_shape = "x"
		1: # Very closed
			lip_shape = "a"
		2: # Slightly open (e.g. EE sound)
			lip_shape = "b"
		3: # Open (e.g. AE sound)
			lip_shape = "c"
		4: # Wide open
			lip_shape = "d"
		5: # Slightly rounded (e.g. the i in bird)
			lip_shape = "e"
		6: # Puckered lips
			lip_shape = "f"
		7: # Biting lower lip (F sound)
			lip_shape = "g"
		8: # Tongue on top of mouth (L sound)
			lip_shape = "h"
	animation_node.set_lip_shape(lip_shape)

# Process functions ############################################################
#func _process(delta):
	#pass

# Basic Script to be hostile when attacked or just stand there and talk if not
func _physics_process(delta):

	if not is_on_floor():
		y_velocity -= GRAVITY * delta
	else:
		y_velocity = 0
		
	velocity = Vector3.ZERO
	velocity.y = y_velocity
	move_and_slide()
	
	if hostile:
		if not global_position or not destination_node:
			return
		hunt_target(delta)
		

func hunt_target(delta):
	print(name, ": HUNTING TARGET")
	var aim_node = destination_node
	if destination_node.head:
		aim_node = destination_node.head
	
	var distance_to_target = global_position.distance_to(destination_node.global_position)
	if distance_to_target >= 30:
		pass
	if character_data.can_move:
		var direction = Vector3()
		navigation_agent.target_position = destination_node.global_position
		direction = navigation_agent.get_next_path_position() - global_position

		# Rotate body (Y axis only)
		var look_dir = aim_node.global_position - global_position
		look_dir.y = 0
		if look_dir.length_squared() > 0.01:
			look_at(global_position + look_dir.normalized(), Vector3.UP)

		# ✅ Rotate head on X axis (pitch) toward destination
		var head_pos = head.global_position
		var to_target = aim_node.global_position - head_pos
		var flat_distance = Vector2(to_target.x, to_target.z).length()
		var pitch_angle = atan2(to_target.y, flat_distance)  # ✅ Corrected: positive looks down

		# Smoothly rotate head (optional)
		head.rotation.x = lerp_angle(head.rotation.x, pitch_angle, delta * 5.0)
		
		# Check if player is within weapon hitscan_range, then fire
		var item = inventory_data.get_current_item()
		if item and destination_node:  # destination_node is assumed to be the player
			#var distance_to_target = global_position.distance_to(destination_node.global_position)
			if distance_to_target <= item.hitscan_range: #TODO: this is bc they suck at aiming in lore ig
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

# Get the effective speed, taking into account move mode
func get_effective_speed() -> float:
	var factor: float
	if move_mode == MoveMode.SPRINT:
		factor = SPRINT_FACTOR
	elif move_mode == MoveMode.CROUCH:
		factor = CROUCH_FACTOR
	else:
		factor = 1.0
	return character_data.speed * factor

# Controls #####################################################################

# Checks for interactable inside of a hitscan_range 
func check_for_interactable():
	var target = _get_interact_target()

	if target and target.has_method("interact"):
		interact_target = target
	else:
		interact_target = find_interactable_parent(target)

	if target and target.has_method("trade"):
		trade_target = target
	else:
		trade_target = null

func find_interactable_parent(node: Node) -> Node:
	if node == null:
		return null

	if node.has_method("interact"):
		return node
	elif node.get_parent():
		return find_interactable_parent(node.get_parent())
	else:
		return null





func _get_interact_target() -> Node3D:
	# This is so that in 3rd person we have more reach
	interact_raycast.target_position = Vector3.FORWARD * (INTERACT_DISTANCE + SPRING_EXTENDED_LENGTH)
	interact_raycast.force_raycast_update()
	if interact_raycast.is_colliding():
		return interact_raycast.get_collider()
	else: 
		return null

# Save functions ###################################################################################
func get_save_data() -> Dictionary:
	var data = super()
	data["scene_path"] = scene_path
	data["move_mode"] = move_mode
	data["inventory_data"] = inventory_data
	data["character_data"] = character_data
	#data["destination_node"] = destination_node
	
	data["head_rotation_x"] = $Head.rotation.x
	return data

#TODO: Fix to use composition
func apply_save_data(data: Dictionary):
	super(data)
	if data.has("move_mode"):
		move_mode = data["move_mode"]
	if data.has("inventory_data"):
		inventory_data = data["inventory_data"]
	if data.has("character_data"):
		character_data = data["character_data"]
	#if data.has("destination_node"):
		#destination_node = data["destination_node"]
	if data.has("head_rotation_x"):
		$Head.rotation.x = data["head_rotation_x"]
	
	# Set up rest based on the data
	update_equipped_item()

# Gameplay Functions ###############################################################################
func change_health(amount: int):
	hostile = true
	character_data.change_health(amount)
	if character_data.health <= 0:
		die()
	
func die():
	for item in inventory_data.items:
		processor.spawn_pickup_near_character(item, self)
	processor.spawn_ragdoll_near_node($Skin/MaxSkin/Human_Ultimate_Lipsync, self)
	queue_free()

func change_wealth(amount: int):
	if character_data.wealth + amount < 0:
		print(name, ": wealth unchanged, player would be broke")
	else:
		character_data.wealth += amount
		var status = "enriched" if (amount >= 0) else "impoverished"
		print(name, ": Player " + status + " by " + str(abs(amount)) + " dollars.")
		if character_data.wealth + amount < 0:
			print(name, ": player is broke")

func perform_secondary_fire():
	if inventory_data.get_current_item():
		toggle_scope()

func toggle_scope():
	if hold_mode == HoldMode.SCOPE:
		hold_mode = HoldMode.AIM
	elif hold_mode == HoldMode.AIM:
		hold_mode = HoldMode.SCOPE
	else:
		hold_mode = HoldMode.AIM

func perform_reload():
	inventory_data.change_ammo_of_current_weapon(10)
	animation_node.reload()

func perform_inspect():
	animation_node.inspect()

func perform_pullout():
	animation_node.pullout()

# Checks for object in hitscan_range of current item, then shoots if in hitscan_range
func perform_primary_fire() -> void:
	if not can_shoot:
		return

	elif hold_mode == HoldMode.HOLD:
		# Start aiming and do nto shoot
		hold_mode = HoldMode.AIM
		animation_node.equip_item(inventory_data.get_current_item())
		return
	
	
	if inventory_data.items.is_empty():
		return

	if inventory_data.current_index < 0 or inventory_data.current_index >= inventory_data.get_size():
		print(name, ": No item equipped")
		return
	if not check_for_raycast_collision():
		return
	#pass all checks
	can_shoot = false  # block further shots
	await fire_weapon_with_delay()

func create_local_timer(wait_time: float) -> void:
	if wait_time < 0.05:
		wait_time = 0.05
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
	


	var result: bool = inventory_data.shoot_current_weapon()
	if result:
		gun_sound.stream = load(item.sound_path)
		gun_sound.play()
		animation_node.shoot()

		if item.uses_ammo:
			var weapon = animation_node.get_equipped_item_child()

			if weapon and weapon.has_node("MuzzleOrigin"):
				var muzzle = weapon.get_node("MuzzleOrigin")
				muzzle_flash.global_position = muzzle.global_position
				muzzle_flash.global_rotation = muzzle.global_rotation
				muzzle_flash.fire_weapon()
		
		# PROJECTILE VS HITSCAN
		if item.shooting_type == ItemData.ShootingType.HITSCAN:
			# Do raycast
			attack_raycast.target_position = Vector3.FORWARD * item.hitscan_range
			attack_raycast.force_raycast_update()
			
			if attack_raycast.is_colliding():
				var target = attack_raycast.get_collider()
				if target:
					var crit = false
					if target.is_in_group("crit_hurtbox"):
						crit = true
						print(name, ": CRITIAL HIT")
					else:
						crit = false
					
					var enemy = find_enemy_root(target)
					var multiplier = 4.0 if crit else 1.0
					if enemy:
						enemy.change_health(-(item.damage * multiplier))
						if "hit_sound" in enemy and enemy is not Player:
							if crit:
								enemy.hit_sound.stream = load("res://assets/critical-hit-sounds-effect.mp3")
							else:
								enemy.hit_sound.stream = load("res://assets/tf2_hitsound.mp3")
							enemy.hit_sound.play()
						
							
						
					print(name, ": Hitscan Attacked ", target, " for ", item.damage, " damage")
		elif item.shooting_type == ItemData.ShootingType.PROJECTILE:
			processor.spawn_projectile(item.projectile_path, head)
			
	# Wait between shots (non-blocking)
	await create_local_timer(item.between_shooting_delay)

	can_shoot = true

func find_enemy_root(node)-> Node:
	while node != null:
		#if node.is_in_group("damageable_character"):
		if node.has_method("change_health"):
			print(name, ": enemy found with change health function")
			
			return node
		node = node.get_parent()
	print(name, ": enemy NOT found with change health function")
	return null

#Uses interact one bc it is meant to be not accurate
func check_for_raycast_collision() -> bool:
	var item = inventory_data.get_current_item()
	interact_raycast.target_position = Vector3.FORWARD * item.hitscan_range
	interact_raycast.force_raycast_update()
	if interact_raycast.is_colliding():
			var target = interact_raycast.get_collider()
			if target and target is Player:
				return true
	return false








# This updates the item that the player has equipped
func update_equipped_item():
	if inventory_data.get_current_item():
		
		var item = inventory_data.get_current_item()
		animation_node.equip_item(item)
		
		
		print(name, ": equipped ", item.display_name)
		await create_local_timer(0.0001)
		
		
		perform_pullout()
		hold_mode = HoldMode.AIM
		
		print("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT:", item.display_name)
		
	else:
		#await animation_node.switch()
		animation_node.equip_item(null)
		hold_mode = HoldMode.HOLSTER
		print(name, ": visually unequipped any item")

func drop_current_item():
	if inventory_data.current_index >= 0:
		processor.spawn_pickup_near_character(inventory_data.remove_current_item(), self)
		update_equipped_item()

func holster():
	if(hold_mode == HoldMode.AIM or hold_mode == HoldMode.SCOPE):
		hold_mode = HoldMode.HOLD
		#is_aiming = false
		print(name, ": item holstered but still active")
	elif hold_mode == HoldMode.HOLD:
		animation_node.equip_item(null)
		hold_mode = HoldMode.HOLSTER
		inventory_data.set_current_index(-1)
		print(name, ": unequipped any item")

func immobilize():
	character_data.can_move = false

func unimmobilize():
	character_data.can_move = true
####################################################################################################
