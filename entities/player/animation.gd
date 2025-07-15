extends Node3D

@export var player: Player
@onready var animation_tree: AnimationTree = $"../AnimationTree"
@onready var target := $"../Target"
#enum player.MoveMode { WALK, SPRINT, CROUCH }

@export var blend_lerp_speed: float = 6

var smoothed_velocity: Vector2 = Vector2.ZERO
var smoothed_jump_blend: float = 0.0
var smoothed_iwr_blend: float = 0.0

# AnimationTree parameter paths
const AG_TRANSITION_REQUEST = "parameters/ag_transition/transition_request"
const AG_WEAPON_TRANSITION_REQUEST = "parameters/air_ground_weapon/transition_request"
const AIM_TRANSITION_REQUEST = "parameters/aim_transition/transition_request"
const CS_TRANSITION_REQUEST = "parameters/cs_transition/transition_request"

const CROUCH_IW_BLEND = "parameters/crouch_iw_blend/blend_amount"
const CROUCH_WALK_BLENDSPACE = "parameters/crouch/blend_position"
const WALK_BLENDSPACE = "parameters/walk/blend_position"

const IR_RIFLE_BLEND = "parameters/ir_rifle_blend/blend_amount"
const IWR_BLEND = "parameters/iwr_blend/blend_amount"
const JUMP_BLEND = "parameters/jump_blend/blend_position"
const WEAPON_BLEND = "parameters/weapon_blend/blend_amount"

const STRAIGHT_NECK = "parameters/straight_neck/blend_amount"

const PISTOL_RIFLE_AIMING = "parameters/pistol_rifle_aiming/transition_request"
const PISTOL_RIFLE_IDLE = "parameters/pistol_rifle_idle/transition_request"
const PISTOL_RIFLE_RUN = "parameters/pistol_rifle_run/transition_request"
const PISTOL_RIFLE_AIR = "parameters/pistol_rifle_air/transition_request"

const RELOAD = "parameters/reload/request"
const SWITCH_WEAPON = "parameters/switch_weapon/request"
const SWITCH_WEAPON_BLEND = "parameters/switch_weapon_blend/blend_position"

const SHOOT = "parameters/shoot/request"
var smoothed_camera_direction: Vector3

var is_using_pistol: bool

func _ready() -> void:
	animation_tree.active = true
	$"../Max_Shooter/max/Skeleton3D/SpineIK".start()




func _physics_process(delta: float) -> void:
	if player == null:
		return

	# === Determine logical state ===
	var is_on_floor = player.is_on_floor()
	var is_sprinting = player.move_mode == player.MoveMode.SPRINT
	var is_crouching = player.move_mode == player.MoveMode.CROUCH
	var has_weapon = (player.inventory_data.item_mode == InventoryData.ItemMode.ACTIVE or player.inventory_data.item_mode == InventoryData.ItemMode.HOLSTER)
	var is_aiming = player.is_aiming
	#is_using_pistol = true
	##(
		##player.inventory_data.get_current_item() and 
		##player.inventory_data.get_current_item().display_name == "Shit Pistol"
	##)

	# === Smooth velocity ===
	var local_velocity = global_transform.basis.inverse() * player.velocity
	var velocity_2d = Vector2(-local_velocity.x, -local_velocity.z)
	smoothed_velocity = smoothed_velocity.lerp(velocity_2d, blend_lerp_speed * delta)

	# === Blend values (first!) ===
	# Walk (standing movement)
	animation_tree.set(WALK_BLENDSPACE, smoothed_velocity)

	# Crouch walk blend
	if is_crouching:
		var crouch_speed_blend = clamp(smoothed_velocity.normalized().length(), 0.0, 1.0)
		animation_tree.set(CROUCH_IW_BLEND, crouch_speed_blend)
		animation_tree.set(CROUCH_WALK_BLENDSPACE, smoothed_velocity)

	# In-walk-run blend
	var target_iwr := -1.0 if is_crouching else (1.0 if is_sprinting else 0.0)
	smoothed_iwr_blend = lerp(smoothed_iwr_blend, target_iwr, blend_lerp_speed * delta)
	animation_tree.set(IWR_BLEND, smoothed_iwr_blend)

	# Jump blend
	var target_jump = clamp(player.y_velocity / 10.0, -1.0, 1.0)
	smoothed_jump_blend = lerp(smoothed_jump_blend, target_jump, blend_lerp_speed * delta)
	animation_tree.set(JUMP_BLEND, smoothed_jump_blend)

	# Weapon blend
	animation_tree.set(WEAPON_BLEND, 1.0 if has_weapon else 0.0)

	# Sprinting weapon blend
	animation_tree.set(IR_RIFLE_BLEND, 1.0 if is_sprinting else 0.0)
	
	# Straight neck
	var target_straight_neck = 1.0 if (is_aiming and is_crouching) else 0.0
	var current_straight_neck = float(animation_tree.get(STRAIGHT_NECK))
	var smoothed_straight_neck = lerp(current_straight_neck, target_straight_neck, blend_lerp_speed * delta)
	animation_tree.set(STRAIGHT_NECK, smoothed_straight_neck)

	# === Spine IK (based on aim) ===
	if is_aiming:
		$"../Max_Shooter/max/Skeleton3D/SpineIK".start()
	else:
		$"../Max_Shooter/max/Skeleton3D/SpineIK".stop()

	# === Pistol/Rifle sub-transitions ===
	var weapon_type = "using_pistol" if is_using_pistol else "using_rifle"
	animation_tree.set(PISTOL_RIFLE_AIMING, weapon_type)
	animation_tree.set(PISTOL_RIFLE_IDLE, weapon_type)

	if is_on_floor:
		animation_tree.set(PISTOL_RIFLE_RUN, weapon_type)
	else:
		animation_tree.set(PISTOL_RIFLE_AIR, weapon_type)

	# === Transition requests (last!) ===
	animation_tree.set(AG_TRANSITION_REQUEST, "on_ground" if is_on_floor else "on_air")
	animation_tree.set(AG_WEAPON_TRANSITION_REQUEST, "on_ground" if is_on_floor else "on_air")
	animation_tree.set(CS_TRANSITION_REQUEST, "crouching" if is_crouching else "standing")
	animation_tree.set(AIM_TRANSITION_REQUEST, "aiming" if is_aiming else "not_aiming")

	# === Camera control ===
	var camera = player.get_node("Head/SpringParent/SpringArm3D/MarginThing/Camera3D")
	var target_camera_direction = target.global_transform.origin + camera.global_transform.basis.z * 1000
	smoothed_camera_direction = lerp(smoothed_camera_direction, target_camera_direction, blend_lerp_speed * delta)
	smoothed_camera_direction.x = target_camera_direction.x
	target.look_at(smoothed_camera_direction, Vector3.UP)
	
func reload():
	animation_tree.set(RELOAD, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func switch(position: float):
	is_using_pistol = true if position == -1 else false
	
	var weapon_type = "using_pistol" if is_using_pistol else "using_rifle"
	animation_tree.set(PISTOL_RIFLE_AIMING, weapon_type)
	animation_tree.set(PISTOL_RIFLE_IDLE, weapon_type)

	if player.is_on_floor():
		animation_tree.set(PISTOL_RIFLE_RUN, weapon_type)
	else:
		animation_tree.set(PISTOL_RIFLE_AIR, weapon_type)	
	
	
	
	print("Switch requested: ", position)
	animation_tree.set(SWITCH_WEAPON_BLEND, position)
	animation_tree.set(SWITCH_WEAPON, 0)
	await get_tree().process_frame
	print("Firing one-shot")
	animation_tree.set(SWITCH_WEAPON, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func shoot():
	
	print("shoot requested: ", position)
	await get_tree().process_frame
	print("Firing one-shot")
	animation_tree.set(SHOOT, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
