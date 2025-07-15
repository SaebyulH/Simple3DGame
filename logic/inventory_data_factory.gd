extends Node

func create_default_inventory_data() -> InventoryData:
	var inventory_data = InventoryData.new()
	inventory_data.max_mass = 100.0
	inventory_data.current_index = -1
	inventory_data.item_mode = InventoryData.ItemMode.INACTIVE
	inventory_data.items = [] as Array[ItemData]  # Already typed in class
	inventory_data.ammo_boxes = [] as Array[AmmoData]
	return inventory_data


func create_player_inventory_data() -> InventoryData:
	var inventory_data = InventoryData.new()
	inventory_data.max_mass = 100000000.0
	inventory_data.current_index = -1
	inventory_data.item_mode = InventoryData.ItemMode.INACTIVE
	inventory_data.items = [] as Array[ItemData]
	inventory_data.ammo_boxes = [] as Array[AmmoData] 

	inventory_data.add_item(ItemFactory.create_scrap_metal())
	inventory_data.ammo_boxes.append(AmmoFactory.create_revolver_ammo(240))
	inventory_data.ammo_boxes.append(AmmoFactory.create_rifle_ammo(120))
	
	return inventory_data


func create_merchant_inventory_data() -> InventoryData:
	var inventory_data = InventoryData.new()
	inventory_data.max_mass = 10000.0
	inventory_data.current_index = -1
	inventory_data.item_mode = InventoryData.ItemMode.INACTIVE
	inventory_data.items = [] as Array[ItemData]
	inventory_data.ammo_boxes = [] as Array[AmmoData] 

	for i in range(6):
		inventory_data.add_item(ItemFactory.create_scrap_metal())

	inventory_data.ammo_boxes.append(AmmoFactory.create_revolver_ammo(24))
	return inventory_data


func create_basic_enemy_inventory_data() -> InventoryData:
	var inventory_data = InventoryData.new()
	inventory_data.max_mass = 1000.0
	inventory_data.current_index = -1
	inventory_data.item_mode = InventoryData.ItemMode.INACTIVE
	inventory_data.items = [] as Array[ItemData]
	inventory_data.ammo_boxes = [] as Array[AmmoData] 

	for i in range(7):
		inventory_data.add_item(ItemFactory.create_scrap_metal())
	inventory_data.add_item(ItemFactory.create_shit_rifle())
	#inventory_data.ammo_boxes.append(AmmoFactory.create_revolver_ammo(14))
	return inventory_data


func create_armed_enemy_inventory_data() -> InventoryData:
	var inventory_data = InventoryData.new()
	inventory_data.max_mass = 100.0
	inventory_data.current_index = -1
	inventory_data.item_mode = InventoryData.ItemMode.INACTIVE
	inventory_data.items = [] as Array[ItemData]
	inventory_data.ammo_boxes = [] as Array[AmmoData] 

	inventory_data.add_item(ItemFactory.create_shit_pistol())
	inventory_data.ammo_boxes.append(AmmoFactory.create_revolver_ammo(600))
	
	return inventory_data
