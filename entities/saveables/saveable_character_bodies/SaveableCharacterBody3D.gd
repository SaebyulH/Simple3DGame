# SaveableCharacterBody3D.gd
extends CharacterBody3D
class_name SaveableCharacterBody3D

#@export var save_id: String = ""
var scene_path : String

func _ready():
	scene_path = "res://entities/saveables/saveable_character_bodies/SaveableChracterBody3D.tscn"
	
func get_save_data() -> Dictionary:
	return {
		"scene_path": scene_path,
		"position": global_position,
		"rotation": global_rotation,
		
		"visible": visible,
		"velocity": velocity,
	}

func apply_save_data(data: Dictionary) -> void:
	if data.has("position"):
		global_position = data["position"]
	if data.has("rotation"):
		global_rotation = data["rotation"]
	if data.has("visible"):
		visible = data["visible"]
	if data.has("velocity"):
		velocity = data["velocity"]
