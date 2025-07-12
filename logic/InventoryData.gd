extends Resource
class_name InventoryData

# Inventory stats
@export var max_mass: float = 100.0
@export var current_index: int = -1

# Actual inventory
@export var items: Array[ItemData] = []

func get_size():
	return items.size()

func set_current_index(index: int) -> bool:
	if index == -1:
		current_index = -1 # Uneqippped		
	if index >= 0 and index < items.size():
		current_index = index
		
		# Cannot assign greater
		clamp(current_index, 0, get_size() - 1)
		return true
	return false
	
func get_current_item() -> ItemData:
	if current_index >= 0:
		return items[current_index]
	return null
	
func add_item(item_data: ItemData) -> bool:
	if(item_data.mass + total_mass() > max_mass):
		print("too massive, cannot be added")
		return false
	else:
		items.append(item_data)
	if current_index == -1:
		current_index = 0
	return true

func remove_current_item() -> ItemData:
	if current_index >= 0:
		var item = items[current_index]
		items.remove_at(current_index)
		current_index -= 1
		return item
	return null
	
func move_item_at_to(index: int, other_inventory: InventoryData):
	if (index >= 0 and index < items.size() 
	and not(get_current_item().mass + other_inventory.total_mass() > other_inventory.max_mass)):
		var item = remove_current_item()
		if item == null:
			return false
		else:
			return other_inventory.add_item(item)
	return false
	
func total_mass() -> float:
	var total := 0.0
	for i in items:
		total += i.mass
	return total
