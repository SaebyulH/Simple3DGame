extends Node

@onready var pause_menu = get_parent().get_node("PauseMenu")
@onready var player_hud = get_parent().get_node("PlayerHUD")
@onready var main_node = get_parent()
@onready var saveables_node = get_parent().get_node("Saveables")
@onready var trade_menu = get_parent().get_node("TradeMenu")
@onready var inventory_screen = get_parent().get_node("InventoryScreen")

@onready var player = get_parent().get_node("Player")

@export var in_dialogue := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	call_deferred("_maybe_load_save")

func _load_dialogic() -> void:
	Dialogic.Save.load()

func _maybe_load_save() -> void:
	if SaveManagerSingleton.should_load_game:
		var data = await SaveManagerSingleton.load_game(main_node)
		if data:
			# player.apply_save_data(data.player_data)
			Dialogic.Save.load()
		else:
			print("⚠️ Could not load save data.")
		SaveManagerSingleton.should_load_game = false
	else:
		print("🆕 Starting new game (no load)")


func _input(event):
	
	if event.is_action_pressed("ui_cancel"):
		if pause_menu.visible:
			unpause_game()
		else:
			pause_game()
	if event.is_action_pressed("inventory"):
		if inventory_screen.visible:
			hide_inventory()
		else:
			show_inventory()
	if event.is_action_pressed("trade"):
		if trade_menu.visible:
			hide_trade()
		else:
			#show_trade()
			pass
func pause_game():
	hide_inventory()
	hide_trade()
	hide_hud()
	pause_menu.show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if in_dialogue:
		pause_menu.disable_saves()
	else:
		pause_menu.enable_saves()

func unpause_game():
	#hide_inventory()
	#hide_trade()
	show_hud()
	pause_menu.hide()
	get_tree().paused = false
	if not in_dialogue:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func show_inventory():
	hide_hud()
	hide_trade()
	inventory_screen.show()
	inventory_screen.update()
	#inventory_screen.inventory_data = player.inventory_data
	#inventory_screen.update_inventory_ui()
	
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	
func hide_inventory():
	show_hud()
	inventory_screen.hide()
	
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func hide_hud():
	player_hud.hide()

func show_hud():
	player_hud.show()

func hide_trade():
	trade_menu.hide()
	show_hud()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func show_trade():
	hide_inventory()
	hide_hud()
	trade_menu.show()
	trade_menu.update()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func spawn_scene_at_position(scene_path: String, position: Vector3):
	pass





func spawn_pickup_near_character(saveable_data: ItemData, character: Node3D):
	var scene_path = saveable_data.scene_path
	var scene_resource = load(scene_path) # Load the PackedScene
	var instance = scene_resource.instantiate()
	saveables_node.add_child(instance)
	instance.apply_save_data_from_item_data(saveable_data)

	var forward = -character.global_transform.basis.z.normalized()
	var spawn_position = character.global_position + forward * 2.0
	instance.global_position = spawn_position
	instance.global_rotation = character.global_rotation + Vector3(0, PI/2, 0)
	
	# Customizable vertical force factor (can be adjusted)
	var vertical_force = 4.0  # Controls how much upward force to apply
	var speed = 4.0  # Horizontal speed factor
	# Mix forward direction with upward force (add the y component)
	var launch_direction = forward + Vector3(0, vertical_force, 0)
	launch_direction = launch_direction.normalized()  # Normalize to prevent excessive speed from the vertical force

	# Apply the velocity (horizontal and vertical components)
	if instance is RigidBody3D:
		instance.linear_velocity = launch_direction * speed
