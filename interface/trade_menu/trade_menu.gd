extends CanvasLayer

@export var player : Player
@export var npc : NonPlayerCharacter

@onready var preview_1 := $VBoxContainer/HBoxContainer/VBoxContainer/MainContent/InfoPanel/SubViewportContainer/SubViewport/ItemPreviewRoot
@onready var preview_2 := $VBoxContainer/HBoxContainer/VBoxContainer2/MainContent/InfoPanel/SubViewportContainer/SubViewport/ItemPreviewRoot
var rotation_speed := 1.0 # Radians per second

@onready var item_list_1 := $VBoxContainer/HBoxContainer/VBoxContainer/MainContent/ItemListPanel/ItemListPlayer
@onready var item_list_2 := $VBoxContainer/HBoxContainer/VBoxContainer2/MainContent/ItemListPanel/ItemListNPC

@onready var max_mass_label_1: Label = $VBoxContainer/HBoxContainer/VBoxContainer/TopInfoPanel/MaxMassLabel
@onready var max_mass_label_2: Label = $VBoxContainer/HBoxContainer/VBoxContainer2/TopInfoPanel/MaxMassLabel

@onready var item_count_label_1: Label = $VBoxContainer/HBoxContainer/VBoxContainer/TopInfoPanel/ItemCountLabel
@onready var item_count_label_2: Label = $VBoxContainer/HBoxContainer/VBoxContainer2/TopInfoPanel/ItemCountLabel

@onready var item_details_1: Label = $VBoxContainer/HBoxContainer/VBoxContainer/MainContent/InfoPanel/ItemDetails
@onready var item_details_2: Label = $VBoxContainer/HBoxContainer/VBoxContainer2/MainContent/InfoPanel/ItemDetails

@onready var sell_button: Button = $VBoxContainer/HBoxContainer/VBoxContainer/MainContent/InfoPanel/SellItemButton
@onready var buy_button: Button = $VBoxContainer/HBoxContainer/VBoxContainer2/MainContent/InfoPanel/BuyItemButton


func _ready() -> void:
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	update_headers()
	update_lists()


func _process(delta: float) -> void:
	if is_instance_valid(preview_1):
		preview_1.rotate_y(rotation_speed * delta)
	if is_instance_valid(preview_2):
		preview_2.rotate_y(rotation_speed * delta)
		
func update():
	update_headers()
	update_lists()
	update_both_details()
	update_preview_1()
	update_preview_2()
	

func update_lists():
	item_list_1.clear()
	item_list_2.clear()
	
	for i in player.inventory_data.items:
		item_list_1.add_item(i.display_name)
	for i in npc.inventory_data.items:
		item_list_2.add_item(i.display_name)



func update_headers():
	max_mass_label_1.text = "Mass: " + str(player.inventory_data.total_mass()) + "/" +str(player.inventory_data.max_mass) + " Max"
	item_count_label_1.text = "Item Count: " + str(player.inventory_data.items.size())
	max_mass_label_2.text = "Mass: " + str(npc.inventory_data.total_mass()) + "/" +str(npc.inventory_data.max_mass) + " Max"
	item_count_label_2.text = "Item Count: " + str(npc.inventory_data.items.size())
	

	
func update_both_details():
	var current_index_player = player.inventory_data.current_index
	print(str(current_index_player))
	if current_index_player >= 0:
		item_details_1.text = _format_item_details(player.inventory_data.items[current_index_player])
		update_preview_1()
		sell_button.show()
	else:
		item_details_1.text = "No Item Selected"
		hide_preview_1()
		sell_button.hide()
		
	var current_index_npc = npc.inventory_data.current_index
	print(str(current_index_npc))
	if current_index_npc >= 0:
		item_details_2.text = _format_item_details(npc.inventory_data.items[current_index_npc])
		update_preview_2()
		buy_button.show()
	else:
		item_details_2.text = "No Item Selected"
		hide_preview_2()
		buy_button.hide()
		

func hide_preview_1():
	preview_1.hide()

func hide_preview_2():
	preview_2.hide()

func update_preview_1():
	preview_1.show()
	# Clear previous preview
	for child in preview_1.get_children():
		child.queue_free()
	
	var current_index = player.inventory_data.current_index
	if current_index < 0:
		return
	
	var item: ItemData = player.inventory_data.items[current_index]
	if item.view_model:
		var item_instance = item.view_model.instantiate()
		preview_1.add_child(item_instance)
		item_instance.owner = preview_1 # Needed for proper scene ownership

func update_preview_2():
	preview_2.show()
	# Clear previous preview
	for child in preview_2.get_children():
		child.queue_free()
	
	var current_index = npc.inventory_data.current_index
	if current_index < 0:
		return
	
	var item: ItemData = npc.inventory_data.items[current_index]
	if item.view_model:
		var item_instance = item.view_model.instantiate()
		preview_2.add_child(item_instance)
		item_instance.owner = preview_2 # Needed for proper scene ownership

func _format_item_details(item: ItemData) -> String:
	return """Name: %s
		Mass: %.1f
		Value: $%.2f
		Uses Ammo: %s
		Ammo Type: %s
		Range: %.1f
		Damage: %d""" % [
		item.display_name,
		item.mass,
		item.value,
		item.uses_ammo,
		item.ammo_type.resource_name if item.uses_ammo and item.ammo_type else "N/A",
		item.hitscan_range,
		item.damage
	]




func _on_sell_item_button_pressed() -> void:
	player.inventory_data.move_item_at_to(player.inventory_data.current_index, npc.inventory_data)
	update()
	#pass # Replace with function body.


func _on_buy_item_button_pressed() -> void:
	npc.inventory_data.move_item_at_to(npc.inventory_data.current_index, player.inventory_data)
	update()
	
	#pass # Replace with function body.


func _on_item_list_player_item_selected(index: int) -> void:
	player.set_inventory_selection(index)
	update_both_details()


func _on_item_list_npc_item_selected(index: int) -> void:
	npc.set_inventory_selection(index)
	update_both_details()
