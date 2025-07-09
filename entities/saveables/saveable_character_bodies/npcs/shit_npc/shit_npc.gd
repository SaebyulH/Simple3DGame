extends SaveableCharacterBody3D
class_name ShitNPCSkin

@export var max_health: float = 100.0
var current_health: float

@export var speed: float = 2.0
@export var idle_time_range: Vector2 = Vector2(2.0, 5.0)
@export var move_time_range: Vector2 = Vector2(2.0, 5.0)
@export var move_area_radius: float = 10.0

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var random = RandomNumberGenerator.new()

var state_timer: float = 0.0
var moving: bool = false
var target_direction: Vector3 = Vector3.ZERO
var origin_position: Vector3

var anim_locked: bool = false
var anim_conditions := ["Idle", "Run", "TakeDamage"]

func _ready():
	super._ready()  # Adds to group
	current_health = max_health
	anim_tree.active = true
	random.randomize()
	origin_position = global_transform.origin
	set_anim_condition("Idle")
	choose_new_action()

func _physics_process(delta):
	if not anim_locked:
		set_anim_condition("Run" if velocity.length() > 0.1 else "Idle")

	state_timer -= delta
	if state_timer <= 0.0:
		choose_new_action()

	if moving:
		velocity.x = target_direction.x * speed
		velocity.z = target_direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func choose_new_action():
	moving = !moving
	state_timer = random.randf_range(
		idle_time_range.x if !moving else move_time_range.x,
		idle_time_range.y if !moving else move_time_range.y
	)

	if moving:
		var angle = random.randf_range(0, TAU)
		var distance = random.randf_range(0, move_area_radius)
		var new_pos = origin_position + Vector3(cos(angle), 0, sin(angle)) * distance
		target_direction = (new_pos - global_transform.origin).normalized()

func change_health(amount: float) -> void:
	current_health = clamp(current_health + amount, 0, max_health)

	if amount < 0:
		await play_damage_animation()

	if current_health <= 0:
		visible = false
		set_physics_process(false)
		set_process(false)
		$CollisionShape3D.disabled = true

func set_anim_condition(condition_name: String) -> void:
	for name in anim_conditions:
		anim_tree.set("parameters/conditions/" + name, name == condition_name)

func play_damage_animation() -> void:
	anim_locked = true
	set_anim_condition("TakeDamage")
	await get_tree().create_timer(0.7).timeout
	anim_locked = false

func get_save_data() -> Dictionary:
	var data = super()
	data["health"] = current_health
	data["moving"] = moving
	return data

func apply_save_data(data: Dictionary):
	super(data)
	if data.has("health"):
		current_health = data["health"]
	if data.has("moving"):
		moving = data["moving"]
