extends Area2D
@onready var dialog_box: Sprite2D = $"../DialogBox"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("cliqueEsquerdo"):
		dialog_box.visible= !dialog_box.visible
		
