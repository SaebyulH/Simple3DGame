extends SaveableInteractableRigidBody3D
class_name EnrichObject

#func _ready() -> void:
	#super()
	#scene_path = "res://entities/saveables/saveable_interactables/test_objects/enrich_object/enrich_object.tscn"

func interact(player):
	if player.has_method("change_wealth"):
		player.change_wealth(10)

func get_interact_verb() -> String:
	return "Get Richer"
