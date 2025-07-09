@tool
extends Node3D

# Show button in inspector
@export_category("Saveable ID Tools")
@export var assign_save_ids := false:
	set(value):
		if value:
			_assign_ids()
		assign_save_ids = false  # Reset toggle

func _assign_ids():
	var index := 0
	for child in get_children():
		if child is Saveable or SaveableCharacterBody3D:
			child.save_id = "%s_%d" % [child.name, index]
			index += 1
	print("✅ Assigned save_id values to all Saveables.")
	
	# Notify the editor that something has changed
	if Engine.is_editor_hint():
		notify_property_list_changed()  # Marks the scene dirty for saving
