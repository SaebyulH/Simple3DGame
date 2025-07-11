extends Node3D

@onready var player: Player = get_owner()
#@onready var skin:= get_owner().get_node("Skin")
@onready var animation_tree: AnimationTree = get_owner().get_node("Skin/MaxSkin/AnimationTree")

var direction = Vector3.BACK
var velocity = Vector3.ZERO
var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO



var smoothed_velocity: Vector2 = Vector2.ZERO
@export var blend_lerp_speed: float = 8  # Adjust this value to control lag/smoothing
#func _ready() -> void:
	#animation_tree.set("parameters/aim_transition/transition_request", 1)

func _physics_process(delta: float) -> void:
	animation_tree.set("parameters/aim_transition/transition_request", 
	"not_aiming" if player.inventory_data.current_index == -1 else "aiming")
	
	#print(animation_tree.get("parameters/aim_transition/current_state"))
	# Convert player velocity to skin's local space
	var local_velocity = global_transform.basis.inverse() * player.velocity
	var velocity2D = Vector2(local_velocity.x, local_velocity.z)
	smoothed_velocity = smoothed_velocity.lerp(velocity2D, blend_lerp_speed * delta)
	animation_tree.set("parameters/BlendSpace2D/blend_position", smoothed_velocity)
	
	animation_tree.set("parameters/idle_walk_blend/blend_amount", smoothed_velocity.length()/player.get_effective_speed())
	
	
