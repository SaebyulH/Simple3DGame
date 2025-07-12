extends Node

func create_default_inventory_data() -> InventoryData:
	var inventory_data = InventoryData.new()
	inventory_data.max_mass= 100.0
	inventory_data.current_index = -1
	inventory_data.items = [] as Array[ItemData]
	return inventory_data

func create_player_inventory_data() -> InventoryData:
	var inventory_data = InventoryData.new()
	inventory_data.max_mass= 100.0
	inventory_data.current_index = -1
	inventory_data.items = [] as Array[ItemData]
	inventory_data.add_item(ItemFactory.create_scrap_metal())
	return inventory_data

func create_merchant_inventory_data() -> InventoryData:
	var inventory_data = InventoryData.new()
	inventory_data.max_mass= 10000.0
	inventory_data.current_index = -1
	inventory_data.items = [] as Array[ItemData]
	inventory_data.add_item(ItemFactory.create_scrap_metal())
	inventory_data.add_item(ItemFactory.create_scrap_metal())
	inventory_data.add_item(ItemFactory.create_scrap_metal())
	inventory_data.add_item(ItemFactory.create_scrap_metal())
	inventory_data.add_item(ItemFactory.create_scrap_metal())
	inventory_data.add_item(ItemFactory.create_scrap_metal())
	return inventory_data
