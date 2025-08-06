extends Resource
class_name InventoryData

# Inventory stats
@export var max_mass: float = 100.0
@export var current_index: int = -1

# Actual inventory
@export var items: Array[ItemData] = []
@export var ammo_boxes: Array[AmmoData] = []

func get_current_weapon_ammo_count():
	var current_item = get_current_item()
	for ammo in ammo_boxes:
		if ammo.display_name == current_item.ammo_type.display_name:
			return ammo.count
	return -1

func change_ammo_of_current_weapon(amount: int) -> bool:
	var current_item = get_current_item()		
	if current_item == null:
		return false

	if not current_item.uses_ammo:
		print("Current weapon does not use ammo, no ammo to add")
		return true

	for ammo in ammo_boxes:
		if ammo.display_name == current_item.ammo_type.display_name:
			if ammo.count + amount < 0:
				return false
				print("Not enough ammo. Would have negative ammo")
			ammo.count += amount
			return true
			print("ammo count change sucessful")

	print("No matching ammo found for: ", current_item.display_name, ". Cannot change ammo count")
	return false

func shoot_current_weapon() -> bool:
	var current_item = get_current_item()
	if current_item == null:
		return false

	if not current_item.uses_ammo:
		print("No ammo required, shoot sucessful")
		return true

	if change_ammo_of_current_weapon(-1):
		return true
	
	return false

func get_size():
	return items.size()

func set_current_index(index: int) -> bool:
	if index == -1:
		current_index = -1 # Uneqippped
		#item_mode = ItemMode.INACTIVE
		pass
	if index >= 0 and index < items.size():
		current_index = index
		
		# Cannot assign greater
		clamp(current_index, 0, get_size() - 1)
		return true
	return false

func change_current_index(amount: int) -> bool:
	var size = items.size()
	if size == 0:
		current_index = -1
		return false

	current_index = (current_index + amount) % size
	if current_index < 0:
		current_index += size  # Ensure it wraps correctly for negative values

	return true

func get_current_item() -> ItemData:
	if current_index >= 0 and current_index < items.size():
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
		if current_index == -1:
			if items.size() > 0:
				current_index = items.size() -1
			else:
				current_index = -1
				#item_mode = ItemMode.INACTIVE
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
