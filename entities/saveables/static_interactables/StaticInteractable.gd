extends Node3D
class_name StaticInteractable

# This is a node intended to be used for something that the player can interact
# with but does not change it's own state in any way, th

@export var display_name: String = "Unnamed Object"

func interact(player):
	print("Interacted with ", display_name)
