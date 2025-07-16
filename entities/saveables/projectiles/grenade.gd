extends Saveable

var detonation_time_left := 3.5
@export var damage_radius := 5
@export var damage_amount := 20.0
@export var early_detonation_radius := 1.0  # Use a smaller radius for early detection
@onready var explosion := $Explosion

func _physics_process(delta: float) -> void:
	detonation_time_left -= delta
	
	if check_for_early_detonation():
		await explode()
		queue_free()
		return

	if detonation_time_left <= 0:
		await explode()
		queue_free()

func check_for_early_detonation() -> bool:
	var space_state = get_world_3d().direct_space_state
	var shape = SphereShape3D.new()
	shape.radius = early_detonation_radius

	var transform = Transform3D(Basis(), global_transform.origin)
	var shape_query = PhysicsShapeQueryParameters3D.new()
	shape_query.shape = shape
	shape_query.transform = transform
	shape_query.collide_with_bodies = true
	shape_query.collide_with_areas = true

	var results = space_state.intersect_shape(shape_query, 8)

	for result in results:
		var collider = result.get("collider")
		if collider != self and collider.has_method("change_health"):
			print("💢 Early detonation triggered by:", collider.name)
			return true
	return false

func explode():
	print("💥 Boom!")
	var space_state = get_world_3d().direct_space_state
	var shape = SphereShape3D.new()
	shape.radius = damage_radius

	var transform = Transform3D(Basis(), global_transform.origin)
	var shape_query = PhysicsShapeQueryParameters3D.new()
	shape_query.shape = shape
	shape_query.transform = transform
	shape_query.collide_with_bodies = true
	shape_query.collide_with_areas = true

	var results = space_state.intersect_shape(shape_query, 32)

	for result in results:
		var collider = result.get("collider")
		if collider != self and collider.has_method("change_health"):
			print("Damaging:", collider.name)
			collider.change_health(-damage_amount)
	explosion.show()
	await explosion.explode()
	queue_free()
