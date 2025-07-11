extends CanvasLayer

#@export var pausable := true
@export var can_save := true
@onready var player := get_tree().get_root().get_node("Main/Player")
@onready var processor := get_tree().get_root().get_node("Main/Processor")
@onready var main_node := get_tree().get_root().get_node("Main")
@onready var save_button := $Control/VBoxContainer/SaveGame

# Save button reference (used in _on_save_game_pressed, but updated by Main)
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func disable_saves():
	can_save = false
	save_button.disabled = true
	save_button.text = "Finish dialogue to save"
	
func enable_saves():
	can_save = true
	save_button.disabled = false
	save_button.text = "Save Game"
	


func _on_quit_to_menu_pressed() -> void:
	Dialogic.end_timeline()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://interface/main_menu/main_menu.tscn")

func _on_return_to_game_pressed() -> void:
	processor.unpause_game()

func _on_save_game_pressed() -> void:
	if player:
		SaveManagerSingleton.save_game(player, main_node)
		Dialogic.Save.save()
	else:
		print("Player not found. Cannot save.")
