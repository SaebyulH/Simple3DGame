extends Node3D

@export var player: AdvancedCharacter

@onready var animation_tree: AnimationTree = $"../AnimationTree"
const CROUCH_BLEND_SPACE := "parameters/crouch_blend_space/blend_position"
const WALK_BLEND_SPACE := "parameters/walk_blend_space/blend_position"
const SPRINT_BLEND_SPACE := "parameters/sprint_blend_space/blend_position"
const CROUCH_WALK_SPRINT_BLEND := "parameters/crouch_walk_sprint_blend/blend_amount"
@onready var equipped_item :EquippedItem= $"../Human2026/Armature/Skeleton3D/HandBone/EquippedItem"
@onready var ik : SkeletonIK3D= $"../Human2026/Armature/Skeleton3D/SkeletonIK3D"

#func _ready() -> void:

func equip_item(item_data: ItemData):
	equipped_item.equip_item(item_data)
	#update_animation_inputs(item_data)

func _process(delta: float) -> void:
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

func randomize_character():
	var mesh_instance: MeshInstance3D = $"../Human2026/Armature/Skeleton3D/ultimate_human_mesh_Baked"
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
	#for surface_index in mesh_instance.get_surface_override_material_count():
		#var base_material := mesh.surface_get_material(surface_index)
		#if base_material and base_material is StandardMaterial3D:
			#var new_material := base_material.duplicate()
			#new_material.albedo_color = Color(randf(), randf(), randf())
			#mesh_instance.set_surface_override_material(surface_index, new_material)



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
