extends Area2D
## Base class for all interactable objects in the game.
## Handles mouse highlight and input detection.
## Subclass this (or use interactable.gd directly) instead of duplicating
## highlight logic across scripts.

@export var enable_highlight: bool = true
@export var highlight_target: NodePath = NodePath("")
@export var highlight_color: Color = Color(1.3, 1.3, 1.0, 1.0)
@export var highlight_fade_seconds: float = 0.15

var _visual_node: CanvasItem
var _original_modulate: Color


func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_resolve_visual_node()


func _resolve_visual_node() -> void:
	if highlight_target != NodePath(""):
		var target := get_node_or_null(highlight_target)
		if target is CanvasItem:
			_visual_node = target
	else:
		var parent := get_parent()
		if parent is CanvasItem:
			_visual_node = parent

	if _visual_node != null:
		_original_modulate = _visual_node.modulate


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_trigger()


## Override in subclasses to define what happens when clicked.
func _trigger() -> void:
	pass


func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	_set_highlight(true)


func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	_set_highlight(false)


func _set_highlight(on: bool) -> void:
	if not enable_highlight or _visual_node == null:
		return
	var target_color: Color = highlight_color if on else _original_modulate
	var tween := create_tween()
	tween.tween_property(_visual_node, "modulate", target_color, highlight_fade_seconds)
