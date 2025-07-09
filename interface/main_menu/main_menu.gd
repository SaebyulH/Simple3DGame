extends Control

func _on_new_game_pressed() -> void:
	SaveManagerSingleton.should_load_game = false
	get_tree().change_scene_to_file("res://places/main.tscn")

func _on_load_game_pressed() -> void:
	if ResourceLoader.exists("user://save_data.tres"):
		SaveManagerSingleton.should_load_game = true
		get_tree().change_scene_to_file("res://places/main.tscn")
	else:
		print("⚠️ No save file to load.")



func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://interface/options_menu/options_menu.tscn")

func _on_exit_to_desktop_pressed() -> void:
	get_tree().quit()
