extends AdvancedCharacter
class_name Player

var bullet_time := false

# Player Specific
enum CameraMode { FIRST_PERSON, THIRD_PERSON }
var camera_mode := CameraMode.FIRST_PERSON
const ENEMY_STATS_DISTANCE := 15.0 # Distance to see enemy stats
var elapsed_time := 0.0 
var crouch_toggled := false
var target_spring_length : float = 0.0
var spring_interp_speed: float = 5.0  # Adjust speed as needed
var mouse_sensitivity := 0.003

#var head_yaw: float = 0.0
# Tracks if the player has fired a round. Relevant for Semi-Auto. 
# Only matters to player and not other charactrs as this is merely an input based thing. 
var has_fired_semi :bool = false 

@onready var spring_parent := $ViewPivot/SpringParent
@onready var view_pivot := $ViewPivot

@onready var spring := $ViewPivot/SpringParent/SpringArm3D
@onready var camera := $ViewPivot/SpringParent/SpringArm3D/MarginThing/Camera3D

@onready var head_bone := $Skin/MaxSkin/Human2026/Armature/Skeleton3D/HeadBone/AdjustedHead
@onready var aim_raycast := $ViewPivot/SpringParent/SpringArm3D/MarginThing/Camera3D/AimRayCast3D
@onready var hud := get_parent().get_parent().get_node("PlayerHUD") as PlayerHUD
#@onready var timer := $ShootTimer
# Ready ##########################################################
func _ready() -> void:
	super()

#OVERRIDE
func setup_uninitialized_variables():
	character_data = CharacterDataFactory.create_player_character_data()
	inventory_data = InventoryDataFactory.create_player_inventory_data()
	dialogic_name = "You"
	display_name = dialogic_name

# Process functions ############################################################
func _process(delta):
	super(delta)
	elapsed_time += delta
	
	if inventory_data.get_current_item():
		match inventory_data.get_current_item().shooting_mode:
			ItemData.ShootingMode.AUTO:
				if Input.is_action_pressed("primary_fire"):
					perform_primary_fire()
			ItemData.ShootingMode.SEMI_AUTO, ItemData.ShootingMode.NON_AUTO:
				if Input.is_action_pressed("primary_fire") and not has_fired_semi:
					perform_primary_fire()
					has_fired_semi = true
				elif not Input.is_action_pressed("primary_fire"):
					has_fired_semi = false
	
	# HUD
	if hud:
		#hud.update_time(elapsed_time)
		#hud.update_health(character_data.health, character_data.max_health)
		#hud.update_wealth(character_data.wealth)
		#hud.update_display_name(character_data.display_name)
		hud.update_player_stats(character_data.display_name)
		hud.update_inventory_data(inventory_data)
		hud.update_ammo_label(inventory_data)

	# Interactions
	check_for_interactable()
	check_for_enemy() #updates HUD
	
	# Camera
	update_spring_length(delta)
	if (camera_mode == CameraMode.THIRD_PERSON
		and is_equal_approx(spring.spring_length, SPRING_EXTENDED_LENGTH) 
		#and (camera.global_position - head.global_position).length() <= SNAP_FIRST_PERSON_DISTANCE):
		and (spring.get_hit_length() <= SNAP_FIRST_PERSON_DISTANCE)):
		snap_to_first()
	if camera_mode == CameraMode.FIRST_PERSON:
		camera.global_position = head_bone.global_position
	set_face_visibility(camera_mode == CameraMode.THIRD_PERSON or processor.in_dialogue)

func _physics_process(delta):
	if not is_on_floor():
		y_velocity -= GRAVITY * delta
	else:
		y_velocity = 0
		if Input.is_action_just_pressed("jump"):
			y_velocity = character_data.jump_force
	if character_data.can_move:
		var input_dir = Vector3.ZERO
		if Input.is_action_pressed("move_forward"):
			input_dir.z -= 1
		if Input.is_action_pressed("move_back"):
			input_dir.z += 1
		if Input.is_action_pressed("move_left"):
			input_dir.x -= 1
		if Input.is_action_pressed("move_right"):
			input_dir.x += 1
		if Input.is_action_pressed("crouch"):
			move_mode = MoveMode.CROUCH
		elif Input.is_action_pressed("sprint"):
			move_mode = MoveMode.SPRINT
			#is_aiming = false # OVERRIDES!!
		else:
			move_mode = MoveMode.WALK

		#if inventory_data.item_mode == InventoryData.ItemMode.ACTIVE and not inventory_data.items.is_empty():
			#is_aiming = true
		
		input_dir = input_dir.normalized()
		var direction = (transform.basis * input_dir).normalized()
		
		velocity = direction * get_effective_speed()
		velocity.y = y_velocity
		
		if bullet_time:
			if velocity == Vector3.ZERO:
				Engine.time_scale = 0.01
			else:
				Engine.time_scale = 1.0
		else:
			Engine.time_scale = 1.0
		move_and_slide()
		
		# FACE DIRECTION IF PLAYER IS NOT AIMING BASICALLY
		#if camera_mode == CameraMode.THIRD_PERSON and (hold_mode == HoldMode.HOLD or hold_mode == HoldMode.HOLSTER):
			#if velocity.length() > 0.1:
				#var flat_velocity = velocity
				#flat_velocity.y = 0
				#var target_dir = flat_velocity.normalized()
#
				## Get current and target rotations as Quaternions
				#var current_rot = skin.global_transform.basis.get_rotation_quaternion()
				#var target_basis = Basis.looking_at(-target_dir, Vector3.UP)
				#var target_rot = target_basis.get_rotation_quaternion()
#
				## Interpolate rotation
				#var new_rot = current_rot.slerp(target_rot, delta * 8.0)
#
				## Preserve original scale
				#var current_scale = skin.global_transform.basis.get_scale()
				#var new_basis = Basis(new_rot)
				#new_basis = Basis(
					#new_basis.x * current_scale.x,
					#new_basis.y * current_scale.y,
					#new_basis.z * current_scale.z
				#)
				## Apply new transform
				#skin.global_transform = Transform3D(new_basis, skin.global_transform.origin)
		#else:
			#skin.rotation = DEFAULT_SKIN_ROTATION
	else:
		velocity = Vector3.ZERO
		velocity.y = y_velocity
		move_and_slide()	

# Controls #####################################################################
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Step 1: update aim ray direction from mouse intent
		view_pivot.rotation.y -= event.relative.x * mouse_sensitivity
		self.rotation.y -= event.relative.x * mouse_sensitivity
		
		var new_pitch: float = view_pivot.rotation.x - event.relative.y * mouse_sensitivity
		view_pivot.rotation.x = clamp(new_pitch, deg_to_rad(-80), deg_to_rad(80))
		
		# Step 2: force raycast update
		aim_raycast.force_raycast_update()
		
		var aim_position := Vector3.ZERO
		# Step 3: resolve aim position
		if aim_raycast.is_colliding():
			aim_position = aim_raycast.get_collision_point()
		else:
			# 1000 meters straight ahead of the ray
			var origin: Vector3 = aim_raycast.global_transform.origin
			var direction: Vector3 = -aim_raycast.global_transform.basis.z
			aim_position = origin + direction * 1000.0
			
		aim_at(aim_position)
		
	# Scrolling
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			if inventory_data.change_current_index(-1): 
				#inventory_data.item_mode = InventoryData.ItemMode.ACTIVE
				#is_aiming = true
				hold_mode = HoldMode.AIM
				update_equipped_item()
				
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if inventory_data.change_current_index(1): 
				#inventory_data.item_mode = InventoryData.ItemMode.ACTIVE
				#is_aiming = true
				hold_mode = HoldMode.AIM
				update_equipped_item()
				
	if event.is_action_pressed("interact") and interact_target:
		if interact_target.has_method("interact"):
			interact_target.interact(self)
	if (event.is_action_pressed("trade") and interact_target
	and interact_target.has_method("trade") 	and interact_target.tradeable):
		if processor.trade_menu.visible:
			processor.hide_trade()
		else:
			if interact_target.has_method("trade"):
				interact_target.trade(self)
				
	#if event.is_action_pressed("primary_fire"):
		#perform_primary_fire()
	#if event.is_action_pressed("secondary_fire"):
		#perform_secondary_fire()
	if event.is_action_pressed("reload"):
		perform_reload()
	if event.is_action_pressed("inspect"):
		perform_inspect()
	#else:
		#hold_mode = HoldMode.AIM
	if event.is_action_pressed("toggle_camera"):
		toggle_camera_mode()
	if event.is_action_pressed("bullet_time"):
		toggle_bullet_time()
	if event.is_action_pressed("holster"):
		holster()
	if event.is_action_pressed("drop"):
		drop_current_item()
	#if event.is_action_pressed("crouch"):
		#if move_mode != MoveMode.CROUCH:
			#if Input.is_action_pressed("sprint"):
				#move_mode = MoveMode.SPRINT
			#elif Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_back"):
				#move_mode = MoveMode.WALK
				#

func set_face_visibility(visibility : bool):
	pass
	#face.visible = visibility
	#eyelashes.visible = visibility
	#eyes.visible = visibility
	#hair.visible = visibility

func toggle_bullet_time():
	bullet_time = !bullet_time 

func toggle_camera_mode():
	camera_mode = CameraMode.THIRD_PERSON if camera_mode == CameraMode.FIRST_PERSON else CameraMode.FIRST_PERSON
	# Set the target spring length based on the new mode
	if camera_mode == CameraMode.FIRST_PERSON:
		target_spring_length = 0.0  # Fully pulled in
	else:
		target_spring_length = SPRING_EXTENDED_LENGTH  # Or whatever your 3rd person offset is

# INSTANT snap to first person, not using lerp.
func snap_to_first():
	camera_mode = CameraMode.FIRST_PERSON
	target_spring_length = 0.0
	spring.spring_length = 0.0

func update_spring_length(delta):
	spring.spring_length = lerp(spring.spring_length, target_spring_length, spring_interp_speed * delta)

# Checks for interactible inside of a range 
func check_for_interactable():
	
	var target = _get_interact_target()
	
	if target is PhysicalBone3D:
		target = find_interactable_parent(target)
	
	
	
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
			hud.show_interactable_name(target_name, verb)		
	else:
		hud.hide_interactable_ui()
		
		
		
		
	if target and target.has_method("trade"):
		trade_target = target
		hud.show_tradeable_prompt()
		
	else:
		trade_target = null
		hud.hide_tradeable_ui()
	
func check_for_enemy():
	interact_raycast.target_position = Vector3.FORWARD * (ENEMY_STATS_DISTANCE + SPRING_EXTENDED_LENGTH)
	interact_raycast.force_raycast_update()

	if interact_raycast.is_colliding():
		var target = interact_raycast.get_collider()
		#TODO
		if target and target is SaveableCharacterBody3D:
			hud.show_enemy_stats(target)
			return

	# If nothing valid hit
	hud.hide_enemy_stats()
	

# Gameplay Functions ###############################################################################
func change_health(amount: int):
	character_data.change_health(amount)
	if character_data.health <= 0: die()

func die():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://interface/death_screen/death_screen.tscn")

func change_wealth(amount: int):
	super(amount)
	if hud:
		hud.update_wealth(character_data.wealth)

func check_for_raycast_collision() -> bool:
	return true

func drop_current_item():
	if inventory_data.current_index >= 0:
		processor.spawn_pickup_near_character(inventory_data.remove_current_item(), self)
		update_equipped_item()
		

####################################################################################################
# Save functions ###################################################################################
func get_save_data() -> Dictionary:
	var data = super()
	# Player Specific
	data["scene_path"] = "res://entities/saveable_character_bodies/advanced_character_bodies/player/Player.tscn"
	data["mouse_sensitivity"] = mouse_sensitivity
	data["camera_mode"] = camera_mode
	data["time_elapsed"] = elapsed_time
	return data

#TODO: Fix to use composition
func apply_save_data(data: Dictionary):
	super(data)
	# Player Specific
	if data.has("mouse_sensitivity"):
		mouse_sensitivity = data["mouse_sensitivity"]
	if data.has("camera_mode"):
		camera_mode = data["camera_mode"]
	if data.has("time_elapsed"):
		elapsed_time = data["time_elapsed"]
	
	# Set up rest based on the data
	set_face_visibility(camera_mode == CameraMode.THIRD_PERSON)
	update_equipped_item()
	
	if camera_mode == CameraMode.THIRD_PERSON: 
		target_spring_length = SPRING_EXTENDED_LENGTH
