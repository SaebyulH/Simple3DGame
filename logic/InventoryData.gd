extends Resource
class_name InventoryData

# Inventory stats
@export var max_mass: float = 100.0
@export var current_index: int = -1
# Actual inventory
@export var items: Array[ItemData] = []

func add_item(item: ItemData):
	items.append(item)
	if current_index == -1:
		current_index = 0


func remove_item(item: ItemData):
	items.erase(item)

func total_mass() -> float:
	var total := 0.0
	for i in items:
		total += i.mass
	return total
