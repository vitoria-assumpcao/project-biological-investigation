extends CanvasLayer
## Autoload singleton. Register this in Project > Project Settings > Globals > Autoload
## with the name "Transition" so it's globally accessible.
##
## Provides a full-screen fade overlay used for:
## - fading in when the game first starts
## - fading out -> changing scene -> fading back in

@export var fade_duration: float = 0.9
@export var fade_color: Color = Color.BLACK

var _rect: ColorRect


func _ready() -> void:
	layer = 128  # always render on top of everything else

	_rect = ColorRect.new()
	_rect.color = fade_color
	_rect.anchor_right = 1.0
	_rect.anchor_bottom = 1.0
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)

	# Start fully black, then fade in once the first scene is ready.
	_rect.modulate.a = 1.0
	await get_tree().process_frame
	fade_in()


## Call this once, e.g. from the very first scene, if you want an explicit
## fade-in on game start. (Also runs automatically on autoload _ready.)
func fade_in() -> void:
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", 0.0, fade_duration)


## Call this to fade to black, then jump to next_scene, then fade back in.
func fade_to_scene(next_scene: String) -> void:
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP  # block clicks during transition
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", 1.0, fade_duration)
	await tween.finished

	get_tree().change_scene_to_file(next_scene)

	# Wait one frame so the new scene is actually in the tree before fading in.
	await get_tree().process_frame

	var tween_in := create_tween()
	tween_in.tween_property(_rect, "modulate:a", 0.0, fade_duration)
	await tween_in.finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
