#extends Node
#
#@onready var pause_menu = $PauseMenu 
#@onready var inventory_screen = $InventoryScreen 
#
#@onready var player = $Player
#
#@export var in_dialogue := false
#
#func _ready() -> void:
	#process_mode = Node.PROCESS_MODE_ALWAYS
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#call_deferred("_maybe_load_save")
#
#func _load_dialogic() -> void:
	#Dialogic.Save.load()
#
#func _maybe_load_save():
	#if SaveManagerSingleton.should_load_game:
		#var data = SaveManagerSingleton.load_game()
		#if data:
			#player.apply_save_data(data.player_data)
			#Dialogic.Save.load()
		#else:
			#print("⚠️ Could not load save data.")
		#SaveManagerSingleton.should_load_game = false
	#else:
		#print("🆕 Starting new game (no load)")
#
#func _input(event):
	#
	#if event.is_action_pressed("ui_cancel"):
		#if pause_menu.visible:
			#unpause_game()
		#else:
			#pause_game()
	#if event.is_action_pressed("inventory"):
		#if inventory_screen.visible:
			#hide_inventory()
		#else:
			#show_inventory()
#
#func pause_game():
	#pause_menu.show()
	#get_tree().paused = true
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#
	#if in_dialogue:
		#pause_menu.disable_saves()
	#else:
		#pause_menu.enable_saves()
#
#func unpause_game():
	#pause_menu.hide()
	#get_tree().paused = false
	#if not in_dialogue:
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		#
#func show_inventory():
	#inventory_screen.show()
	#get_tree().paused = true
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#
#func hide_inventory():
	#inventory_screen.hide()
	#get_tree().paused = false
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
