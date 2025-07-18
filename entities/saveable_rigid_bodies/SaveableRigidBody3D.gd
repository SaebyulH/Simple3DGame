# Saveable.gd
extends RigidBody3D
class_name SaveableRigidBody3D

# This is a class that can save and apply it's transformation data as well as the appropriate scene
var scene_path : String


func _ready():
	var script_path : String = get_script().resource_path
	assert(script_path.ends_with(".gd"), "Script does not end with .gd")
	scene_path = script_path.substr(0, script_path.length() - 3) + ".tscn"

func get_save_data() -> Dictionary:
	return {
		"name": name,
		"scene_path": scene_path,
		"position": global_position,
		"rotation": global_rotation,
		"visible": visible,
		#"type": get_class()  # optional but helpful for debugging
	}

func apply_save_data(data: Dictionary) -> void:
	#if data.has("scene_path"):
		#scene_path = data["scene_path"]
	if data.has("name"):
		name = data["name"]
		print(name)
	if data.has("position"):
		global_position = data["position"]
	if data.has("rotation"):
		global_rotation = data["rotation"]
	if data.has("visible"):
		visible = data["visible"]

#func get_display_name() -> String:
	#if "display_name" in self:
		#return display_name
	#else:
		#return name
