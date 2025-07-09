extends Control

const UNPRESSED_COLOR := Color("ffffff")
const PRESSED_COLOR := Color("a32929")


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		print(event.as_text())
		
		
		
		#if (event.as_text() == "Shift+Ctrl"):
			#get_node("Ctrl").color = PRESSED_COLOR
			#get_node("Shift").color = PRESSED_COLOR
		#else:
			#get_node("Ctrl").color = UNPRESSED_COLOR
			#get_node("Shift").color = UNPRESSED_COLOR
		
		if (
			event.as_text() == "W" 
			or event.as_text() == "A" 
			or event.as_text() == "S" 
			or event.as_text() == "D"
			
			or event.as_text() == "Space"
			
			or event.as_text() == "Ctrl"
			
			or event.as_text() == "Shift"
			
		):
			if event.pressed:
				get_node(event.as_text()).color = PRESSED_COLOR
			else:
				get_node(event.as_text()).color = UNPRESSED_COLOR
		
