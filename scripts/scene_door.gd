extends Area2D
## Attach to an Area2D that should change scene when clicked.
## Optionally requires clues to be collected before allowing passage,
## and can show a dialogue (and optionally a report screen) before transitioning.

@export_file("*.tscn") var next_scene: String = ""
@export var required_clue_count: int = 0
@export var required_clue_prefix: String = ""
@export_file("*.dialogue") var dialogue_file: String = ""
@export var dialogue_title: String = ""

## If true, opens the Report screen after the first dialogue finishes,
## then plays dialogue_title_after_report before transitioning.
@export var show_report_after: bool = false
@export var dialogue_title_after_report: String = ""

@export_file("*.dialogue") var locked_dialogue_file: String = ""
@export var locked_dialogue_title: String = "locked"

var _in_progress: bool = false


func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_trigger()


func _trigger() -> void:
	if _in_progress:
		return

	if required_clue_count > 0 and _count_clues() < required_clue_count:
		if locked_dialogue_file != "":
			var resource: DialogueResource = load(locked_dialogue_file)
			DialogueManager.show_dialogue_balloon(resource, locked_dialogue_title)
		return

	_in_progress = true

	if dialogue_file != "" and dialogue_title != "":
		var resource: DialogueResource = load(dialogue_file)
		DialogueManager.show_dialogue_balloon(resource, dialogue_title)
		await DialogueManager.dialogue_ended

		if show_report_after:
			Report.open()
			await Report.closed
			if dialogue_title_after_report != "":
				DialogueManager.show_dialogue_balloon(resource, dialogue_title_after_report)
				await DialogueManager.dialogue_ended

	if next_scene == "":
		push_warning("SceneDoor '%s' has no next_scene set." % name)
		_in_progress = false
		return

	Transition.fade_to_scene(next_scene)


func _count_clues() -> int:
	if required_clue_prefix == "":
		return ClueManager.count()
	var n := 0
	for clue_id in ClueManager.collected.keys():
		if clue_id.begins_with(required_clue_prefix):
			n += 1
	return n


func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
