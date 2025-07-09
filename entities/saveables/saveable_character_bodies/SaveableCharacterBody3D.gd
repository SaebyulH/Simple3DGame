# SaveableCharacterBody3D.gd
extends CharacterBody3D
class_name SaveableCharacterBody3D

@export var save_id: String = ""

func _ready():
	add_to_group("saveable")

func get_save_data() -> Dictionary:
	return {
		"save_id": save_id,
		"position": global_transform.origin,
		"visible": visible,
		"velocity": velocity,
	}

func apply_save_data(data: Dictionary) -> void:
	if data.has("position"):
		global_transform.origin = data["position"]
	if data.has("visible"):
		visible = data["visible"]
	if data.has("velocity"):
		velocity = data["velocity"]
