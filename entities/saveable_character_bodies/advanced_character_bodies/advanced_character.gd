extends SaveableCharacterBody3D

class_name AdvancedCharacter

# UNIVERSALS
enum MoveMode {WALK, SPRINT, CROUCH}
# HOLSTER means weapon is on the character's back, belt, etc and is not held in the hand
# HOLD means weapon is held in the hand but is not aimed. TODO: Return to this mode out of combat to avoid weapon blocking view.
# AIM means weapon is held and aimed, but character is not using sight/scope
# SCOPE means weapon is aimed directly in front of character's right eye TODO: Add left handed viewmodel support: will require additional animations
enum HoldMode {HOLSTER, HOLD, AIM, SCOPE}

const DEFAULT_SKIN_ROTATION := Vector3(0, 0, 0)
const SNAP_FIRST_PERSON_DISTANCE := 1
const SPRING_EXTENDED_LENGTH := 2.7 #1.8
const GRAVITY := 9.8
const SPRINT_FACTOR := 1.5
const CROUCH_FACTOR := 0.5
const INTERACT_DISTANCE := 2.0 # Interact Distance for interactable props

const CRIT_MULTIPLIER := 2

const ACCELERATION := 1.0
const MOVEMENT_INACCURACY_MULTIPLIER := 0.4 #how much movement impacts inaccuracy
const CROUCH_INACCURACY_MULTIPLIER := 0.7 # crouching reduces inaccuract by 30%

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

# Shooting
var inaccuracy:float=0
var max_inaccuracy:float=30.0

# Targeting
var scan_interval := 0.5   # scan twice a second
var next_scan_time := 0.0

# Dialogic
var dialogic_current_speaker :String

# Head Turn Logic ##################################################################################
var max_head_yaw := deg_to_rad(75)
const RESET_TIME: float = 0.6
var head_yaw := 0.0 # radians
var head_pitch := 0.0
var target_head_yaw : float
var turn_timer : float = 0.0
#var desired_yaw := 0.0
enum TurnMode {TURN_LEFT, NOT_TURNING, TURN_RIGHT}
var turn_state := TurnMode.NOT_TURNING

# This is what will be attacked. TODO make this more universal
@export var destination_node : AdvancedCharacter
@export var hostile := false
@export var dialogic_name := "THIS MUST MATCH THE DISPLAY NAME OF AN EXISTING DIALOGIC CHARACTER"
######################################################
# Universal
@onready var processor: Processor = get_parent().get_parent().get_node("Processor")
@onready var skin:= $Skin/MaxSkin
@onready var animation_node := $Skin/MaxSkin/Animation2026

@onready var interact_raycast : RayCast3D = $Head/InteractRayCast3D
@onready var attack_raycast : RayCast3D = $Head/AttackRayCast3D

@onready var equipped_item := $Skin/MaxSkin/Human2026/Armature/Skeleton3D/HandBone/EquippedItem  # Update path as needed
@onready var muzzle_flash := $Skin/MaxSkin/Human2026/Armature/Skeleton3D/HandBone/MuzzleFlash
@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3D
@onready var head := $Head

@onready var initial_timer := $InitialShotTimer
@onready var between_timer := $BetweenShotTimer

@onready var gun_sound := $Skin/MaxSkin/Human2026/Armature/Skeleton3D/HandBone/GunSound
@onready var hit_sound := $Skin/MaxSkin/Human2026/Armature/Skeleton3D/HeadBone/HitSound

@onready var selfie_cam := $SelfieCamera
@onready var ots_cam := $OTSCamera



# READY AND SETUP ##################################################################################
func _ready() -> void:
	super()
	add_to_group("characters")
	setup_uninitialized_variables()
	update_equipped_item()
	setup_dialogic_signals()
	setup_skin()
	unimmobilize()
	# start scanning at a random offset so enemies don't sync
	next_scan_time = Time.get_ticks_msec() / 1000.0 + randf() * scan_interval
	

func setup_uninitialized_variables():
	character_data = CharacterDataFactory.create_advanced_npc_character_data()
	inventory_data = InventoryDataFactory.create_advanced_npc_inventory_data()
	display_name = dialogic_name

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
	
# PLAYER INTERACTION, LIPSYNC, DIALOGUE ############################################################
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
	if hostile:
		return
	interact_target = player
	player.interact_target = self
	
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
func _process(delta):
	#_update_turn(delta)
	head.global_position = $Skin/MaxSkin/Human2026/Armature/Skeleton3D/HeadBone/AdjustedHead.global_position
	if inventory_data.get_current_item():
		inaccuracy -= inventory_data.get_current_item().inaccuracy_reset_speed * delta
		if inaccuracy < 0:
			inaccuracy = 0
		elif inaccuracy > max_inaccuracy:
			inaccuracy = max_inaccuracy

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
		# Scan only at staggered intervals
		var now = Time.get_ticks_msec() / 1000.0
		if now >= next_scan_time:
			next_scan_time = now + scan_interval
		hunt_target(delta)

# HEAD TURN MECHANIC ##############################################################################
func set_turn(pitch: float, yaw: float) -> void:
	
	head_yaw = yaw
	head_pitch = pitch

	var effective_max_head_yaw: float = (
		max_head_yaw
		if Vector3(velocity.x, 0.0, velocity.z) == Vector3.ZERO
		else 0.0
	)
	
	var overflow: float = 0.0
	if head_yaw > effective_max_head_yaw:
		overflow = head_yaw - effective_max_head_yaw
		head_yaw = effective_max_head_yaw
	elif head_yaw < -effective_max_head_yaw:
		overflow = head_yaw + effective_max_head_yaw
		head_yaw = -effective_max_head_yaw
		
	# Overflow into body yaw
	if overflow != 0.0:
		self.rotation.y += overflow
		head.rotation.y = head_yaw
		if velocity.y == 0:
			turn_state = TurnMode.TURN_LEFT if overflow < 0 else TurnMode.TURN_RIGHT
	else: turn_state = TurnMode.NOT_TURNING
			
	## If over the limit, start reset
	#if abs(head_yaw) > effective_max_head_yaw:
		#self.rotation.y += head_yaw
		#head_yaw = 0.0
		#
	head.rotation.x = clamp(head_pitch, deg_to_rad(-80), deg_to_rad(80))
	head.rotation.y = head_yaw

func change_turn(pitch: float, yaw: float) -> void:
	var target_yaw: float = head_yaw - yaw
	var target_pitch: float = head.rotation.x - pitch

	set_turn(target_pitch, target_yaw)

func aim_at(target_pos: Vector3) -> void:
	# --- BODY YAW ---
	var body_dir: Vector3 = target_pos - global_position
	body_dir.y = 0

	if body_dir.length_squared() > 0.001:
		var desired_yaw: float = atan2(-body_dir.x, -body_dir.z)
		global_rotation.y = desired_yaw

	# --- HEAD PITCH ---
	var head_pos: Vector3 = head.global_position
	var to_target: Vector3 = target_pos - head_pos

	var flat_distance: float = Vector2(to_target.x, to_target.z).length()
	if flat_distance > 0.001:
		var pitch_angle: float = atan2(to_target.y, flat_distance)
		head.rotation.x = pitch_angle

# BEHAVIOUR AND TARGETING ##########################################################################
func hunt_target(delta: float) -> void:
	if not destination_node:
		return

	print(name, ": HUNTING TARGET")

	# --- Aim target ---
	var aim_node: Node = destination_node
	if destination_node.has_node("Head"):
		aim_node = destination_node.head

	# --- Distance used for movement and shooting ---
	var distance_to_target: float = global_position.distance_to(destination_node.global_position)

	# --- Movement ---
	if character_data.can_move:
		# Path direction (navigation)
		var next_pos: Vector3 = navigation_agent.get_next_path_position()
		var direction: Vector3 = (next_pos - global_position).normalized()

		velocity = direction * get_effective_speed()

		# Make sure navigation keeps updating
		navigation_agent.target_position = destination_node.global_position

		# Aim at target
		aim_at(aim_node.global_position)
	else:
		velocity = Vector3.ZERO

	velocity.y = y_velocity
	move_and_slide()

	# --- Shooting ---
	var item = inventory_data.get_current_item()
	if item and destination_node:
		if distance_to_target <= item.hitscan_range:
			var tolerance: float = distance_to_target * 0.1

			if inaccuracy <= tolerance:
				move_mode = MoveMode.CROUCH
				inaccuracy += 3.5
				perform_primary_fire()
			else:
				move_mode = MoveMode.SPRINT
		else:
			move_mode = MoveMode.SPRINT

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


# Gameplay Functions ###############################################################################
func change_health(amount: int):
	hostile = true
	character_data.change_health(amount)
	if character_data.health <= 0:
		die()
	
func die():
	for item in inventory_data.items:
		processor.spawn_pickup_near_character(item, self)
	processor.spawn_ragdoll_near_node($Skin/MaxSkin/Human2026, self)
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
		return
		#wait_time = 0.05
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
	var muzzle_location : Vector3 = Vector3.ZERO
	# Wait initial shooting delay BEFORE firing
	await create_local_timer(item.initial_shooting_delay)
	
	var result: bool = inventory_data.shoot_current_weapon()
	if result:
		gun_sound.pitch_scale = 1.0 if inventory_data.get_current_weapon_ammo_count() >=10 else 1.5
		gun_sound.stream = load(item.sound_path)
		gun_sound.play()
		animation_node.shoot()

		if item.uses_ammo:
			var weapon = animation_node.get_equipped_item_child()

			if weapon and weapon.has_node("MuzzleOrigin"):
				var muzzle = weapon.get_node("MuzzleOrigin")
				muzzle_flash.global_position = muzzle.global_position
				muzzle_location = muzzle.global_position
				muzzle_flash.global_rotation = muzzle.global_rotation
				muzzle_flash.fire_weapon()
		
		# PROJECTILE VS HITSCAN
		if item.shooting_type == ItemData.ShootingType.HITSCAN:
			
			# Do raycast
			attack_raycast.target_position = Vector3.FORWARD * item.hitscan_range
			# Reset rotation to face forward
			attack_raycast.rotation = Vector3.ZERO
			
			inaccuracy += inventory_data.get_current_item().first_shot_inaccuracy
			
			var effective_inaccuracy = (inaccuracy + velocity.length()*MOVEMENT_INACCURACY_MULTIPLIER)
			if move_mode == MoveMode.CROUCH: 
				effective_inaccuracy *= CROUCH_INACCURACY_MULTIPLIER
			
			# Apply random rotation based on inaccuracy (in degrees)
			attack_raycast.rotate_x(deg_to_rad(randf_range(-effective_inaccuracy, effective_inaccuracy)))
			attack_raycast.rotate_y(deg_to_rad(randf_range(-effective_inaccuracy, effective_inaccuracy)))
			
			inaccuracy += inventory_data.get_current_item().subsequent_shot_inaccuracy
			
			attack_raycast.force_raycast_update()
			
			if attack_raycast.is_colliding():
				var target = attack_raycast.get_collider()
				if target:
					#Add bullet hole
					var bullet_hole = preload("res://effects/bullet_decal.tscn").instantiate()
					target.add_child(bullet_hole)
					bullet_hole.global_transform.origin = attack_raycast.get_collision_point()
					bullet_hole.look_at(attack_raycast.get_collision_point() + attack_raycast.get_collision_normal(), Vector3.UP)
					
					if target is RigidBody3D:
						var force_direction = -attack_raycast.get_collision_normal()
						var force_magnitude = item.damage * 34.90
						target.apply_impulse(
							attack_raycast.get_collision_point() - target.global_position,
							force_direction * force_magnitude
						)
					elif target is PhysicalBone3D:
						var force_direction = -attack_raycast.get_collision_normal()
						var force_magnitude = item.damage * 34.90
						target.apply_central_impulse(force_direction * force_magnitude)
						#target.apply_impulse(
							#attack_raycast.get_collision_point() - target.global_transform.origin,
							#force_direction * force_magnitude
						#)



					var crit = false
					if target.is_in_group("crit_hurtbox"):
						crit = true
						print(name, ": CRITIAL HIT")
					else:
						crit = false
					
					var enemy = find_enemy_root(target)
					var multiplier = CRIT_MULTIPLIER if crit else 1.0
					if enemy:
						enemy.change_health(-(item.damage * multiplier))
						if "hit_sound" in enemy and enemy is not Player:
							if crit:
								enemy.play_sound("res://assets/critical-hit-sounds-effect.mp3")
							else:
								enemy.play_sound("res://assets/tf2_hitsound.mp3")
						
							
						
					print(name, ": Hitscan Attacked ", target, " for ", item.damage, " damage")
		
		elif item.shooting_type == ItemData.ShootingType.DELAYED_HITSCAN:
			# Reset rotation to face forward
			attack_raycast.rotation = Vector3.ZERO
			attack_raycast.target_position = Vector3.FORWARD * item.hitscan_range

			# Apply inaccuracy
			inaccuracy += inventory_data.get_current_item().first_shot_inaccuracy
			var effective_inaccuracy = (inaccuracy + velocity.length() * MOVEMENT_INACCURACY_MULTIPLIER)
			if move_mode == MoveMode.CROUCH:
				effective_inaccuracy *= CROUCH_INACCURACY_MULTIPLIER

			attack_raycast.rotate_x(deg_to_rad(randf_range(-effective_inaccuracy, effective_inaccuracy)))
			attack_raycast.rotate_y(deg_to_rad(randf_range(-effective_inaccuracy, effective_inaccuracy)))

			inaccuracy += inventory_data.get_current_item().subsequent_shot_inaccuracy

			# Force raycast to update
			attack_raycast.force_raycast_update()

			# Check what we hit
			var hit_position: Vector3
			if attack_raycast.is_colliding():
				hit_position = attack_raycast.get_collision_point()
			else:
				# No hit, just shoot straight to max range
				hit_position = attack_raycast.global_position + attack_raycast.global_transform.basis.z * item.hitscan_range

			# Spawn bullet
			var bullet_scene: PackedScene = preload("res://entities/test/hitscan_bullet.tscn")
			var bullet = bullet_scene.instantiate() as DelayedHitscanBullet
			get_tree().current_scene.add_child(bullet)

			# Place bullet at muzzle (or raycast origin)
			#bullet.global_position = attack_raycast.global_position

			# Aim bullet toward hit point
			bullet.setup(muzzle_location, hit_position, item.damage)

		elif item.shooting_type == ItemData.ShootingType.PROJECTILE:
			processor.spawn_projectile(item.projectile_path, head)
			
	# Wait between shots (non-blocking)
	await create_local_timer(item.between_shooting_delay)

	can_shoot = true

func play_sound(sound_path: String):
	hit_sound.stream = load(sound_path)
	hit_sound.play()
	

static func find_enemy_root(node)-> Node:
	while node != null:
		#if node.is_in_group("damageable_character"):
		if node.has_method("change_health"):
			print("STATIC FUNC", ": enemy found with change health function")
			
			return node
		node = node.get_parent()
	print("STATIC FUNC", ": enemy NOT found with change health function")
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
