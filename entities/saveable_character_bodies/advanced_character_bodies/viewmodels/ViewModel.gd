extends Node3D
class_name ViewModel

@onready var anim_player : AnimationPlayer

func _ready() -> void:
	if find_animation_player(self):
		
		anim_player = find_animation_player(self)
		print(name, ": ANIM PLAYER SET AS", anim_player.name)
		
	else:
		print(name, ": ANIM PLAYER NOT FOUND")

func find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node

	for child in node.get_children():
		if child is Node:
			var found = find_animation_player(child)
			if found:
				return found
				print(name, " found anim player")
	return null

func play_animation(anim_name: String):
	if anim_player and anim_player.has_animation(anim_name):
		print(name, ": playing anim", anim_name,  "in VIEWMODEL")
		anim_player.play(anim_name)
	else:
		print(name, ": ERROR FUCKKKKKKKKKKKKKKKKKKKKK")
