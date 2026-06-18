extends Node
## Attach this to a Node in any investigation scene. Watches ClueManager and
## triggers a closing dialogue once all of this scene's clues are collected.
## Uses a Timer-based approach instead of coroutines to avoid memory leaks.

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


func _on_clue_added(clue_id: String, _clue_label: String) -> void:
	print("[SceneCompletion] clue_added: ", clue_id, " | count: ", _count_scene_clues(), "/", clues_required)
	if _already_triggered or _pending:
		return
	if _count_scene_clues() < clues_required:
		return

	print("[SceneCompletion] threshold reached, waiting for balloon to close...")
	_pending = true
	# Start polling every 0.1s to check when the balloon disappears
	_check_timer.start()


func _on_check_timer() -> void:
	# Check if any balloon is currently visible in the scene tree.
	# ExampleBalloon (the balloon scene) is a CanvasLayer added to the tree
	# by DialogueManager while a dialogue is running and removed when done.
	var balloon_active := false
	for node in get_tree().get_nodes_in_group(""):
		pass  # dummy, just warming up get_tree()

	# DialogueManager adds the balloon as a child of the current scene or root.
	# We check if any node named "ExampleBalloon" (or containing "Balloon")
	# exists and is visible.
	var root := get_tree().root
	for child in root.get_children():
		if "Balloon" in child.name and child.visible:
			balloon_active = true
			break
	# Also check inside current scene
	if not balloon_active and get_tree().current_scene != null:
		for child in get_tree().current_scene.get_children():
			if "Balloon" in child.name and child.visible:
				balloon_active = true
				break

	print("[SceneCompletion] timer check | balloon_active=", balloon_active)

	if not balloon_active:
		_check_timer.stop()
		_trigger_closing_dialogue()


func _trigger_closing_dialogue() -> void:
	print("[SceneCompletion] balloon gone, triggering closing dialogue in ", delay_seconds, "s")
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
