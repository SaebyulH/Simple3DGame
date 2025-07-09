extends Resource
class_name PlayerData

# Physical stats
@export var position: Vector3
@export var velocity: Vector3
@export var body_rotation_y: float
@export var head_rotation_x: float

@export var speed := 5.0
@export var mouse_sensitivity := 0.003
@export var gravity := 9.8
@export var jump_force := 5.0

@export var can_move := true
@export var move_mode : int

# Gameplay stats
@export var display_name : String
@export var health: int
@export var wealth: int
@export var inventory_data : InventoryData
@export var camera_mode : int

# Misc stats
@export var time_elapsed: float
