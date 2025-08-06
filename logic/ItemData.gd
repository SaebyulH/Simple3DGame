extends Resource
class_name ItemData


enum ItemType {RIFLE, PISTOL, MISC}
#enum AmmoType {REVOLVER_AMMO, SNIPER_AMMO}
enum ShootingMode {AUTO, SEMI_AUTO, SAFETY}
enum ShootingType {HITSCAN, PROJECTILE}
# Data stats
@export var item_type: ItemType 
@export var display_name: String
@export var mass: float
@export var value: float # This will be the standardized value which may be used to calculate vendor prices 

# Combat stats
# This can apply to even non-weapon items
@export var uses_ammo: bool
@export var ammo_type: AmmoData
@export var mag_size: int

@export var shooting_mode : ShootingMode
@export var shooting_type : ShootingType

@export var initial_shooting_delay : float # How long to shoot each bullet BEFORE pressing button
@export var between_shooting_delay: float  # how long added AFTER each bullet


@export var hitscan_range: float
@export var damage: int

# Visual stats
@export var scene_path: String
@export var view_model: PackedScene  # New field to store the item's 3D mesh
@export var projectile_path: String
@export var sound_path: String
@export var animation_name: String

func _to_string() -> String:
	var text := "Item: %s\n" % display_name
	text += "  Type: %s\n" % ItemType.keys()[item_type]
	text += "  Mass: %.1f\n" % mass
	text += "  Value: %.1f\n" % value

	text += "Combat:\n"
	text += "  Uses Ammo: %s\n" % ("Yes" if uses_ammo else "No")
	if uses_ammo:
		text += "  Ammo Type: %s\n" % (ammo_type.display_name if ammo_type else "None")
		text += "  Magazine Size: %d\n" % mag_size
	text += "  Shooting Mode: %s\n" % ShootingMode.keys()[shooting_mode]
	text += "  Shooting Type: %s\n" % ShootingType.keys()[shooting_type]
	text += "  Initial Delay: %.2f s\n" % initial_shooting_delay
	text += "  Between Shots Delay: %.2f s\n" % between_shooting_delay
	text += "  Range: %.1f\n" % hitscan_range
	text += "  Damage: %d\n" % damage

	text += "Visuals:\n"
	text += "  Scene Path: %s\n" % scene_path
	text += "  View Model: %s\n" % (view_model.resource_path if view_model else "None")
	text += "  Projectile Path: %s\n" % projectile_path
	text += "  Sound Path: %s\n" % sound_path
	text += "  Animation: %s\n" % animation_name

	return text
