extends "res://scripts/interactable_base.gd"
## Interactable variant that opens the Credits screen after the dialogue ends.
## Used specifically on Iolanda in the epilogue scene.

@export_file("*.dialogue") var dialogue_file: String
@export var dialogue_title: String = "start"
@export var one_shot: bool = true

var _already_triggered: bool = false


func _trigger() -> void:
	if one_shot and _already_triggered:
		return
	_already_triggered = true

	if dialogue_file == "":
		push_warning("InteractableWithCredits '%s' has no dialogue_file set." % name)
		return

	var resource: DialogueResource = load(dialogue_file)
	DialogueManager.show_dialogue_balloon(resource, dialogue_title)
	await DialogueManager.dialogue_ended
	await Transition.fade_to_black()
	Credits.open()
	await Transition.fade_in_from_black()
