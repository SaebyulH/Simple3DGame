extends PickupObject

func _ready():
	super()
	setup_item_data(ItemFactory.create_scrap_metal())

func get_save_data() -> Dictionary:
	return super()

func apply_save_data(data: Dictionary) -> void:
	super(data)
