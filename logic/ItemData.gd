extends Resource
class_name ItemData

# Data stats
#@export var item_type: ItemType 
@export var display_name: String
@export var mass: float
@export var value: float # This will be the standardized value which may be used to calculate vendor prices 

# Combat stats
# This can apply to even non-weapon items
@export var uses_ammo: bool
@export var ammo_type: AmmoData

@export var range: float
@export var damage: int

# Visual stats
@export var scene_path: String
@export var view_model: PackedScene  # New field to store the item's 3D mesh
