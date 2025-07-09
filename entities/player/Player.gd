extends CharacterBody3D
class_name Player

# Constants
enum CameraMode { FIRST_PERSON, THIRD_PERSON }
enum MoveMode {WALK, SPRINT, CROUCH}
const INTERACT_DISTANCE := 2.0 # Interact Distance for interactable props
const DEFAULT_SKIN_ROTATION := Vector3(0, PI, 0)
const SNAP_FIRST_PERSON_DISTANCE := 2
const SPRING_EXTENDED_LENGTH := 2.3

const SPRINT_FACTOR := 3
const CROUCH_FACTOR := 0.1


var target_spring_length : float = 0.0
var spring_interp_speed: float = 5.0  # Adjust speed as needed

# Misc vars
var interact_target: Node = null
var y_velocity := 0.0

# Default values
@export var speed := 5.0
@export var mouse_sensitivity := 0.003
@export var gravity := 9.8
@export var jump_force := 5.0
@export var can_move := true

@export var camera_mode := CameraMode.FIRST_PERSON
@export var move_mode := MoveMode.WALK
@export var health := 100
@export var max_health := 100
@export var display_name := "Main Character"
var wealth := 0
var inventory_data: InventoryData = InventoryData.new()
var elapsed_time := 0.0

######################################################
@onready var spring := $Head/SpringParent/SpringArm3D
@onready var skin := $Skin/MaxSkin
@onready var animation_tree := $Skin/MaxSkin/AnimationTree
@onready var camera := $Head/SpringParent/SpringArm3D/MarginThing/Camera3D

@onready var face := $Skin/MaxSkin/max/Armature/Skeleton3D/CH_S_Max01_02
@onready var eyelashes := $Skin/MaxSkin/max/Armature/Skeleton3D/CH_S_Max01_03
@onready var eyes := $Skin/MaxSkin/max/Armature/Skeleton3D/CH_S_Max01_04

@onready var head := $Head
@onready var head_bone := $Skin/MaxSkin/max/Armature/Skeleton3D/Head/AdjustedHead

@onready var raycast := $Head/SpringParent/SpringArm3D/MarginThing/Camera3D/RayCast3D
@onready var hud := get_parent().get_node("PlayerHUD") as PlayerHUD
@onready var equipped_item = get_node("Skin/MaxSkin/max/Armature/Skeleton3D/RightHand/EquippedItem")  # Update path as needed



# Ready empty for now ##########################################################
func _ready() -> void:
	pass
	#toggle_camera_mode()

# Process functions ############################################################
func _process(delta):
	elapsed_time += delta
	
	# HUD
	if hud:
		hud.update_time(elapsed_time)
		hud.update_health(health, max_health)
		hud.update_wealth(wealth)
		hud.update_display_name(display_name)
		hud.update_inventory_data(inventory_data)
		
	# Interactions
	check_for_interactable()
	
	# Camera
	update_spring_length(delta)
	if (camera_mode == CameraMode.THIRD_PERSON
		and is_equal_approx(spring.spring_length, SPRING_EXTENDED_LENGTH) 
		#and (camera.global_position - head.global_position).length() <= SNAP_FIRST_PERSON_DISTANCE):
		and (spring.get_hit_length() <= SNAP_FIRST_PERSON_DISTANCE)):
		snap_to_first()
	if camera_mode == CameraMode.FIRST_PERSON:
		camera.global_position = head_bone.global_position
	set_face_visibility(camera_mode == CameraMode.THIRD_PERSON)
	
func _physics_process(delta):
	# Basic gravity
	if not is_on_floor():
		y_velocity -= gravity * delta
	else:
		y_velocity = 0
		if Input.is_action_just_pressed("jump"):
			y_velocity = jump_force
			animation_tree.set("parameters/jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	if can_move:
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
		else:
			move_mode = MoveMode.WALK
	
		
		
		
		input_dir = input_dir.normalized()
		var direction = (transform.basis * input_dir).normalized()
		
		var factor = (SPRINT_FACTOR if move_mode == MoveMode.SPRINT else (CROUCH_FACTOR if move_mode == MoveMode.CROUCH else 1))
		velocity = direction * speed * factor
		velocity.y = y_velocity
		move_and_slide()
		
		if camera_mode == CameraMode.THIRD_PERSON and inventory_data.current_index == -1:
			if velocity.length() > 0.1:
				var flat_velocity = velocity
				flat_velocity.y = 0
				var target_dir = flat_velocity.normalized()

				# Get current and target rotations as Quaternions
				var current_rot = skin.global_transform.basis.get_rotation_quaternion()
				var target_basis = Basis().looking_at(-target_dir, Vector3.UP)
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
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -90, 90)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			update_inventory_selection(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			update_inventory_selection(1)
			
	if event.is_action_pressed("interact") and interact_target:
		if interact_target.has_method("interact"):
			interact_target.interact(self)
	
	if event.is_action_pressed("primary_fire"):
		perform_primary_fire()
	if event.is_action_pressed("toggle_camera"):
		toggle_camera_mode()
		
	
	if event.is_action_pressed("holster"):
		holster()


func set_face_visibility(visibility : bool):
	face.visible = visibility
	eyelashes.visible = visibility
	eyes.visible = visibility


	

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
	# This is so that in 3rd person we have more reach
	raycast.target_position = Vector3.FORWARD * (INTERACT_DISTANCE + SPRING_EXTENDED_LENGTH)
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target and target.has_method("interact"):
			interact_target = target

			if target.has_method("get_display_name"):
				hud.show_interactable_name(target.get_display_name())
			elif "display_name" in target:
				hud.show_interactable_name(target.display_name)
			else:
				hud.show_interactable_name(target.name)

			return

	# If nothing valid hit
	interact_target = null
	hud.hide_interactable_ui()

# Save functions ###################################################################################
func get_save_data() -> PlayerData:
	var data = PlayerData.new()
	# Physical Stats
	data.position = global_transform.origin
	data.velocity = velocity # Note this is different from SPEED, which is movement speed.
	data.body_rotation_y = rotation.y
	data.head_rotation_x = $Head.rotation.x
	
	data.speed = speed
	data.mouse_sensitivity = mouse_sensitivity
	data.gravity = gravity
	data.jump_force = jump_force
	data.can_move = can_move
	data.move_mode = move_mode
	
	# Gameplay stats
	data.health = health
	data.wealth = wealth
	data.display_name = display_name
	data.inventory_data = inventory_data
	data.camera_mode = camera_mode
	
	# Misc stats
	data.time_elapsed = elapsed_time
	return data

func apply_save_data(data: PlayerData):
	# Physical Stats
	global_transform.origin = data.position
	velocity = data.velocity
	rotation.y = data.body_rotation_y
	$Head.rotation.x = data.head_rotation_x
	
	speed = data.speed
	mouse_sensitivity = data.mouse_sensitivity
	gravity = data.gravity
	jump_force = data.jump_force
	can_move = data.can_move
	move_mode = data.move_mode
	
	# Gameplay stats
	health = data.health
	wealth = data.wealth
	display_name = data.display_name
	inventory_data = data.inventory_data
	camera_mode = data.camera_mode
	set_face_visibility(camera_mode == CameraMode.THIRD_PERSON)
	update_equipped_item()
	if camera_mode == CameraMode.THIRD_PERSON: 
		target_spring_length = SPRING_EXTENDED_LENGTH
	# Misc stats
	elapsed_time = data.time_elapsed

# Gameplay Functions ###############################################################################
func change_health(amount: int):
	if health < 0:
		print("health unchanged, player is already dead")
	elif health + amount > max_health:
		print("health unchanged, max health already reached")
	else:
		health += amount
		var status = "healed" if (amount >= 0) else "damaged"
		print("Player " + status + " by " + str(abs(amount)) + " HP.")
		if health + amount < 0:
			health = 0
			print("player is now dead")
		elif health + amount > max_health:
			health = max_health
			print("max health reached")

func change_wealth(amount: int):
	if wealth + amount < 0:
		print("wealth unchanged, player would be broke")
	else:
		wealth += amount
		var status = "enriched" if (amount >= 0) else "impoverished"
		print("Player " + status + " by " + str(abs(amount)) + " dollars.")
		if wealth + amount < 0:
			print("player is broke")

	#var hud = get_parent().get_node("PlayerHUD") as PlayerHUD
	if hud:
		hud.update_wealth(wealth)

# Checks for object in range of current item, then shoots if in range
func perform_primary_fire():
	if inventory_data.current_index < 0 or inventory_data.current_index >= inventory_data.items.size():
		print("No item equipped")
		return

	var item = inventory_data.items[inventory_data.current_index]
	if item.uses_ammo:
		print("Not implemented: item requires ammo")
		return

	# Use item's range for raycasting
	raycast.target_position = Vector3.FORWARD * item.range
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target and target.has_method("change_health"):
			target.change_health(-item.damage)
			print("Attacked ", target, " for ", item.damage, " damage")

# This allows for the changing of the selected item via direction. 
# NOT BASED ON INVENTORY SLOT NUMBER
func update_inventory_selection(direction: int):
	var item_count = inventory_data.items.size()
	if item_count == 0:
		inventory_data.current_index = -1
	else:
		inventory_data.current_index += direction
		inventory_data.current_index = clamp(inventory_data.current_index, 0, item_count - 1)

	if hud:
		hud.update_inventory_data(inventory_data)

	update_equipped_item()  # Refresh equipped mesh

# This updates the item that the player has equipped
func update_equipped_item():
	if inventory_data.current_index >= 0 and inventory_data.current_index < inventory_data.items.size():
		var item = inventory_data.items[inventory_data.current_index]
		equipped_item.equip_item(item)
		print("equipped" + item.display_name)
	else:
		equipped_item.equip_item(null)
		print("unequipped any item")

func holster():
	equipped_item.equip_item(null)
	inventory_data.current_index = -1
	print("unequipped any item")
	
####################################################################################################
