extends Node3D

@export var animation_tree : AnimationTree
@onready var crab : TalkingCrab = get_owner()

func _physics_process(delta: float) -> void:
	var velocity2D = Vector2(crab.velocity.x, crab.velocity.z) 
	#animation_tree.set("parameters/Walk/blend_position", velocity2D)
	#animation_tree.set("parameters/conditions/idle", velocity2D.normalized() == Vector2.ZERO)
	#animation_tree.set("parameters/conditions/talk", velocity2D.normalized() != Vector2.ZERO)	
	#print("idle" if velocity2D.normalized() == Vector2.ZERO else "walking")
	
