extends SaveableCharacterBody3D
class_name NonPlayerCharacter

var talkable : bool
var tradeable : bool





var inventory_data: InventoryData = InventoryData.new()
var character_data: CharacterData = CharacterData.new()
@onready var player: Node = get_tree().get_root().get_node("Main/Player")
@onready var processor: Node = get_tree().get_root().get_node("Main/Processor")  # Adjust this path as needed

func _ready() -> void:
	super()
	talkable = true
	tradeable = false
	character_data = CharacterFactory.create_default_character_data()
	inventory_data = InventoryFactory.create_default_inventory_data()
	scene_path = "res://entities/saveable_character_bodies/npcs/NonPlayerCharacter.tscn"

func set_inventory_selection(index: int):
	inventory_data.set_current_index(index)
	#update_equipped_item()

func get_save_data() -> Dictionary:
	var save_data = super()
	save_data["talkable"] = talkable
	save_data["tradeable"] = tradeable
	return save_data

func apply_save_data(data: Dictionary) -> void:
	super(data)
	if data.has("talkable"):
		talkable = data["talkable"]
	if data.has("tradable"):
		tradeable = data["tradeable"]

func start_dialogue(arg: String):
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Dialogic.start(arg)

	player.immobilize()
	processor.in_dialogue = true

func get_interact_verb() -> String:
	return "Talk"

func interact(player: Player):
	start_dialogue("default_npc_timeline")

func trade(player: Player):
	processor.trade_menu.player = player
	processor.trade_menu.npc = self
	processor.show_trade()
	pass
	#processor.show_trade()

func change_health(amount: int):
	character_data.change_health(amount)
	if character_data.health <= 0: die()


func die():
	for item in inventory_data.items:
		processor.spawn_pickup_near_character(item, self)
	queue_free()
	
func DialogicSignal(arg: String):
	if arg == "exit":
		print("dialogue exited")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		player.unimmobilize()
		processor.in_dialogue = false
