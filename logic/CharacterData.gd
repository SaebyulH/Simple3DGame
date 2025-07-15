extends Resource
class_name CharacterData

@export var speed := 5.0

@export var jump_force := 5.0
@export var can_move := true

@export var health := 100
@export var max_health := 100
@export var display_name := "Default Character"

@export var wealth := 0

func change_health(amount: int):
	if health < 0:
		print("health unchanged, " + display_name +" is already dead")
	elif health + amount > max_health:
		print("health unchanged, " + display_name +"max health already reached")
	else:
		health += amount
		var status = "healed" if (amount >= 0) else "damaged"
		print(display_name + status + " by " + str(abs(amount)) + " HP.")
		if health < 0:
			health = 0
			print(display_name + " is now dead")
		elif health + amount > max_health:
			health = max_health
			print(display_name + "max health reached")
