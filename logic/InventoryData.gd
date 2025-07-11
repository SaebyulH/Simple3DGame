extends Resource
class_name InventoryData

# Inventory stats
@export var max_mass: float = 100.0
@export var current_index: int = -1
# Actual inventory
@export var items: Array[ItemData] = []
@export var dictionaries: Array[Dictionary] = []

func add_item(dictionary: Dictionary) -> bool:
	if dictionary.has("item_data"):
		var item = dictionary["item_data"]
		if(item.mass + total_mass() > max_mass):
			print("too massive, cannot be added")
			return false
		items.append(item)
		if current_index == -1:
			current_index = 0
		dictionaries.append(dictionary)
		return true
		
	return false
	print("dictionary has no item data")


func remove_current_item():
	items.remove_at(current_index)
	dictionaries.remove_at(current_index)

#func remove_item(item: ItemData):
	#items.erase(item)

func total_mass() -> float:
	var total := 0.0
	for i in items:
		total += i.mass
	return total
