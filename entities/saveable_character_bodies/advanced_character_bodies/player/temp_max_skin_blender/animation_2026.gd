extends Node3D

@export var player: AdvancedCharacter

@onready var animation_tree: AnimationTree = $"../AnimationTree"

const WALK_BLEND_SPACE := "parameters/walk_blend_space/blend_position"


func _physics_process(delta: float) -> void:
	var local_velocity = global_transform.basis.inverse() * player.velocity
	var velocity_2d = Vector2(-local_velocity.x, -local_velocity.z)
	animation_tree.set(WALK_BLEND_SPACE, velocity_2d)
