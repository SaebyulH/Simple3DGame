extends RigidBody3D
class_name HealthObject

@export var max_health: float = 100.0
var current_health: float

@onready var mesh_instance: MeshInstance3D = $UploadsFiles734240Skeleton

func _ready():
	current_health = max_health
	ensure_unique_material()
	update_color()

func change_health(amount: float):
	current_health = clamp(current_health + amount, 0, max_health)
	update_color()
	
	if current_health <= 0:
		queue_free()

func ensure_unique_material():
	var material = mesh_instance.get_active_material(0)
	if material:
		var new_material = material.duplicate()
		mesh_instance.set_surface_override_material(0, new_material)
	else:
		# Create a fallback material if none exists
		var fallback_material = StandardMaterial3D.new()
		mesh_instance.set_surface_override_material(0, fallback_material)

func update_color():
	var health_ratio = current_health / max_health
	var color = Color(1.0 - health_ratio, health_ratio, 0.0)  # red to green

	var material = mesh_instance.get_active_material(0)
	if material is StandardMaterial3D:
		material.albedo_color = color
