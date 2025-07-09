extends SaveableCharacterBody3D
class_name CrabEnemy

@export var player_path: NodePath  # Set this in the editor
@export var max_speed: float = 3.0
@export var current_health = 100
@export var max_health = 100
@export var damage_anim_duration: float = 1.0
#@export var being_damaged := false

var damage_timer := 0.0  # seconds



var player: Node3D = null

func _ready():
	super._ready()
	if has_node(player_path):
		player = get_node(player_path)
	else:
		push_error("🦀 CrabEnemy: Player not found at path: " + str(player_path))

func change_health(amount: float) -> void:
	current_health = clamp(current_health + amount, 0, max_health)

	#if amount < 0:
		#being_damaged = true
		#damage_timer = damage_anim_duration
		#print("🦀 Crab is being damaged")
		#being_damaged = false
		

	if current_health <= 0:
		visible = false
		set_physics_process(false)
		set_process(false)
		$CollisionShape3D.disabled = true


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
	return {
		"save_id": save_id,
		"position": global_transform.origin,
		"visible": visible,
		"velocity": velocity,
		"current_health" : current_health
	}

func apply_save_data(data: Dictionary) -> void:
	if data.has("position"):
		global_transform.origin = data["position"]
	if data.has("visible"):
		visible = data.visible
		if data.visible:
			
			set_physics_process(true)
			set_process(true)
			$CollisionShape3D.disabled = false
		else:
			set_physics_process(false)
			set_process(false)
			$CollisionShape3D.disabled = true
	if data.has("velocity"):
		velocity = data["velocity"]
	if data.has("current_health"):
		current_health = data["current_health"]	
