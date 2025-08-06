extends Node3D

func _ready() -> void:
	$Human_Ultimate_Current/AnimationPlayer.active = false
	$Human_Ultimate_Current/AnimationPlayer.stop()

	$Human_Ultimate_Current/rig/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()
