extends Node3D

@export var player: AdvancedCharacter

@onready var animation_tree: AnimationTree = $"../AnimationTree"
const CROUCH_BLEND_SPACE := "parameters/crouch_blend_space/blend_position"
const WALK_BLEND_SPACE := "parameters/walk_blend_space/blend_position"
const SPRINT_BLEND_SPACE := "parameters/sprint_blend_space/blend_position"
const CROUCH_WALK_SPRINT_BLEND := "parameters/crouch_walk_sprint_blend/blend_amount"
@onready var equipped_item :EquippedItem= $"../Human2026/Armature/Skeleton3D/HandBone/EquippedItem"
@onready var ik : SkeletonIK3D= $"../Human2026/Armature/Skeleton3D/SkeletonIK3D"
@onready var target : Node3D = $"../Target"
#func _ready() -> void:

func equip_item(item_data: ItemData):
	equipped_item.equip_item(item_data)
	#update_animation_inputs(item_data)

func _process(delta: float) -> void:
	
	var head = player.get_node("Head")
	target.global_rotation = Vector3(-head.global_rotation.x, head.global_rotation.y + PI, head.global_rotation.z)


	if player.hold_mode == AdvancedCharacter.HoldMode.HOLSTER:
		#hold_aim_scope = -1
		#upper_body_blend_target = 0
		if ik.is_running():
			ik.stop()
	elif player.hold_mode == AdvancedCharacter.HoldMode.HOLD:
		#hold_aim_scope = -1
		#upper_body_blend_target = 1
		if ik.is_running():
			ik.stop()
	elif player.hold_mode == AdvancedCharacter.HoldMode.AIM:
		#hold_aim_scope = 0
		#upper_body_blend_target = 1
		#aim_scope_shoot_transition = "is_aiming"
		if not ik.is_running():
			ik.start()
	elif player.hold_mode == AdvancedCharacter.HoldMode.SCOPE:
		#hold_aim_scope = 1
		#upper_body_blend_target = 1
		#aim_scope_shoot_transition = "is_scoping"
		if not ik.is_running():
			ik.start()
func _physics_process(delta: float) -> void:
	
	
	
	var local_velocity = global_transform.basis.inverse() * player.velocity
	var velocity_2d = Vector2(-local_velocity.x, -local_velocity.z)
	
	animation_tree.set(CROUCH_BLEND_SPACE, velocity_2d)
	animation_tree.set(WALK_BLEND_SPACE, velocity_2d)
	animation_tree.set(SPRINT_BLEND_SPACE, velocity_2d)  
	animation_tree.set(CROUCH_WALK_SPRINT_BLEND, -1 if player.move_mode == AdvancedCharacter.MoveMode.CROUCH else 0 if player.move_mode == AdvancedCharacter.MoveMode.WALK else 1)

func randomize_character() -> void:
	var meshes_parent: Node = $"../Human2026/default_shirt_and_jeans/Skeleton3D"
	if not meshes_parent:
		push_error("Meshes parent node not found")
		return

	var body_meshes: Array[MeshInstance3D] = [$"../Human2026/default_shirt_and_jeans/Skeleton3D/ultimate_human_mesh_Baked_001", $"../Human2026/default_shirt_and_jeans/Skeleton3D/ultimate_human_mesh_Baked_002"]
	var hair_meshes: Array[MeshInstance3D] = [$"../Human2026/default_shirt_and_jeans/Skeleton3D/Female_Bob_Haircut_Baked", ]

	# Collect meshes
	for child: Node in meshes_parent.get_children():
		if child is MeshInstance3D:
			var mesh_instance := child as MeshInstance3D
			if "Hair" in mesh_instance.name:
				hair_meshes.append(mesh_instance)
			else:
				body_meshes.append(mesh_instance)

	if body_meshes.is_empty():
		push_error("No body meshes found")
		return

	# Use first body mesh as reference
	var reference_mesh_instance: MeshInstance3D = body_meshes[0]
	var reference_mesh: Mesh = reference_mesh_instance.mesh
	if not reference_mesh:
		push_error("Reference body mesh has no mesh assigned")
		return

	# Generate shared random values for body blend shapes
	var body_blendshape_values: Dictionary = {}

	for i: int in range(reference_mesh.get_blend_shape_count()):
		var shape_name: String = reference_mesh.get_blend_shape_name(i)

		if shape_name == "SEX":
			body_blendshape_values[shape_name] = int(randi() % 2)
		else:
			body_blendshape_values[shape_name] = randf_range(-1.0, 1.0)

	# Apply to body meshes
	for mesh_instance: MeshInstance3D in body_meshes:
		var mesh: Mesh = mesh_instance.mesh
		if not mesh:
			push_error("Body mesh '%s' has no mesh assigned" % mesh_instance.name)
			continue

		for shape_name: String in body_blendshape_values.keys():
			var shape_index: int = mesh.find_blend_shape_by_name(shape_name)
			if shape_index == -1:
				push_error(
					"Blend shape '%s' missing on body mesh '%s'" %
					[shape_name, mesh_instance.name]
				)
				continue

			mesh_instance.set(
				"blend_shapes/" + shape_name,
				body_blendshape_values[shape_name]
			)

	# Randomize hair independently
	for hair_instance: MeshInstance3D in hair_meshes:
		var hair_mesh: Mesh = hair_instance.mesh
		if not hair_mesh:
			push_error("Hair mesh '%s' has no mesh assigned" % hair_instance.name)
			continue

		for i: int in range(hair_mesh.get_blend_shape_count()):
			var shape_name: String = hair_mesh.get_blend_shape_name(i)
			hair_instance.set(
				"blend_shapes/" + shape_name,
				randf_range(-1.0, 1.0)
			)


func pullout():
	pass
	
func reload():
	pass

func shoot():
	pass

func inspect():
	pass

func set_lip_shape(arg: String):
	pass

func set_expression(arg: String):
	pass

func set_random_expression():
	pass

func play_item_animation(anim_name: String):
	pass
	#if not equipped_item:
		#print(name, ": No equipped item")
		#return
	#
	#if not player.inventory_data.get_current_item():
		#return
#
	#var animation_prefix: String = player.inventory_data.get_current_item().animation_name
	#
	#if equipped_item.get_child(0) and equipped_item.get_child(0) is ViewModel:
		#print(name, ": playing anim name")
		#equipped_item.get_child(0).play_animation(animation_prefix + "_" + anim_name)
	#else:
		#print(name, ": no viewmodel found")

func get_equipped_item_child():
	return equipped_item.get_child(0) if equipped_item.get_child_count() > 0 else null
