extends Node3D
class_name DelayedHitscanBullet

const BULLET_VELOCITY := 20.0
const CRIT_MULTIPLIER := 2.0

var start_position: Vector3
var destination: Vector3
var direction: Vector3
var traveled_distance: float = 0.0
var damage: int = 0
var hit_targets: Array[int] = []

@onready var raycast := $RayCast3D
@onready var mesh := $MeshInstance3D

func _ready() -> void:
	raycast.enabled = true
	print_debug("Bullet ready: ", self)


func setup(start: Vector3, dest: Vector3, dmg: int) -> void:
	global_position = start
	start_position = start
	destination = dest
	direction = (destination - start_position).normalized()
	damage = dmg
	print_debug("Bullet setup: start=", start, " dest=", dest, " dmg=", dmg)


func _process(delta: float) -> void:
	var step = BULLET_VELOCITY * delta
	traveled_distance += step

	# Move the bullet
	global_position = start_position + direction * traveled_distance

	# Update raycast tip in local space
	raycast.target_position = raycast.to_local(global_position + direction * step)
	raycast.force_raycast_update()

	# Check collision
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target:
			_handle_hit(target)
			queue_free()


func _handle_hit(target: Object) -> void:
	if not target:
		return

	var id = target.get_instance_id()
	if id in hit_targets:
		return
	hit_targets.append(id)

	# Bullet decal
	var bullet_hole = preload("res://effects/bullet_decal.tscn").instantiate()
	target.add_child(bullet_hole)
	bullet_hole.global_transform.origin = raycast.get_collision_point()
	bullet_hole.look_at(
		raycast.get_collision_point() + raycast.get_collision_normal(),
		Vector3.UP
	)

	# Physics impulse
	var force_dir = -raycast.get_collision_normal()
	var force_mag = damage * 34.90
	if target is RigidBody3D:
		target.apply_impulse(
			raycast.get_collision_point() - target.global_position,
			force_dir * force_mag
		)
	elif target is PhysicalBone3D:
		target.apply_central_impulse(force_dir * force_mag)

	# Crit & damage
	var crit = target.is_in_group("crit_hurtbox")
	var enemy = AdvancedCharacter.find_enemy_root(target)
	if enemy:
		var multiplier = CRIT_MULTIPLIER if crit else 1.0
		enemy.change_health(-(damage * multiplier))

		if "hit_sound" in enemy and enemy is not Player:
			if crit:
				enemy.play_sound("res://assets/critical-hit-sounds-effect.mp3")
			else:
				enemy.play_sound("res://assets/tf2_hitsound.mp3")
