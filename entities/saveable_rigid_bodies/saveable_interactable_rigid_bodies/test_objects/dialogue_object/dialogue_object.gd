extends SaveableInteractableRigidBody3D
class_name DialogueObject

@onready var player: Node = get_tree().get_root().get_node("Main/Saveables/Player")  # Adjust this path as needed
@onready var processor: Node = get_tree().get_root().get_node("Main/Processor")  # Adjust this path as needed

func _ready() -> void:
	super()
	#scene_path = "res://entities/saveables/saveable_interactables/test_objects/dialogue_object/dialogue_object.tscn"
	Dialogic.signal_event.connect(DialogicSignal)

func interact(_player):  # You can keep this parameter if you want, but it's unused now
	start_dialogue("shit_timeline")
	
func get_interact_verb() -> String:
	return "Talk"

func DialogicSignal(arg: String):
	if arg == "exit":
		print("dialogue exited")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		player.unimmobilize()
		processor.in_dialogue = false
		
func start_dialogue(arg: String):
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Dialogic.start(arg)

	player.immobilize()
	processor.in_dialogue = true

	#var head = player.get_node("Head")
#
	## ---- Step 1: Rotate player (Y-axis) to face object ----
	#var player_pos = player.global_transform.origin
	#var target_pos = global_transform.origin
	#var direction = target_pos - player_pos
	#direction.y = 0  # Flatten to horizontal
#
	#var target_angle = atan2(-direction.x, -direction.z)
	#player.rotation.y = target_angle
#
	## ---- Step 2: Rotate head (X-axis) to look up/down ----
	#var head_pos = head.global_transform.origin
	#var head_forward = -head.global_transform.basis.z  # This is the forward vector
	#var to_target = (target_pos - head_pos).normalized()
#
	## Compute angle between head forward and target in vertical axis
	#var vertical_angle = head_forward.angle_to(to_target)
#
	## Determine sign of angle using cross product
	#var cross = head_forward.cross(to_target)
	#var sign = sign(cross.x)  # X-axis is pitch
#
	## Apply signed pitch
	#var pitch = vertical_angle * sign
#
	#head.rotation.x = pitch
#
	#print("Pitch angle: ", rad_to_deg(pitch))
