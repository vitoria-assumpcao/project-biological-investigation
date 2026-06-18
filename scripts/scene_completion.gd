extends Node
## Attach this to a Node in any investigation scene (e.g. as a child of the
## scene's root). Watches ClueManager and automatically triggers a closing
## dialogue line once all of this scene's clues have been collected.
##
## Configure the clue id prefix used in THIS scene (e.g. "uti_") and how many
## clues are expected — matches the same convention used by hud.gd.

## Prefix used by this scene's clue ids (e.g. "uti_", "lab_", "dorm_")
@export var scene_clue_prefix: String = ""

## How many real clues this scene has (matches hud.gd's CLUES_PER_SCENE)
@export var clues_required: int = 3

## Path to the .dialogue resource for the closing line
@export_file("*.dialogue") var dialogue_file: String

## Which title inside the .dialogue file to play once all clues are collected
@export var dialogue_title: String = "conclusao"

## Optional small extra delay AFTER the current dialogue line finishes,
## before showing the closing dialogue (purely cosmetic pacing).
@export var delay_seconds: float = 0.4

var _already_triggered: bool = false
var _pending: bool = false
var _dialogue_currently_running: bool = false


func _ready() -> void:
	ClueManager.clue_added.connect(_on_clue_added)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _on_dialogue_started(_resource: DialogueResource) -> void:
	_dialogue_currently_running = true


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	_dialogue_currently_running = false


func _on_clue_added(_clue_id: String, _clue_label: String) -> void:
	if _already_triggered or _pending:
		return
	if _count_scene_clues() < clues_required:
		return

	_pending = true
	_wait_for_current_dialogue_then_show()


## The clue's own dialogue line (e.g. "duto" or "prontuario") is usually
## about to start when this signal fires, since add_clue() runs BEFORE
## show_dialogue_balloon() in interactable.gd — meaning dialogue_started
## for that line hasn't fired yet at this exact instant. We wait one frame
## to let that call happen first, then check if a dialogue is running.
func _wait_for_current_dialogue_then_show() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

	if _dialogue_currently_running:
		await DialogueManager.dialogue_ended

	if delay_seconds > 0.0:
		await get_tree().create_timer(delay_seconds).timeout

	_already_triggered = true
	_pending = false
	_show_closing_dialogue()


func _show_closing_dialogue() -> void:
	if dialogue_file == "":
		push_warning("SceneCompletion on '%s' has no dialogue_file set." % name)
		return

	var resource: DialogueResource = load(dialogue_file)
	DialogueManager.show_dialogue_balloon(resource, dialogue_title)


func _count_scene_clues() -> int:
	if scene_clue_prefix == "":
		return ClueManager.count()
	var n := 0
	for clue_id in ClueManager.collected.keys():
		if clue_id.begins_with(scene_clue_prefix):
			n += 1
	return n
