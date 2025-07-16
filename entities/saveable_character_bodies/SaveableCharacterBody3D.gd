# SaveableCharacterBody3D.gd
extends CharacterBody3D
class_name SaveableCharacterBody3D

# This class works similarly to the Saveable class but represents a CharacterBody3D
var scene_path : String

func _ready():
	scene_path = "res://entities/saveables/saveable_character_bodies/SaveableChracterBody3D.tscn"
	
func get_save_data() -> Dictionary:
	return {
		"name": name,
		"scene_path": scene_path,
		"position": global_position,
		"rotation": global_rotation,
		"velocity": velocity,
		"visible": visible,
	}

func apply_save_data(data: Dictionary) -> void:
	if data.has("name"):
		name = data["name"]
		print(name)
	if data.has("position"):
		global_position = data["position"]
	if data.has("rotation"):
		global_rotation = data["rotation"]
	if data.has("velocity"):
		velocity = data["velocity"]
	if data.has("visible"):
		visible = data["visible"]
