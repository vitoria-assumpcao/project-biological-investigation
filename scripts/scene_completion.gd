extends Node
## Attach this to a Node in any investigation scene. Watches ClueManager and
## triggers a closing dialogue once all of this scene's clues are collected.
## Uses a Timer-based approach to avoid coroutine accumulation.

@export var scene_clue_prefix: String = ""
@export var clues_required: int = 3
@export_file("*.dialogue") var dialogue_file: String
@export var dialogue_title: String = "conclusao"
@export var delay_seconds: float = 0.4
@export var show_report_after: bool = false
@export var dialogue_title_after_report: String = ""

var _already_triggered: bool = false
var _pending: bool = false
var _check_timer: Timer


func _ready() -> void:
	ClueManager.clue_added.connect(_on_clue_added)
	_check_timer = Timer.new()
	_check_timer.wait_time = 0.1
	_check_timer.timeout.connect(_on_check_timer)
	add_child(_check_timer)


func _on_clue_added(_clue_id: String, _clue_label: String) -> void:
	if _already_triggered or _pending:
		return
	if _count_scene_clues() < clues_required:
		return
	_pending = true
	_check_timer.start()


func _on_check_timer() -> void:
	var balloon_active := _is_balloon_visible()
	if not balloon_active:
		_check_timer.stop()
		_trigger_closing_dialogue()


func _is_balloon_visible() -> bool:
	for child in get_tree().root.get_children():
		if "Balloon" in child.name and child.visible:
			return true
	if get_tree().current_scene != null:
		for child in get_tree().current_scene.get_children():
			if "Balloon" in child.name and child.visible:
				return true
	return false


func _trigger_closing_dialogue() -> void:
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

	if show_report_after:
		await DialogueManager.dialogue_ended
		Report.open()
		await Report.closed
		if dialogue_title_after_report != "":
			DialogueManager.show_dialogue_balloon(resource, dialogue_title_after_report)


func _count_scene_clues() -> int:
	if scene_clue_prefix == "":
		return ClueManager.count()
	var n := 0
	for clue_id in ClueManager.collected.keys():
		if clue_id.begins_with(scene_clue_prefix):
			n += 1
	return n
