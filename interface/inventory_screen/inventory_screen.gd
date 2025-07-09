extends Control

@export var inventory_data: InventoryData

@onready var item_list: ItemList = $MainContent/ItemListPanel/ItemList
@onready var max_mass_label: Label = $TopInfoPanel/MaxMassLabel
@onready var item_count_label: Label = $TopInfoPanel/ItemCountLabel
@onready var item_details: Label = $MainContent/InfoPanel/ItemDetails
@onready var item_preview_root: Node3D = $MainContent/InfoPanel/Item3DPreview/SubViewport/ItemPreviewRoot

var hovered_index := -1

func _ready():
	item_list.item_clicked.connect(_on_item_clicked)
	item_list.allow_reselect = true

	#item_list.item_mouse_entered.connect(_on_item_hovered)
	$MainContent/ItemListPanel.connect("mouse_exited", _on_mouse_exited)
	
func _on_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	# Optional: check for left click only
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		inventory_data.current_index = index
		show_item_info(inventory_data.items[index])
		item_list.select(index) # visually select it

func update_inventory_ui():
	if not inventory_data:
		return

	# Top panel
	max_mass_label.text = "Max Mass: %.1f" % inventory_data.max_mass
	item_count_label.text = "Items: %d" % inventory_data.items.size()

	# List panel
	item_list.clear()
	for item in inventory_data.items:
		item_list.add_item(item.display_name)

	# Auto-select current item
	if inventory_data.current_index >= 0 and inventory_data.current_index < inventory_data.items.size():
		item_list.select(inventory_data.current_index)
		show_item_info(inventory_data.items[inventory_data.current_index])
	else:
		item_details.text = "No item selected."
		update_3d_preview(null)

func _on_item_selected(index: int):
	inventory_data.current_index = index
	show_item_info(inventory_data.items[index])

func _on_item_hovered(index: int):
	hovered_index = index
	show_item_info(inventory_data.items[index])

func _on_mouse_exited():
	hovered_index = -1
	if inventory_data and inventory_data.current_index >= 0 and inventory_data.current_index < inventory_data.items.size():
		show_item_info(inventory_data.items[inventory_data.current_index])

func show_item_info(item: ItemData):
	item_details.text = """Name: %s
Mass: %.1f
Value: %.1f
Uses Ammo: %s
Ammo Type: %s
Range: %.1f
Damage: %d
Health: %d""" % [
		item.display_name,
		item.mass,
		item.value,
		item.uses_ammo,
		item.ammo_type.resource_name if item.uses_ammo and item.ammo_type else "N/A",
		item.range,
		item.damage,
		item.health
	]
	update_3d_preview(item)

func update_3d_preview(item: ItemData):
	for child in item_preview_root.get_children():
		child.queue_free()

	if item and item.item_scene:
		var instance = item.item_scene.instantiate()
		item_preview_root.add_child(instance)
