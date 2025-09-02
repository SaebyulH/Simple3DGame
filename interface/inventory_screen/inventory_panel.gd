extends Control

@export var player : Player

@onready var item_list: ItemList = $HBoxContainer2/ItemList

#@onready var max_mass_label: Label = $VBoxContainer/TopInfoPanel/MaxMassLabel
#@onready var item_count_label: Label = $VBoxContainer/TopInfoPanel/ItemCountLabel
@onready var item_details: Label = $HBoxContainer2/VBoxContainer/ScrollContainer/ItemDetails
@onready var preview: Node3D = $HBoxContainer2/VBoxContainer/SubViewportContainer/SubViewport/ItemPreviewRoot
@onready var drop_button : Button = $HBoxContainer2/VBoxContainer/DropButton


#var _last_item_count: int = -1
var rotation_speed := 1.0 # Radians per second

func _process(delta: float) -> void:
	if is_instance_valid(preview):
		preview.rotate_y(rotation_speed * delta)
		
func update():
	#update_header()
	update_list()
	update_details()
	update_preview()

func update_list():
	item_list.clear()
	for i in player.inventory_data.items:
		item_list.add_item(i.display_name)
	
#func update_header():
	#max_mass_label.text = "Mass: " + str(player.inventory_data.total_mass()) + "/" +str(player.inventory_data.max_mass) + " Max"
	#item_count_label.text = "Item Count: " + str(player.inventory_data.items.size())

func _on_item_list_item_selected(index: int) -> void:
	player.inventory_data.set_current_index(index)
	update_details()
	
	
func update_details():
	var current_index = player.inventory_data.current_index
	print(str(current_index))
	if current_index >= 0:
		item_details.text = player.inventory_data.items[current_index].to_string()
		update_preview()
		drop_button.show()
	else:
		item_details.text = "No Item Selected"
		hide_preview()
		drop_button.hide()
		

func hide_preview():
	preview.hide()

func update_preview():
	preview.show()

	# Clear previous preview
	for child in preview.get_children():
		child.queue_free()
	
	if player.inventory_data.get_current_item():
		var item = player.inventory_data.get_current_item()
		if item.view_model_path:
			var item_instance = load(item.view_model_path).instantiate()
			preview.add_child(item_instance)
			item_instance.owner = preview # Needed for proper scene ownership




func _on_drop_button_pressed() -> void:
	player.drop_current_item() # Replace with function body.
	update()
