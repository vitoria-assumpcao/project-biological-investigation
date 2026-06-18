extends CanvasLayer
## Full-screen credits screen. Call Credits.open() to show it.
## Register as Autoload named "Credits".

signal closed

var _overlay: Control


func _ready() -> void:
	layer = 110
	visible = false

	_overlay = Control.new()
	_overlay.anchor_right = 1.0
	_overlay.anchor_bottom = 1.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)

	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.05, 1.0)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(bg)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	_overlay.add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	scroll.add_child(vbox)

	# --- Final text ---
	var final_text := Label.new()
	final_text.text = "Este jogo é baseado em casos reais de surtos hospitalares por Legionella e outros agentes associados a sistemas de climatização sem manutenção adequada. Nenhum personagem representa um profissional culpado — todos representam profissionais que fazem seu trabalho dentro das condições que o sistema oferece.\n\nTorná-los visíveis é o primeiro passo para construir sistemas mais seguros."
	final_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	final_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	final_text.add_theme_font_size_override("font_size", 7)
	final_text.modulate = Color(0.9, 0.9, 0.85)
	vbox.add_child(final_text)

	_add_spacer(vbox, 10)

	# --- Divider ---
	var divider := ColorRect.new()
	divider.color = Color(0.3, 0.3, 0.3)
	divider.custom_minimum_size.y = 1
	vbox.add_child(divider)

	_add_spacer(vbox, 8)

	# --- Credits title ---
	var credits_title := Label.new()
	credits_title.text = "Além do Leito"
	credits_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits_title.add_theme_font_size_override("font_size", 10)
	credits_title.modulate = Color(1.0, 1.0, 1.0)
	vbox.add_child(credits_title)

	_add_spacer(vbox, 6)

	# --- Team ---
	var team: Array = [
		["Vitória Assumpção", "Dev"],
		["Jean Maciel", "Design"],
		["Ghiovanna Ventura", "Pesquisa e Roteiro"],
	]

	for member in team:
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_child(row)

		var name_label := Label.new()
		name_label.text = member[0]
		name_label.add_theme_font_size_override("font_size", 7)
		name_label.modulate = Color(1.0, 1.0, 1.0)
		row.add_child(name_label)

		var sep := Label.new()
		sep.text = "  —  "
		sep.add_theme_font_size_override("font_size", 7)
		sep.modulate = Color(0.5, 0.5, 0.5)
		row.add_child(sep)

		var role_label := Label.new()
		role_label.text = member[1]
		role_label.add_theme_font_size_override("font_size", 7)
		role_label.modulate = Color(0.75, 0.75, 0.75)
		row.add_child(role_label)

	_add_spacer(vbox, 10)

	# --- Close button ---
	var btn := Button.new()
	btn.text = "Encerrar"
	btn.add_theme_font_size_override("font_size", 7)
	btn.pressed.connect(close)
	vbox.add_child(btn)


func _add_spacer(parent: Control, height: int) -> void:
	var s := Control.new()
	s.custom_minimum_size.y = height
	parent.add_child(s)


func open() -> void:
	visible = true


func close() -> void:
	visible = false
	closed.emit()
