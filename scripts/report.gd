extends CanvasLayer
## Full-screen "epidemiological report" overlay. Shows every clue collected
## across the whole investigation, organized into fixed report fields.
## Call Report.open() from a script (e.g. after the lab's closing dialogue)
## to show it; the player presses a button or Tab to close and continue.
##
## Register as Autoload named "Report".

## Maps a report field label to the list of clue_ids that belong under it.
## Add/adjust as needed — if a clue_id isn't collected yet, that line is
## simply skipped (so the report still looks fine even if something was
## missed, rather than showing an empty/broken field).
const REPORT_FIELDS: Dictionary = {
	"Agente etiológico": ["lab_cultura"],
	"Fonte de contaminação": ["uti_swab", "dorm_grade"],
	"Vetor de transmissão": ["lab_computador"],
	"Causa raiz": ["uti_manutencao"],
	"Profissionais que identificaram primeiro": ["dorm_fernanda"],
	"Padrão epidemiológico": ["uti_prontuario", "dorm_escala"],
	"Confirmação molecular": ["lab_quadro"],
}

signal closed

var _overlay: Control
var _list_container: VBoxContainer
var _continue_button: Button


func _ready() -> void:
	layer = 100
	visible = false

	_overlay = Control.new()
	_overlay.anchor_right = 1.0
	_overlay.anchor_bottom = 1.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.9)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(bg)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	_overlay.add_child(margin)

	var outer_vbox := VBoxContainer.new()
	margin.add_child(outer_vbox)

	var title := Label.new()
	title.text = "Relatório Epidemiológico"
	title.add_theme_font_size_override("font_size", 10)
	outer_vbox.add_child(title)

	var spacer_top := Control.new()
	spacer_top.custom_minimum_size.y = 4
	outer_vbox.add_child(spacer_top)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer_vbox.add_child(scroll)

	_list_container = VBoxContainer.new()
	_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list_container)

	var spacer_bottom := Control.new()
	spacer_bottom.custom_minimum_size.y = 4
	outer_vbox.add_child(spacer_bottom)

	_continue_button = Button.new()
	_continue_button.text = "Continuar"
	_continue_button.add_theme_font_size_override("font_size", 7)
	_continue_button.pressed.connect(close)
	outer_vbox.add_child(_continue_button)


func open() -> void:
	_rebuild()
	visible = true


func close() -> void:
	visible = false
	closed.emit()


func _rebuild() -> void:
	for child in _list_container.get_children():
		child.queue_free()

	for field_label in REPORT_FIELDS.keys():
		var clue_ids: Array = REPORT_FIELDS[field_label]
		var collected_texts: Array = []
		for clue_id in clue_ids:
			if ClueManager.has_clue(clue_id):
				collected_texts.append(ClueManager.collected[clue_id])

		if collected_texts.is_empty():
			continue  # skip fields with nothing collected, instead of showing them empty

		var field_title := Label.new()
		field_title.text = field_label + ":"
		field_title.add_theme_font_size_override("font_size", 7)
		_list_container.add_child(field_title)

		for text in collected_texts:
			var value_label := Label.new()
			value_label.text = "  " + text
			value_label.add_theme_font_size_override("font_size", 6)
			value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			_list_container.add_child(value_label)

		var spacer := Control.new()
		spacer.custom_minimum_size.y = 3
		_list_container.add_child(spacer)
