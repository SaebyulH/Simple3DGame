extends CanvasLayer

@export var player : Player
#@export var inventory_data: InventoryData

@onready var item_list: ItemList = $VBoxContainer/MainContent/ItemListPanel/ItemList
@onready var max_mass_label: Label = $VBoxContainer/TopInfoPanel/MaxMassLabel
@onready var item_count_label: Label = $VBoxContainer/TopInfoPanel/ItemCountLabel
@onready var item_details: Label = $VBoxContainer/MainContent/InfoPanel/ItemDetails
@onready var preview: Node3D = $VBoxContainer/MainContent/InfoPanel/SubViewportContainer/SubViewport/ItemPreviewRoot
@onready var drop_button : Button = $VBoxContainer/MainContent/InfoPanel/DropButton
#var _last_item_count: int = -1
var rotation_speed := 1.0 # Radians per second

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	update_header()
	update_list()


func _process(delta: float) -> void:
	if is_instance_valid(preview):
		preview.rotate_y(rotation_speed * delta)
		
func update():
	update_header()
	update_list()
	update_details()
	update_preview()

func update_list():
	item_list.clear()
	for i in player.inventory_data.items:
		item_list.add_item(i.display_name)
	



func update_header():
	max_mass_label.text = "Mass: " + str(player.inventory_data.total_mass()) + "/" +str(player.inventory_data.max_mass) + " Max"
	item_count_label.text = "Item Count: " + str(player.inventory_data.items.size())

func _on_item_list_item_selected(index: int) -> void:
	player.set_inventory_selection(index)
	update_details()
	
	
func update_details():
	var current_index = player.inventory_data.current_index
	print(str(current_index))
	if current_index >= 0:
		item_details.text = _format_item_details(player.inventory_data.items[current_index])
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
	
	var current_index = player.inventory_data.current_index
	if current_index < 0:
		return
	
	var item: ItemData = player.inventory_data.items[current_index]
	if item.view_model:
		var item_instance = item.view_model.instantiate()
		preview.add_child(item_instance)
		item_instance.owner = preview # Needed for proper scene ownership

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
		item.range,
		item.damage
	]


func _on_drop_button_pressed() -> void:
	player.drop_current_item() # Replace with function body.
	update()
