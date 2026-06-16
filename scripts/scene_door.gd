extends Area2D
## Attach to an Area2D that should change scene when clicked, with no dialogue
## involved — e.g. a door leading from one location to another.

## Scene to load when this object is clicked (e.g. res://Scenes/UTI.tscn)
@export_file("*.tscn") var next_scene: String

## Optional: requires this clue to have been collected before the door works.
## Leave empty to allow entering at any time.
@export var requires_clue: String = ""

## Optional: dialogue file + title to show if requires_clue isn't met yet
## (e.g. a small "not ready yet" line). Leave dialogue_file empty to do nothing.
@export_file("*.dialogue") var locked_dialogue_file: String = ""
@export var locked_dialogue_title: String = "locked"


func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_trigger()


func _trigger() -> void:
	if requires_clue != "" and not ClueManager.has_clue(requires_clue):
		if locked_dialogue_file != "":
			var resource: DialogueResource = load(locked_dialogue_file)
			DialogueManager.show_dialogue_balloon(resource, locked_dialogue_title)
		return

	if next_scene == "":
		push_warning("SceneDoor '%s' has no next_scene set." % name)
		return

	Transition.fade_to_scene(next_scene)


func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
