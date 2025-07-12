extends SaveableCharacterBody3D
class_name CrabEnemy

@export var display_name:= "Stalker Crab"
@onready var player: Node = get_tree().get_root().get_node("Main/Player")  # Adjust this path as needed


@export var max_speed: float = 3.0
@export var current_health = 100
@export var max_health = 100
@export var damage_anim_duration: float = 1.0
#@export var being_damaged := false

var damage_timer := 0.0  # seconds

func _ready():
	super()
	scene_path = "res://entities/saveable_character_bodies/old_npcs/crab_enemy/crab_enemy.tscn"


func change_health(amount: float) -> void:
	current_health = clamp(current_health + amount, 0, max_health)

	#if amount < 0:
		#being_damaged = true
		#damage_timer = damage_anim_duration
		#print("🦀 Crab is being damaged")
		#being_damaged = false
		

	if current_health <= 0:
		#visible = false
		#set_physics_process(false)
		#set_process(false)
		#$CollisionShape3D.disabled = true
		queue_free()


func _physics_process(delta):

	if not player:
		return
	
	var to_player = player.global_transform.origin - global_transform.origin
	to_player.y = 0

	var distance = to_player.length()
	if distance > 0.1:
		var direction = to_player.normalized()
		velocity = direction * max_speed
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()

func get_save_data() -> Dictionary:
	var data = super()
	data[current_health] = current_health
	return data

func apply_save_data(data: Dictionary) -> void:
	super(data)
	if data.has("current_health"):
		current_health = data["current_health"]
