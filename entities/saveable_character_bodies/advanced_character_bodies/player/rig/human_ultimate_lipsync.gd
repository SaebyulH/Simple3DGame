extends Saveable
class_name HumanUltimateLipsync 

@onready var skeleton: Skeleton3D = $rig/Skeleton3D

var display_name := ""

func _ready() -> void:
	super()
	disable_ragdoll()

func interact(player: AdvancedCharacter):
	player.change_health(300)
	player.play_sound("res://assets/tf2-heavy-om-nom-nom-sound-effect.mp3")
	queue_free()

func delete_equipped_item():
	for child in $rig/Skeleton3D/HandBone/EquippedItem.get_children():
		child.queue_free()

func get_equipped_item_position():
	return $rig/Skeleton3D/HandBone/EquippedItem.get_child(0).global_position
	
func get_equipped_item_rotation():
	return $rig/Skeleton3D/HandBone/EquippedItem.get_child(0).global_rotation


func get_interact_verb() -> String:
	return "Eat (Heal 300 HP)"

func get_display_name() -> String:
	return display_name

func enable_ragdoll():
	$AnimationPlayer.active = false
	$AnimationPlayer.stop()

	for child in $rig/Skeleton3D/PhysicalBoneSimulator3D.get_children():
		child.set_collision_layer_value(1, true)
		child.set_collision_layer_value(2, true) #IMPORTANT AS WE WANfadsfasdfdsaT IT TO STILL BE INTERACTABLE VIA GUNS
		
		child.set_collision_mask_value(1, true)
		child.set_collision_mask_value(2, false)
		
		child.joint_type = PhysicalBone3D.JOINT_TYPE_6DOF
		
	$rig/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()
	

 #This is kinda useless but might as well make it
func disable_ragdoll():
	$AnimationPlayer.active = true
	$rig/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_stop_simulation()
	
	for child in $rig/Skeleton3D/PhysicalBoneSimulator3D.get_children():
		child.set_collision_layer_value(1, false)
		child.set_collision_layer_value(2, true)
		
		child.set_collision_mask_value(1, false)
		child.set_collision_mask_value(2, true)
		
		child.joint_type = PhysicalBone3D.JOINT_TYPE_NONE



func get_save_data() -> Dictionary:
	var save_data = super()
	save_data["display_name"] = display_name
	# Save bone poses
	var bone_data := {}
	for i in skeleton.get_bone_count():
		var bone_name = skeleton.get_bone_name(i)
		bone_data[bone_name] = skeleton.get_bone_global_pose(i)
	save_data["bone_poses"] = bone_data

	return save_data

func apply_save_data(data: Dictionary) -> void:
	super(data)

	if data.has("display_name"):
		display_name = data["display_name"]
	enable_ragdoll()
	# Restore bone poses
	if data.has("bone_poses"):
		for bone_name in data["bone_poses"]:
			var bone_idx = skeleton.find_bone(bone_name)
			if bone_idx != -1:
				var transform: Transform3D = data["bone_poses"][bone_name]
				skeleton.set_bone_global_pose_override(bone_idx, transform, 1.0, true)
