extends Resource
class_name CharacterData

@export var speed :float= 5.0
@export var jump_force :float= 5.0
@export var can_move :bool= true
@export var health :int= 100
@export var max_health :int= 100
@export var display_name :String= "Default Character"
@export var wealth :int= 0

func change_health(amount: int):
	if health < 0:
		print("health unchanged, " + display_name +" is already dead")
	elif health >= max_health and amount >=0:
		print("health cannot be increased, " + display_name +"max health already reached")
	else:
		health += amount
		var status = "healed" if (amount >= 0) else "damaged"
		print(display_name + status + " by " + str(abs(amount)) + " HP.")
		
		
		if health < 0:
			health = 0
			print(display_name + " is now dead")
		elif health > max_health:
			health = max_health
			print(display_name + "overheal removed. max health reached")
			
func _to_string() -> String:
	var text := "Character: %s\n" % display_name
	text += "Can Move: %s\n" % (can_move if can_move else "No")
	text += "Speed: %.2f\n" % speed
	text += "Jump Force: %.2f\n" % jump_force
	text += "Health: %d / %d\n" % [health, max_health]
	text += "Wealth: %d\n" % wealth
	text += "Status: %s\n" % ("Alive" if health > 0 else "Dead")
	return text
