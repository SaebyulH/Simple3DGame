extends PickupObject

func _ready():
	super()
	setup_item_data(ItemDataFactory.create_crowbar())

func get_save_data() -> Dictionary:
	return super()

func apply_save_data(data: Dictionary) -> void:
	super(data)
