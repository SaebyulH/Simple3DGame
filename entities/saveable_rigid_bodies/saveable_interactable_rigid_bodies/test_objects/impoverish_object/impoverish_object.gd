extends SaveableInteractableRigidBody3D
class_name ImpoverishObject

#func _ready() -> void:
	#super()
	#scene_path = "res://entities/saveables/saveable_interactables/test_objects/impoverish_object/impoverish_object.tscn"

func interact(player):
	if player.has_method("change_wealth"):
		player.change_wealth(-10)

func get_interact_verb() -> String:
	return "Get Poorer"
