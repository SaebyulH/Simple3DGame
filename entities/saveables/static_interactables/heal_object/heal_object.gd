extends StaticInteractable
class_name HealObject

func interact(player):
	if player.has_method("_change_health"):
		player._change_health(10)
