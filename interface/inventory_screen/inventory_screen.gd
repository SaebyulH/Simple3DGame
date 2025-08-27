extends CanvasLayer
@onready var inventory_panel := $MarginContainer/VBoxContainer2/InventoryPanel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	#update_header()
	
func update():
	inventory_panel.update()
	#update_header()
	
