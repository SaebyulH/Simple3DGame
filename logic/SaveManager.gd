extends Node

var should_load_game := false

func save_game(player, main_node):
	var state = GameState.new()
	state.player_data = player.get_save_data()
	state.world_data = get_world_save_data()
	ResourceSaver.save(state, "user://save_data.tres")
	print("💾 Game saved.")

func load_game() -> GameState:
	if ResourceLoader.exists("user://save_data.tres"):
		var state = ResourceLoader.load("user://save_data.tres") as GameState
		apply_world_save_data(state.world_data)
		return state
	else:
		print("⚠️ Save file does not exist.")
		return null

func get_world_save_data() -> WorldData:
	var world_data = WorldData.new()
	var saveables = get_tree().get_nodes_in_group("saveable")
	for obj in saveables:
		if obj.has_method("get_save_data"):
			var id = obj.get("save_id")
			if id == "":
				push_warning("Saveable object %s is missing a save_id" % obj.name)
				continue
			world_data.saveables_data[id] = obj.get_save_data()
	return world_data

func apply_world_save_data(world_data: WorldData) -> void:
	var saveables = get_tree().get_nodes_in_group("saveable")
	for obj in saveables:
		var id = obj.get("save_id")
		if world_data.saveables_data.has(id):
			obj.apply_save_data(world_data.saveables_data[id])
		else:
			print("⚠️ No saved data for saveable with ID: %s" % id)
