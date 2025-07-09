extends StaticInteractable
class_name DamageObject

func interact(player):
	if player.has_method("_change_health"):
		player._change_health(-10)
