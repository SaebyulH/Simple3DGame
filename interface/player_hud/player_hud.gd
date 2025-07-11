extends CanvasLayer
class_name PlayerHUD

@onready var display_name_label = $MarginContainer/VBoxContainer/DisplayNameLabel
@onready var time_label = $MarginContainer/VBoxContainer/TimeLabel
@onready var health_label = $MarginContainer/VBoxContainer/HealthLabel
@onready var wealth_label = $MarginContainer/VBoxContainer/WealthLabel
@onready var object_name_label = $CenterContainer/VBoxContainer/ObjectNameLabel
@onready var interact_prompt_label = $CenterContainer/VBoxContainer/InteractPromptLabel
@onready var inventory_list = $RightInventoryContainer/InventoryList


@onready var enemy_name_label = $MarginContainer2/VBoxContainer/EnemyName
@onready var enemy_health_label = $MarginContainer2/VBoxContainer/EnemyHealth


func update_inventory_data(inventory_data: InventoryData):
	for child in inventory_list.get_children():
		child.queue_free()

	for i in inventory_data.items.size():
		var item = inventory_data.items[i]
		var label = Label.new()
		label.text = format_item(item)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		# Highlight current item in red
		if i == inventory_data.current_index:
			label.add_theme_color_override("font_color", Color.RED)
		else:
			label.add_theme_color_override("font_color", Color.WHITE)

		inventory_list.add_child(label)


func show_enemy_stats(enemy: SaveableCharacterBody3D):
	
	
	if "display_name" in enemy:
		enemy_name_label.show()
		enemy_name_label.text = enemy.display_name
	if "current_health" in enemy and "max_health" in enemy:
		enemy_health_label.show()
		enemy_health_label.text = str("Health: " + str(enemy.current_health) + "/" + str(enemy.max_health))

func hide_enemy_stats():
	enemy_name_label.hide()
	enemy_health_label.hide()

func format_item(item: ItemData) -> String:
	var text = "%s\n" % item.display_name
	#text += "  Mass: %.1f\n" % item.mass
	#text += "  Value: %.1f\n" % item.value
	#if item.uses_ammo:
		#text += "  Ammo Type: %s\n" % (item.ammo_type.display_name if item.ammo_type else "None")
	#text += "  Range: %.1f\n" % item.range
	#text += "  Damage: %d\n" % item.damage
	#text += "  Health: %d\n" % item.health
	return text

func _ready() -> void:
	hide_interactable_ui()

func update_display_name(display_name: String):
	display_name_label.text = "Display Name: " + display_name

func update_health(health: int, max_health: int):
	health_label.text = "Health: %d / %d" % [health, max_health]


func update_wealth(wealth: int):
	wealth_label.text = "Wealth: " + str(wealth)

func update_time(time_elapsed: float):
	time_label.text = "Time: %.1f s" % time_elapsed

func show_interactable_name(name: String, verb: String):
	object_name_label.text = name
	object_name_label.visible = true
	interact_prompt_label.text = verb + ": [E]"
	interact_prompt_label.visible = true

func hide_interactable_ui():
	object_name_label.visible = false
	interact_prompt_label.visible = false
