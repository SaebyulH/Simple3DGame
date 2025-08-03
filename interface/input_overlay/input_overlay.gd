extends Control

const UNPRESSED_COLOR := Color("ffffff")
const PRESSED_COLOR := Color("a32929")

const TRACKED_KEYS := [
	"W", "A", "S", "D", "Q", "E", "Space", "Ctrl", "Shift"
]

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var text := event.as_text()
		
		for key in TRACKED_KEYS:
			if key == text or (key in text and "+" in text):
				print("Overlay: ", key, " key pressed")
				var node := get_node_or_null(key)
				if node:
					node.color = PRESSED_COLOR if event.pressed else UNPRESSED_COLOR
