extends StaticInteractable
class_name EnrichObject

func interact(player):
	if player.has_method("_change_wealth"):
		player._change_wealth(10)
