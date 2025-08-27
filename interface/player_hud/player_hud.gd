extends CanvasLayer
class_name PlayerHUD

@onready var player_stats_label := $MarginContainer/VBoxContainer/PlayerStatsLabel
@onready var object_name_label := $CenterContainer/VBoxContainer/ObjectNameLabel
@onready var interact_prompt_label := $CenterContainer/VBoxContainer/InteractPromptLabel
@onready var inventory_list := $RightInventoryContainer/InventoryList

@onready var trade_prompt_label := $CenterContainer/VBoxContainer/TradePromptLabel

@onready var enemy_name_label := $MarginContainer2/VBoxContainer/EnemyName
@onready var enemy_health_label := $MarginContainer2/VBoxContainer/EnemyHealth
@onready var ammo_label := $MarginContainer3/VBoxContainer/AmmoLabel

@onready var blood_border: TextureRect = $TextureRect
@onready var health_bar := $HealthBarContainer/HealthBar

@onready var player := get_tree().root.get_node("Main/Saveables/Player")

func update_ammo_label(inventory_data: InventoryData):
	if inventory_data.get_current_item() and inventory_data.get_current_item().uses_ammo:
		ammo_label.text = "Ammo\n" + str(inventory_data.get_current_weapon_ammo_count())
	else:
		ammo_label.text = "Does not use ammo"
		



func update_inventory_data(inventory_data: InventoryData):
	for child in inventory_list.get_children():
		child.queue_free()

	for i in inventory_data.items.size():
		var item = inventory_data.items[i]
		var label = Label.new()
		label.text = item.display_name
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		# Highlight current item in red
		if i == inventory_data.current_index:
			label.add_theme_color_override("font_color", Color.RED)
		else:
			label.add_theme_color_override("font_color", Color.WHITE)

		inventory_list.add_child(label)


func show_enemy_stats(enemy: SaveableCharacterBody3D):
	if "display_name" in enemy.character_data:
		enemy_name_label.show()
		enemy_name_label.text = enemy.character_data.display_name
	if "health" in enemy.character_data and "max_health" in enemy.character_data:
		enemy_health_label.show()
		enemy_health_label.text = str("Health: " + str(enemy.character_data.health) + "/" + str(enemy.character_data.max_health))

func hide_enemy_stats():
	enemy_name_label.hide()
	enemy_health_label.hide()



func _ready() -> void:
	hide_interactable_ui()
	hide_tradeable_ui()
	update_ammo_label(player.inventory_data)

func update_player_stats(display_name: String):
	player_stats_label.text = player.character_data.to_string() + "\nInaccuarcy: " + str(player.inaccuracy)

	
	
	
	var health :int= player.character_data.health
	var max_health :int= player.character_data.max_health
	var health_ratio := float(health) / max_health

	# Update blood border
	var opacity := 0.0
	if health_ratio <= 0.65:
		opacity = clamp((0.65 - health_ratio) / 0.4, 0.0, 1.0)
	var color := blood_border.self_modulate
	color.a = opacity
	blood_border.self_modulate = color

	# Update health bar
	health_bar.value = health
	health_bar.max_value = max_health




func show_interactable_name(display_name: String, verb: String):
	object_name_label.text = display_name
	object_name_label.visible = true
	interact_prompt_label.text = verb + ": [E]"
	interact_prompt_label.visible = true

func hide_interactable_ui():
	object_name_label.visible = false
	interact_prompt_label.visible = false


func show_tradeable_prompt():
	#object_name_label.text = name
	#object_name_label.visible = true
	trade_prompt_label.text = "Trade: [T]"
	trade_prompt_label.visible = true

func hide_tradeable_ui():
	#object_name_label.visible = false
	trade_prompt_label.visible = false
