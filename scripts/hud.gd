extends CanvasLayer
## Persistent HUD showing collected clues, top-left corner.
## Autoload named "Hud". Hides in scenes with no clue prefix.
## Uses _process to detect scene changes instead of tree_changed signal
## (tree_changed fires too frequently and causes coroutine accumulation).

@export var corner_margin: int = 4
@export var font_size: int = 5
@export var max_visible_clues: int = 3

var _container: VBoxContainer
var _title_label: Label
var _panel: PanelContainer
var _last_scene_name: String = ""

const CLUES_PER_SCENE: int = 3

const SCENE_PREFIXES: Dictionary = {
	"UTI": "uti_",
	"Laboratório": "lab_",
	"Dormitório": "dorm_",
}


func _get_current_scene_name() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return ""
	return scene.scene_file_path.get_file().get_basename()


func _current_scene_prefix() -> String:
	return SCENE_PREFIXES.get(_get_current_scene_name(), "")


func _count_clues_for_current_scene() -> int:
	var prefix: String = _current_scene_prefix()
	if prefix == "":
		return 0
	var n := 0
	for clue_id in ClueManager.collected.keys():
		if clue_id.begins_with(prefix):
			n += 1
	return n


func _ready() -> void:
	layer = 50

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

	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_control.add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 3)
	margin.add_theme_constant_override("margin_right", 3)
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_bottom", 2)
	_panel.add_child(margin)

	_container = VBoxContainer.new()
	_container.alignment = BoxContainer.ALIGNMENT_BEGIN
	margin.add_child(_container)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", font_size)
	_container.add_child(_title_label)

	ClueManager.clue_added.connect(_on_clue_added)
	_last_scene_name = _get_current_scene_name()
	_rebuild()


func _process(_delta: float) -> void:
	var current := _get_current_scene_name()
	if current != _last_scene_name:
		_last_scene_name = current
		_rebuild()


func _rebuild() -> void:
	var prefix: String = _current_scene_prefix()
	_panel.visible = prefix != ""

	if prefix == "":
		return

	for i in range(_container.get_child_count() - 1, 0, -1):
		_container.get_child(i).queue_free()

	var count: int = _count_clues_for_current_scene()
	_title_label.text = "Pistas: %d/%d" % [count, CLUES_PER_SCENE]

	var keys: Array = []
	for clue_id in ClueManager.collected.keys():
		if clue_id.begins_with(prefix):
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
