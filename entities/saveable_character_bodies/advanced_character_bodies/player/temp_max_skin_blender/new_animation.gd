extends Node3D
@export var player: AdvancedCharacter
@export var blend_lerp_speed: float = 3

@onready var animation_tree: AnimationTree = $"../NewAnimationTree"
@onready var equipped_item :EquippedItem= $"../Human_Ultimate_Lipsync/rig/Skeleton3D/HandBone/EquippedItem"
@onready var target := $"../Target"
@onready var ik := $"../Human_Ultimate_Lipsync/rig/Skeleton3D/SkeletonIK3D"

var smoothed_head_direction: Vector3
var head : Node3D

var smoothed_velocity: Vector2 = Vector2.ZERO
var smoothed_crouch_walk_sprint :float= 0
var smoothed_hold_aim_scope :float = 0
var smoothed_jump_blend: float = 0.0
var smoothed_upper_body_blend: float = 0.0

const CROUCH_BLEND_SPACE := "parameters/crouch_blend_space/blend_position"
const WALK_BLEND_SPACE := "parameters/walk_blend_space/blend_position"
const SPRINT_BLEND_SPACE := "parameters/sprint_blend_space/blend_position"

const CROUCH_WALK_SPRINT_BLEND := "parameters/crouch_walk_sprint_blend/blend_amount"
const HOLD_AIM_SCOPE_BLEND := "parameters/hold_aim_scope_blend/blend_amount"
const UPPER_BODY_BLEND := "parameters/upper_body_blend/blend_amount"
const JUMP_BLEND := "parameters/jump_blend/blend_amount"


const SHOOT_REQUEST := "parameters/shoot_oneshot/request"
const RELOAD_REQUEST := "parameters/reload_oneshot/request"
const INSPECT_REQUEST := "parameters/inspect_oneshot/request"
const PULLOUT_REQUEST := "parameters/pullout_oneshot/request"
const SWITCH_REQUEST := "parameters/switch_oneshot/request"
const LIPSYNC_REQUEST := "parameters/lipsync_blend_tree/lipsync_transition/transition_request"
const EXPRESSION_REQUEST := "parameters/expression_blend_tree/expression_transition/transition_request"
const AIM_SCOPE_SHOOT_TRANSITION_REQUEST := "parameters/aim_scope_shoot_transition/transition_request"

func get_equipped_item_child():
	return equipped_item.get_child(0) if equipped_item.get_child_count() > 0 else null

func equip_item(item_data: ItemData):
	equipped_item.equip_item(item_data)
	update_animation_inputs(item_data)
	
func randomize_character():
	var mesh_instance: MeshInstance3D = $"../Human_Ultimate_Lipsync/rig/Skeleton3D/ultimate_human_mesh"
	var mesh: Mesh = mesh_instance.mesh

	if not mesh:
		print("No mesh assigned!")
		return

	# Randomize blend shapes
	var blend_shape_count = mesh.get_blend_shape_count()
	for i in blend_shape_count:
		var name = mesh.get_blend_shape_name(i)
		var path = "blend_shapes/" + name

		if name == "Sex":
			mesh_instance.set(path, randi() % 2) # 0 or 1
		else:
			mesh_instance.set(path, randf_range(-1.0, 1.0)) # -1 to 1

	# Randomize material colors per instance
	for surface_index in mesh_instance.get_surface_override_material_count():
		var base_material := mesh.surface_get_material(surface_index)
		if base_material and base_material is StandardMaterial3D:
			var new_material := base_material.duplicate()
			new_material.albedo_color = Color(randf(), randf(), randf())
			mesh_instance.set_surface_override_material(surface_index, new_material)


	
	
	
func _ready():
	animation_tree.tree_root = animation_tree.tree_root.duplicate(true)

	animation_tree.active = true
	
	head = player.get_node_or_null("Head")
	if not head:
		head = player.get_node("Head/SpringParent/SpringArm3D/MarginThing/Camera3D")
		if not head:
			print(name, ": Could not find character's head. Thus cannot use IK. Big issue")
	ik.start()
	
	var target_direction = (head.global_transform.origin + head.global_transform.basis.z * 1000) - target.global_transform.origin
	target.global_transform.basis = Basis().looking_at(target_direction.normalized(), Vector3.UP)

	
func _physics_process(delta: float) -> void:
	var is_on_floor = player.is_on_floor()
	var is_sprinting = player.move_mode == player.MoveMode.SPRINT
	var is_crouching = player.move_mode == player.MoveMode.CROUCH
	
	var local_velocity = global_transform.basis.inverse() * player.velocity
	var velocity_2d = Vector2(-local_velocity.x, -local_velocity.z)
	smoothed_velocity = smoothed_velocity.lerp(velocity_2d, blend_lerp_speed * delta)

	# === Blend values (first!) ===
	var crouch_walk_sprint :float= 0.0
	if player.move_mode == AdvancedCharacter.MoveMode.CROUCH:
		crouch_walk_sprint = -1
	elif player.move_mode == AdvancedCharacter.MoveMode.WALK:
		crouch_walk_sprint = 0
	elif player.move_mode == AdvancedCharacter.MoveMode.SPRINT:
		crouch_walk_sprint = 1
	
	
	smoothed_crouch_walk_sprint = lerp(smoothed_crouch_walk_sprint, crouch_walk_sprint, blend_lerp_speed * delta)
	
	animation_tree.set(CROUCH_WALK_SPRINT_BLEND, smoothed_crouch_walk_sprint)
	
	animation_tree.set(CROUCH_BLEND_SPACE, smoothed_velocity)
	animation_tree.set(WALK_BLEND_SPACE, smoothed_velocity)
	animation_tree.set(SPRINT_BLEND_SPACE, smoothed_velocity)
	
	var hold_aim_scope :float= 1.0
	var aim_scope_shoot_transition :String = "is_aiming"
	var upper_body_blend_target :float= 1.0
	if player.hold_mode == AdvancedCharacter.HoldMode.HOLSTER:
		hold_aim_scope = -1
		upper_body_blend_target = 0
		ik.stop()
	elif player.hold_mode == AdvancedCharacter.HoldMode.HOLD:
		hold_aim_scope = -1
		upper_body_blend_target = 1
		ik.stop()
	elif player.hold_mode == AdvancedCharacter.HoldMode.AIM:
		hold_aim_scope = 0
		upper_body_blend_target = 1
		aim_scope_shoot_transition = "is_aiming"
		ik.start()
	elif player.hold_mode == AdvancedCharacter.HoldMode.SCOPE:
		hold_aim_scope = 1
		upper_body_blend_target = 1
		aim_scope_shoot_transition = "is_scoping"
		ik.start()
		
	
	smoothed_hold_aim_scope = lerp(smoothed_hold_aim_scope, hold_aim_scope, blend_lerp_speed * delta)
	animation_tree.set(HOLD_AIM_SCOPE_BLEND, smoothed_hold_aim_scope)
	
	smoothed_upper_body_blend = lerp(smoothed_upper_body_blend, upper_body_blend_target, blend_lerp_speed * delta)
	animation_tree.set(UPPER_BODY_BLEND, smoothed_upper_body_blend)
	
	animation_tree.set(AIM_SCOPE_SHOOT_TRANSITION_REQUEST, aim_scope_shoot_transition)
	
	animation_tree.set(JUMP_BLEND, 0 if is_on_floor else 1)
	

	# === Camera control ===
	var target_direction = (head.global_transform.origin + head.global_transform.basis.z * 1000) - target.global_transform.origin
	var current_basis = target.global_transform.basis
	var target_basis = Basis().looking_at(target_direction.normalized(), Vector3.UP)
	target.global_transform.basis = current_basis.slerp(target_basis, blend_lerp_speed * delta)
	
#func switch(blend_position: float):
	#pass
	#is_using_pistol = true if blend_position == -1 else false
	#
	#var weapon_type = "using_pistol" if is_using_pistol else "using_rifle"
	#animation_tree.set(PISTOL_RIFLE_AIMING, weapon_type)
	#animation_tree.set(PISTOL_RIFLE_IDLE, weapon_type)
#
	#if player.is_on_floor():
		#animation_tree.set(PISTOL_RIFLE_RUN, weapon_type)
	#else:
		#animation_tree.set(PISTOL_RIFLE_AIR, weapon_type)	
	#
	#print(name, ": Switch requested: ", blend_position)
	#animation_tree.set(SWITCH_WEAPON_BLEND, blend_position)
	#animation_tree.set(SWITCH_WEAPON, 0)
	#await get_tree().process_frame
	#print(name, ": Firing one-shot")
	#animation_tree.set(SWITCH_WEAPON, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

#TODO: REMEMBER THE GUN NEEDS AN ANIM PLAYER LOL
func switch() -> void:
	animation_tree.set(SWITCH_REQUEST, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	if not equipped_item or not equipped_item.get_child(0):
		print(name, ": NO EQUIPPED ITEM TO PUT AWAY")
		return
	print(name, ": equipped item exists")
	
	#TODO
	if equipped_item.get_child(0) is ViewModel:
		equipped_item.get_child(0).play_animation("glock_switch")

func update_animation_inputs(item_data: ItemData):
	if not item_data:
		return
	var animation_prefix: String = item_data.animation_name
	
	
	update_animation("hold", animation_prefix, "hold")
	
	update_animation("aim", animation_prefix, "aim")
	update_animation("scope", animation_prefix, "scope")
	
	update_animation("shoot", animation_prefix, "shoot")
	update_animation("scope_shoot", animation_prefix, "scope_shoot")
	
	update_animation("reload", animation_prefix, "reload")
	update_animation("inspect", animation_prefix, "inspect")
	update_animation("pullout", animation_prefix, "pullout")
	update_animation("switch", animation_prefix, "switch")
	play_item_animation("aim")

func get_ragdoll() -> Node:
	return $"../Human_Ultimate_Lipsync"

func update_animation(anim_node_name: String, anim_prefix: String, anim_name: String):
	var root = animation_tree.tree_root as AnimationNodeBlendTree
	var anim_blend_tree_node = root.get_node(anim_node_name) as AnimationNodeAnimation
	
	var full_anim_name = anim_prefix + "_" + anim_name
	
	var anim_player: AnimationPlayer = animation_tree.get_node(animation_tree.anim_player)

	if anim_player.has_animation(full_anim_name):
		anim_blend_tree_node.animation = full_anim_name
	else:
		print(name, ": the character skin does not even have the animation:", full_anim_name)
		anim_blend_tree_node.animation = "glock_" + anim_name
		print(name, ": Using default animation of the glock. Animation set to: ", "glock_" + anim_name)
		


func pullout():
	animation_tree.set(PULLOUT_REQUEST, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	play_item_animation("pullout")
	
func reload():
	animation_tree.set(RELOAD_REQUEST, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	play_item_animation("reload")

func shoot():
	animation_tree.set(SHOOT_REQUEST, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	play_item_animation("shoot")

func inspect():
	animation_tree.set(INSPECT_REQUEST, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	play_item_animation("inspect")

func set_lip_shape(arg: String):
	animation_tree.set(LIPSYNC_REQUEST, arg)

func set_expression(arg: String):
	animation_tree.set(EXPRESSION_REQUEST, arg)

func set_random_expression():
	randomize() # Important to seed the random number generator

	var emotions = ["anger", "fear", "happy", "sadness"]
	var random_emotion = emotions[randi() % emotions.size()]
	animation_tree.set(EXPRESSION_REQUEST, random_emotion)

func play_item_animation(anim_name: String):
	
	if not equipped_item:
		print(name, ": No equipped item")
		return
	
	if not player.inventory_data.get_current_item():
		return

	var animation_prefix: String = player.inventory_data.get_current_item().animation_name
	
	if equipped_item.get_child(0) and equipped_item.get_child(0) is ViewModel:
		print(name, ": playing anim name")
		equipped_item.get_child(0).play_animation(animation_prefix + "_" + anim_name)
	else:
		print(name, ": no viewmodel found")
