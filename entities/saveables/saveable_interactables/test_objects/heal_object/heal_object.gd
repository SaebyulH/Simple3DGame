extends SaveableInteractable
class_name HealObject

func _ready() -> void:
	super()
	scene_path = "res://entities/saveables/saveable_interactables/test_objects/heal_object/heal_object.tscn"

func interact(player):
	if player.has_method("change_health"):
		player.change_health(10)

func get_interact_verb() -> String:
	return "Get Healed"
