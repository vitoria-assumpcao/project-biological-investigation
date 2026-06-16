extends Area2D
## Generic interactable object. Attach this script to any Area2D that should
## open a dialogue balloon when clicked: ducts, charts, doors, NPCs, etc.
## Configure everything from the Inspector — no need to duplicate this script.

## Path to the .dialogue resource (e.g. res://dialogues/uti.dialogue)
@export_file("*.dialogue") var dialogue_file: String

## Which title/label inside the .dialogue file to start from (the line that starts with "~ title")
@export var dialogue_title: String = "start"

## Only allow interacting once (good for one-shot clues). Leave false for NPCs you can talk to repeatedly.
@export var one_shot: bool = false

## Optional: id used by ClueManager when this object should register a clue on first interaction
@export var clue_id: String = ""

## Optional: shown in the clue tray / UI when collected
@export var clue_label: String = ""

var _already_triggered: bool = false


func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_trigger()


func _trigger() -> void:
	if one_shot and _already_triggered:
		return
	_already_triggered = true

	if clue_id != "" and not ClueManager.has_clue(clue_id):
		ClueManager.add_clue(clue_id, clue_label)

	if dialogue_file == "":
		push_warning("Interactable '%s' has no dialogue_file set." % name)
		return

	var resource: DialogueResource = load(dialogue_file)
	DialogueManager.show_dialogue_balloon(resource, dialogue_title)


func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
