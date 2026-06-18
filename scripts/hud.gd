extends CanvasLayer
## Persistent HUD showing the list of clues collected so far, top-right corner.
## Attach this as an Autoload (Project Settings > Globals > Autoload) named "Hud",
## OR add it as a node directly inside each playable scene — both work since
## it just listens to ClueManager's signal and rebuilds its own list.

@export var corner_margin: int = 4
@export var font_size: int = 5
@export var max_visible_clues: int = 3

var _container: VBoxContainer
var _title_label: Label

## Every scene has exactly 3 real clues. The HUD counts only the clues whose
## id starts with the current scene's prefix (e.g. "uti_", "lab_", "dorm_"),
## so switching scenes doesn't carry over previous scenes' counts.
const CLUES_PER_SCENE: int = 3

## Maps a scene file name (get_tree().current_scene.scene_file_path's file
## name, without extension) to the clue_id prefix used in that scene.
## Add one entry per scene as you build them.
const SCENE_PREFIXES: Dictionary = {
	"UTI": "uti_",
	"Laboratorio": "lab_",
	"Dormitorio": "dorm_",
}


func _current_scene_prefix() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return ""
	var scene_name: String = scene.scene_file_path.get_file().get_basename()
	return SCENE_PREFIXES.get(scene_name, "")


func _count_clues_for_current_scene() -> int:
	var prefix: String = _current_scene_prefix()
	if prefix == "":
		return ClueManager.count()  # fallback: scene not mapped, count everything
	var n := 0
	for clue_id in ClueManager.collected.keys():
		if clue_id.begins_with(prefix):
			n += 1
	return n


func _ready() -> void:
	layer = 50  # below Transition (128), above gameplay

	var root_control := Control.new()
	root_control.anchor_left = 0.0
	root_control.anchor_right = 0.0
	root_control.anchor_top = 0.0
	root_control.anchor_bottom = 0.0
	root_control.offset_left = corner_margin
	root_control.offset_right = corner_margin + 90
	root_control.offset_top = corner_margin
	root_control.offset_bottom = corner_margin + 36
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_control.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 3)
	margin.add_theme_constant_override("margin_right", 3)
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_bottom", 2)
	panel.add_child(margin)

	_container = VBoxContainer.new()
	_container.alignment = BoxContainer.ALIGNMENT_BEGIN
	margin.add_child(_container)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", font_size)
	_container.add_child(_title_label)

	ClueManager.clue_added.connect(_on_clue_added)
	_rebuild()


func _rebuild() -> void:
	# Clear all clue rows except the title (first child).
	for i in range(_container.get_child_count() - 1, 0, -1):
		_container.get_child(i).queue_free()

	var count: int = _count_clues_for_current_scene()
	_title_label.text = "Pistas: %d/%d" % [count, CLUES_PER_SCENE]

	var prefix: String = _current_scene_prefix()
	var keys: Array = []
	for clue_id in ClueManager.collected.keys():
		if prefix == "" or clue_id.begins_with(prefix):
			keys.append(clue_id)

	var start_index: int = max(0, keys.size() - max_visible_clues)
	for i in range(start_index, keys.size()):
		var clue_id: String = keys[i]
		var label_text: String = ClueManager.collected[clue_id]
		var row := Label.new()
		row.add_theme_font_size_override("font_size", font_size)
		row.text = "• " + label_text
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.custom_minimum_size.x = 80
		_container.add_child(row)


func _on_clue_added(_clue_id: String, _clue_label: String) -> void:
	_rebuild()
