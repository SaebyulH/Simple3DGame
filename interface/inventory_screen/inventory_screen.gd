extends CanvasLayer
@onready var inventory_panel := $MarginContainer/VBoxContainer2/InventoryPanel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	#update_header()
	
func update():
	inventory_panel.update()
	#update_header()
	


func _on_inventory_pressed() -> void:
	
	pass # Replace with function body.


func _on_character_pressed() -> void:
	pass # Replace with function body.


func _on_journal_pressed() -> void:
	pass # Replace with function body.
