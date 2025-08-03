extends AdvancedCharacter
class_name Player


# Player Specific
enum CameraMode { FIRST_PERSON, THIRD_PERSON }
const ENEMY_STATS_DISTANCE := 15.0 # Distance to see enemy stats

# Player Specific
var elapsed_time := 0.0 
var crouch_toggled := false
var target_spring_length : float = 0.0
var spring_interp_speed: float = 5.0  # Adjust speed as needed
var mouse_sensitivity := 0.003
var camera_mode := CameraMode.FIRST_PERSON

# Player specific
#@onready var face := $Skin/MaxSkin/Max_Shooter/max/Skeleton3D/Head
#@onready var eyelashes := $Skin/MaxSkin/Max_Shooter/max/Skeleton3D/eyelashes
#@onready var eyes := $Skin/MaxSkin/Max_Shooter/max/Skeleton3D/eyes_001
#@onready var hair := $Skin/MaxSkin/Max_Shooter/max/Skeleton3D/hair
@onready var spring := $Head/SpringParent/SpringArm3D
@onready var camera := $Head/SpringParent/SpringArm3D/MarginThing/Camera3D

@onready var head_bone := $Skin/MaxSkin/Human_Ultimate_Current/rig/Skeleton3D/HeadBone/AdjustedHead
@onready var hud := get_parent().get_parent().get_node("PlayerHUD") as PlayerHUD
#@onready var timer := $ShootTimer
# Ready ##########################################################
func _ready() -> void:
	#super()
	#toggle_camera_mode()
	interact_raycast = $Head/SpringParent/SpringArm3D/MarginThing/Camera3D/InteractRayCast3D
	attack_raycast = $Head/SpringParent/SpringArm3D/MarginThing/Camera3D/AttackRayCast3D
	
	character_data = CharacterDataFactory.create_player_character_data()
	inventory_data = InventoryDataFactory.create_player_inventory_data()
	skin.rotation = DEFAULT_SKIN_ROTATION
	update_equipped_item()
	
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
			if speaker and speaker.nicknames[0]:
				CameraManager.auto_camera(speaker.nicknames[0])
	)
	Dialogic.Text.animation_textbox_new_text.connect(	func():
		animation_node.set_random_expression()
	)
	
# Process functions ############################################################
func _process(delta):
	elapsed_time += delta
	# HUD
	if hud:
		hud.update_time(elapsed_time)
		hud.update_health(character_data.health, character_data.max_health)
		hud.update_wealth(character_data.wealth)
		hud.update_display_name(character_data.display_name)
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
		move_and_slide()
		
		
		
		# FACE DIRECTION IF PLAYER IS NOT AIMING BASICALLY
		if camera_mode == CameraMode.THIRD_PERSON and (hold_mode == HoldMode.HOLD or hold_mode == HoldMode.HOLSTER):
			if velocity.length() > 0.1:
				var flat_velocity = velocity
				flat_velocity.y = 0
				var target_dir = flat_velocity.normalized()

				# Get current and target rotations as Quaternions
				var current_rot = skin.global_transform.basis.get_rotation_quaternion()
				var target_basis = Basis.looking_at(-target_dir, Vector3.UP)
				var target_rot = target_basis.get_rotation_quaternion()

				# Interpolate rotation
				var new_rot = current_rot.slerp(target_rot, delta * 8.0)

				# Preserve original scale
				var current_scale = skin.global_transform.basis.get_scale()
				var new_basis = Basis(new_rot)
				new_basis = Basis(
					new_basis.x * current_scale.x,
					new_basis.y * current_scale.y,
					new_basis.z * current_scale.z
				)
				# Apply new transform
				skin.global_transform = Transform3D(new_basis, skin.global_transform.origin)
		else:
			skin.rotation = DEFAULT_SKIN_ROTATION
	else:
		velocity = Vector3.ZERO
		velocity.y = y_velocity
		move_and_slide()	
		


# Controls #####################################################################
func _unhandled_input(event):
	# Looking Around
	if event is InputEventMouseMotion:
		# Rotate the body (yaw)
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Rotate the head (pitch), but track and clamp it manually
		var new_pitch = head.rotation_degrees.x - event.relative.y * mouse_sensitivity * 180.0 / PI
		new_pitch = clamp(new_pitch, -80, 80)  # Limit vertical look angle to ±80°
		head.rotation_degrees.x = new_pitch

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
				
	if event.is_action_pressed("primary_fire"):
		perform_primary_fire()
	if event.is_action_pressed("secondary_fire"):
		perform_secondary_fire()
	if event.is_action_pressed("reload"):
		perform_reload()
	if event.is_action_pressed("inspect"):
		perform_inspect()
	#else:
		#hold_mode = HoldMode.AIM
	if event.is_action_pressed("toggle_camera"):
		toggle_camera_mode()
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
		interact_target = null
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
