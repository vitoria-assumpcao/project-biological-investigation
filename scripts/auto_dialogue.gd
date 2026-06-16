extends Node
## Attach this script to any Node in a scene that should automatically start
## a dialogue as soon as the scene loads — used for opening cutscenes like
## the prologue with Dra. Renata.

## Path to the .dialogue resource (e.g. res://dialogues/prologo.dialogue)
@export_file("*.dialogue") var dialogue_file: String

## Which title/label inside the .dialogue file to start from
@export var dialogue_title: String = "start"

## Small delay before the dialogue starts (in seconds). Useful to let the
## scene fade in or the camera settle before the balloon appears.
@export var start_delay: float = 0.5

## If set, automatically changes to this scene once this dialogue ends.
## Leave empty to do nothing on dialogue end (e.g. res://Scenes/Hospital.tscn).
@export_file("*.tscn") var next_scene: String = ""

var _resource: DialogueResource


func _ready() -> void:
	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout
	_start_dialogue()


func _start_dialogue() -> void:
	if dialogue_file == "":
		push_warning("AutoDialogue on '%s' has no dialogue_file set." % name)
		return

	_resource = load(dialogue_file)

	if next_scene != "":
		# Only react to OUR dialogue ending, in case other dialogues run elsewhere.
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	DialogueManager.show_dialogue_balloon(_resource, dialogue_title)


func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource != _resource:
		return
	DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)
	Transition.fade_to_scene(next_scene)
