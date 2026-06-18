extends CanvasLayer
## Full-screen inventory overlay. Toggle with Tab. Lists every clue collected
## so far via ClueManager. Attach as an Autoload named "Inventory" so it's
## available from any scene.

@export var background_color: Color = Color(0, 0, 0, 0.85)

var _overlay: Control
var _list_container: VBoxContainer
var _is_open: bool = false


func _ready() -> void:
	layer = 100  # above HUD (50), below Transition (128)
	visible = false

	_overlay = Control.new()
	_overlay.anchor_right = 1.0
	_overlay.anchor_bottom = 1.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)

	var bg := ColorRect.new()
	bg.color = background_color
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(bg)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	_overlay.add_child(margin)

	var outer_vbox := VBoxContainer.new()
	margin.add_child(outer_vbox)

	var title := Label.new()
	title.text = "Inventário de Pistas"
	title.add_theme_font_size_override("font_size", 12)
	outer_vbox.add_child(title)

	var hint := Label.new()
	hint.text = "Tab para fechar"
	hint.add_theme_font_size_override("font_size", 7)
	hint.modulate = Color(1, 1, 1, 0.6)
	outer_vbox.add_child(hint)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 6
	outer_vbox.add_child(spacer)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer_vbox.add_child(scroll)

	_list_container = VBoxContainer.new()
	_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list_container)

	ClueManager.clue_added.connect(_on_clue_added)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next") or (event is InputEventKey and event.pressed and event.keycode == KEY_TAB):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	if _is_open:
		close()
	else:
		open()


func open() -> void:
	_is_open = true
	_rebuild()
	visible = true


func close() -> void:
	_is_open = false
	visible = false


func _rebuild() -> void:
	for child in _list_container.get_children():
		child.queue_free()

	if ClueManager.collected.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Nenhuma pista coletada ainda."
		empty_label.add_theme_font_size_override("font_size", 8)
		empty_label.modulate = Color(1, 1, 1, 0.5)
		_list_container.add_child(empty_label)
		return

	for clue_id in ClueManager.collected.keys():
		var label_text: String = ClueManager.collected[clue_id]
		var row := Label.new()
		row.text = "• " + label_text
		row.add_theme_font_size_override("font_size", 8)
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_list_container.add_child(row)


func _on_clue_added(_clue_id: String, _clue_label: String) -> void:
	if _is_open:
		_rebuild()
