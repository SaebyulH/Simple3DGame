extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_new_game_pressed() -> void:
	SaveManagerSingleton.should_load_game = false
	get_tree().change_scene_to_file("res://places/main.tscn")
