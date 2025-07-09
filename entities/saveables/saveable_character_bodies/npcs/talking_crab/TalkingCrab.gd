extends SaveableCharacterBody3D
class_name TalkingCrab

@export var current_health = 100
@export var max_health = 100
@export var damage_anim_duration: float = 1.0
@onready var processor: Node = get_tree().get_root().get_node("Main/Processor")  # Adjust this path as needed


var lie := false
#@export var being_damaged := false
var damage_timer := 0.0  # seconds
@onready var player: Node = get_tree().get_root().get_node("Main/Player")  # Adjust this path as needed

func _ready() -> void:
	Dialogic.signal_event.connect(DialogicSignal)

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

func interact(_player):  # You can keep this parameter if you want, but it's unused now
	if(lie):
		start_dialogue("crab_conversation_2")
	else: 
		start_dialogue("crab_conversation")
	

func DialogicSignal(arg: String):
	if arg == "give_money":
		print("money recieved")
		player.change_wealth(3000)
		lie = true
	if arg == "fuck_you":
		player.velocity.y = 10000
	if arg == "exit":
		print("dialogue exited")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		player.can_move = true
		processor.in_dialogue = false
		
func start_dialogue(arg: String):
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Dialogic.start(arg)

	player.can_move = false
	processor.in_dialogue = true
	

func get_save_data() -> Dictionary:
	return {
		"save_id": save_id,
		"position": global_transform.origin,
		"visible": visible,
		"velocity": velocity,
		"current_health" : current_health,
		"lie" : lie,
	}

func apply_save_data(data: Dictionary) -> void:
	if data.has("position"):
		global_transform.origin = data["position"]
	if data.has("visible"):
		visible = data["visible"]
	if data.has("velocity"):
		velocity = data["velocity"]
	if data.has("current_health"):
		current_health = data["current_health"]	
	if data.has("lie"):
		lie = data["lie"]	
