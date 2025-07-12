# Saveable.gd
extends Node3D
class_name Saveable

# This is a class that can save and apply it's transformation data as well as the appropriate scene
var scene_path : String


func _ready():
	scene_path = "res://entities/saveables/Saveable.tscn"

func get_save_data() -> Dictionary:
	return {
		"scene_path": scene_path,
		"position": global_position,
		"rotation": global_rotation,
		"visible": visible,
		#"type": get_class()  # optional but helpful for debugging
	}

func apply_save_data(data: Dictionary) -> void:
	#if data.has("scene_path"):
		#scene_path = data["scene_path"]
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
