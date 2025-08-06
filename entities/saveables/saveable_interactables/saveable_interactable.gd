extends Saveable
class_name SaveableInteractable
@export var display_name : String 
# Literally the same, just has a name so it can be refered to in the interact function
# The reason this might need to be saved is because it could move around since it is a RigidBody

func _ready() -> void:
	super()
	scene_path = "res://entities/saveables/Saveable.tscn"

func get_interact_verb() -> String:
	return "Interact"

func get_display_name() -> String:
	return display_name




func get_save_data() -> Dictionary:
	var save_data = super()
	save_data["display_name"] = display_name
	return save_data

func apply_save_data(data: Dictionary) -> void:
	super(data)
	if data.has("display_name"):
		display_name = data["display_name"]
