# Saveable.gd
extends Node3D
class_name Saveable
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
	if data.has("name"):
		name = data["name"]
	if data.has("position"):
		global_position = data["position"]
	if data.has("rotation"):
		global_rotation = data["rotation"]
	if data.has("visible"):
		visible = data["visible"]
