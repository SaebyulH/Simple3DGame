extends Node

#func change_camera(camera_name: String):
	#

func auto_camera(character_name: String):
	var rng = RandomNumberGenerator.new()
	var idk = rng.randf_range(0, 1)
	for character in get_tree().get_nodes_in_group("characters"):
		
		
		if character is AdvancedCharacter and character.dialogic_name == character_name:
			if(idk >= 0.5):
				character.set_selfie_cam()
				print("FOUND")
			else:
				character.interact_target.set_ots_cam()
				print("FOUND")
		print("NOT FOUND")

func change_selfie_cam(character_name: String):
	for character in get_tree().get_nodes_in_group("characters"):
		if character is AdvancedCharacter and character.dialogic_name == character_name:
			character.set_selfie_cam()
			print("FOUND")
		print("NOT FOUND")

func change_ots_cam(character_name: String):
	for character in get_tree().get_nodes_in_group("characters"):
		if character is AdvancedCharacter and character.dialogic_name == character_name:
			character.set_ots_cam()
			print("FOUND")
		print("NOT FOUND")

func reset_cam():
	var main_cam = get_tree().get_first_node_in_group("default_camera")
	if main_cam:
		main_cam.set_current(true)
