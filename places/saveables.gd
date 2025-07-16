extends Node3D
func _apply_world_save_data(world_data: WorldData) -> void:
	for saveable_data in world_data.saveables_data:
		var scene_path = saveable_data["scene_path"]
		var scene_resource = load(scene_path)
		
		if scene_resource:
			var instance = scene_resource.instantiate()
			add_child(instance)  # self is Saveables node
			instance.apply_save_data(saveable_data)
