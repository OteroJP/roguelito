class_name VillainVisuals extends HBoxContainer

signal interaction_logged(entry: AuditLogEntry)
signal spell_resolution_finished

#signal hand_changed()

var _deck: Deck
var _chosen_card: CardData

@onready var _DeckContainer: MarginContainer = %DeckContainer
@onready var _HandContainer: MarginContainer = %HandContainer
@onready var _DiscardContainer: MarginContainer = %DiscardContainer
@onready var _Deck: Label = %Deck
@onready var _Hand: HBoxContainer = %Hand
@onready var _Discard: Label = %Discard
@onready var _ConfirmButton: Button = %ConfirmButton
@onready var _CancelButton: Button = %CancelButton
@onready var _HealthBar: ProgressBar = %Health
@onready var _HealthLabel: Label = %HealthLabel
@onready var _HealthDelta: Label = %HealthDelta
@onready var _ManaBar: ProgressBar = %Mana
@onready var _ManaLabel: Label = %ManaLabel
@onready var _ManaDelta: Label = %ManaDelta
@onready var _CurrentSymbol: TextureRect = %CurrentSymbol
@onready var _SymbolCompleted: TextureRect = %SymbolCompleted
@onready var _SymbolCounters: HBoxContainer = %SymbolCounters
@onready var _Spellbook: VBoxContainer = %Spellbook
@onready var _SpellConfirmBtn: Button = %SpellConfirmBtn
@onready var _Statuses: HBoxContainer = %Statuses

const _SELECTED_COLOR := Color(1, 0.86, 0.45)

var _villain: Villain
var _selected_cards: Array[CardData] = []
var _selection_limit: int = 1
var _multi_select: bool = false
var _discard_prompt: Label
var _spell_outcome: AuditOutcome = AuditOutcome.new()
var _pending_spell_resolutions: int = 0


func _ready() -> void:
	_CancelButton.pressed.connect(_cancel_selection)
	_CurrentSymbol.texture = null
	_SymbolCompleted.texture = null
	for bonus: SymbolBonus in _villain.symbol_bonuses:
		var new_symbol_counter = SymbolCounter.new_symbol_counter(bonus)
		_SymbolCounters.add_child(new_symbol_counter)
	for spell: VillainSpell in _villain.spells:
		var new_spell_btn = SpellButton.new_spell_button(spell, _villain)
		_Spellbook.add_child(new_spell_btn)
		new_spell_btn.spell_chosen.connect(_resolve_spell)
		new_spell_btn.interaction_logged.connect(_on_interaction_logged)
		new_spell_btn._refresh_enabled()
	_HealthDelta.text = ""
	_ManaDelta.text = ""
	_add_modifier_icons()
	_update_counters


func prepare(new_deck: Deck, villain: Villain) -> void:
	_deck = new_deck
	_deck.cards_moved.connect(_update_counters)
	_villain = villain

#TODO revisar esto


func add_to_hand(cards: Array[CardData]) -> void:
	var card_nodes: Array[Control] = []

	for data: CardData in cards:
		var card: VillainCard = VillainCard.new_villain_card(data)
		if _Hand:
			_Hand.add_child(card)
		card.offset_transform_enabled = true
		card.offset_transform_visual_only = true
		card_nodes.append(card) 	#TODO: think a zero-copy, statically typed solution bypassing current GDScript limitations

	await get_tree().create_timer(GameManager.ux_delay).timeout # Wait until the HBoxContainer has arranged its children.
	var animated_translation: Tween = _translation_tween(card_nodes)
	await animated_translation.finished

#


func choose_card() -> CardData:
	_multi_select = false
	_set_hand_interactable(true)
	await _ConfirmButton.pressed
	var card_selected: CardData = _chosen_card
	_cancel_selection()
	_set_hand_interactable(false)
	return card_selected


func choose_cards(amount: int) -> Array[CardData]:
	interaction_logged.emit(AuditLogEntry.new("Choosing cards to discard", AuditLogEntry.Source.VILLAIN))
	_multi_select = true
	_selection_limit = amount
	_selected_cards.clear()
	_discard_prompt = Label.new()
	_discard_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_discard_prompt.add_theme_font_size_override("font_size", 20)
	_refresh_discard_prompt()
	_Hand.get_parent().add_child(_discard_prompt)
	_Hand.get_parent().move_child(_discard_prompt, 0)
	_ConfirmButton.text = "DISCARD"
	_set_hand_interactable(true)
	await _ConfirmButton.pressed
	var picked: Array[CardData] = []
	picked.assign(_selected_cards)
	_finish_card_choice()
	return picked


func choose_cards_from_discard(cards: Array[CardData], amount: int) -> Array[CardData]:
	interaction_logged.emit(AuditLogEntry.new("Choosing cards from discard", AuditLogEntry.Source.VILLAIN))
	var selected: Array[CardData] = []
	var card_nodes: Array[VillainCard] = []
	var layer := CanvasLayer.new()
	layer.layer = 20
	get_tree().root.add_child(layer)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0, 0, 0, 0.72)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.add_child(center)

	var panel := PanelContainer.new()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.05, 0.09, 0.96)
	panel_style.border_color = Color(0.7882353, 0.54901963, 0.08235294, 1)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel_style.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)

	var prompt := Label.new()
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 22)
	prompt.text = _discard_pick_text(amount, 0)
	box.add_child(prompt)

	var scroll := ScrollContainer.new()
	var width := minf(maxf(cards.size(), 1) * 112.0, 920.0)
	scroll.custom_minimum_size = Vector2(width, 170)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	scroll.add_child(row)

	var confirm := Button.new()
	confirm.text = "CONFIRM"
	confirm.disabled = true
	confirm.custom_minimum_size = Vector2(160, 48)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.7882353, 0.54901963, 0.08235294, 0.6862745)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.7882353, 0.54901963, 0.08235294, 1)
	confirm.add_theme_stylebox_override("normal", normal)
	confirm.add_theme_stylebox_override("hover", hover)
	confirm.add_theme_stylebox_override("disabled", normal)
	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_child(confirm)
	box.add_child(button_row)

	for data: CardData in cards:
		var card_node := VillainCard.new_villain_card(data as VillainCardData)
		row.add_child(card_node)
		card_nodes.append(card_node)
		card_node.card_clicked.connect(
			func(clicked: CardData) -> void:
				_toggle_listed_card(clicked, selected, amount, card_nodes, confirm, prompt)
		)

	await confirm.pressed
	var picked: Array[CardData] = []
	picked.assign(selected)
	layer.queue_free()
	return picked


func cast_spells() -> AuditOutcome:
	_spell_outcome = AuditOutcome.new()
	_pending_spell_resolutions = 0
	_set_spells_interactable(true)
	await _SpellConfirmBtn.pressed
	_set_spells_interactable(false)
	while _pending_spell_resolutions > 0:
		await spell_resolution_finished
	return _spell_outcome


func _resolve_spell(spell: VillainSpell) -> void:
	_pending_spell_resolutions += 1
	_spell_outcome.append(await _villain.resolve_spell(spell))
	_pending_spell_resolutions -= 1
	spell_resolution_finished.emit()


func _on_interaction_logged(entry: AuditLogEntry) -> void:
	interaction_logged.emit(entry)


#TODO revisar esto


func remove_from_hand(card_data: CardData) -> void:
	#TODO animaciones sonidos y todo eso
	var card_to_remove: VillainCard = _find_card_in_hand(card_data)
	if card_to_remove == null:
		return
	#tween to visually move outside
	_Hand.remove_child(
		card_to_remove
	)
	card_to_remove.queue_free()
	#if card_to_remove:
		#hand_changed.emit()
	#GameManager.current_villain_card = card_data
	#_deck.play(card_data)


func _update_counters() -> void:
	_Discard.text  = "Discard: %d" %  _deck.cards_in_discard()
	_Deck.text = "Draw pile: %d / %d" % [_deck.cards_in_card_pile(), _deck.size()]
	var delta_mana_value = int(_villain.mana - _ManaBar.value)
	if delta_mana_value != 0:
		_ManaDelta.text = _format_delta_text(delta_mana_value)
		var _ManaDelta_tween: Tween = await LabelAnimation.animate_label_num_delta(_ManaDelta)

	var delta_health_value = int(_villain.health - _HealthBar.value)
	if delta_health_value != 0:
		_HealthDelta.text = _format_delta_text(delta_health_value)
		var _HealthDelta_tween: Tween = await LabelAnimation.animate_label_num_delta(_HealthDelta)
	#var health_bar_tween: Tween = RangeAnimation.animate_range_decrease(
		#_HealthBar,
		#absf(_HealthBar.value - _villain.health)
	#)
	#var mana_bar_tween: Tween = RangeAnimation.animate_range_decrease(
		#_ManaBar,
		#absf(_ManaBar.value - _villain.mana)
	#)
	_HealthBar.value = _villain.health
	_HealthBar.max_value = _villain.max_health
	_HealthLabel.text = "%d / %d" % [_villain.health, _villain.max_health]
	_HealthBar.add_theme_stylebox_override("fill", UIAssets.VILLAIN_SECOND_PHASE_STYLEBOX) if _villain.is_in_second_phase() else _HealthBar.add_theme_stylebox_override("fill", UIAssets.VILLAIN_FIRST_PHASE_STYLEBOX)
	_ManaBar.value = _villain.mana
	_ManaBar.max_value = _villain.max_mana
	_ManaLabel.text = "%d / %d" % [_villain.mana, _villain.max_mana]
	for counter in _SymbolCounters.get_children():
		counter.count = _villain.symbol_count[counter.get_symbol()]


func _find_card_in_hand(data: CardData) -> VillainCard:
	var card_ix = _Hand.get_children().find_custom(
		func(card_node: VillainCard):
			return card_node.match_data(data)
	)
	if card_ix == -1:
		return null
	return _Hand.get_children().get(card_ix)


func _set_spells_interactable(enabled: bool) -> void:
	for spell_button: SpellButton in _Spellbook.get_children():
		spell_button.enable_spell_cast(enabled)
	_SpellConfirmBtn.show() if enabled else _SpellConfirmBtn.hide()


func _set_hand_interactable(enabled: bool) -> void:
	for card: VillainCard in _Hand.get_children():
		card.set_process_input(enabled)
		if enabled:
			card.card_clicked.connect(_chose_card)
		else:
			card.card_clicked.disconnect(_chose_card)


func _chose_card(card: CardData) -> void:
	if _multi_select:
		_toggle_hand_card(card)
		return
	_chosen_card = card
	_CancelButton.show()
	_ConfirmButton.show()
	_CancelButton.set_process_input(true)
	_ConfirmButton.set_process_input(true)


func _toggle_hand_card(card: CardData) -> void:
	var node := _find_card_in_hand(card)
	if node == null:
		return
	if card in _selected_cards:
		_selected_cards.erase(card)
		node.modulate = Color.WHITE
	elif _selected_cards.size() < _selection_limit:
		_selected_cards.append(card)
		node.modulate = _SELECTED_COLOR
	_refresh_discard_prompt()
	var has_selection := not _selected_cards.is_empty()
	_CancelButton.visible = has_selection
	_CancelButton.set_process_input(has_selection)
	var ready := _selected_cards.size() == _selection_limit
	_ConfirmButton.visible = ready
	_ConfirmButton.set_process_input(ready)


func _toggle_listed_card(
	card: CardData,
	selected: Array[CardData],
	limit: int,
	card_nodes: Array[VillainCard],
	confirm: Button,
	prompt: Label
) -> void:
	var node := _card_node_for(card_nodes, card)
	if node == null:
		return
	if card in selected:
		selected.erase(card)
		node.modulate = Color.WHITE
	elif selected.size() < limit:
		selected.append(card)
		node.modulate = _SELECTED_COLOR
	confirm.disabled = selected.size() != limit
	prompt.text = _discard_pick_text(limit, selected.size())


func _card_node_for(card_nodes: Array[VillainCard], data: CardData) -> VillainCard:
	for card_node: VillainCard in card_nodes:
		if card_node.match_data(data as VillainCardData):
			return card_node
	return null


func _discard_pick_text(limit: int, selected_count: int) -> String:
	return "Choose %d cards from the discard (%d/%d)" % [limit, selected_count, limit]


func _refresh_discard_prompt() -> void:
	if _discard_prompt == null:
		return
	_discard_prompt.text = "Choose %d cards to discard (%d/%d)" % [
		_selection_limit, _selected_cards.size(), _selection_limit
	]


func _clear_card_highlights() -> void:
	for card: VillainCard in _Hand.get_children():
		card.modulate = Color.WHITE


func _finish_card_choice() -> void:
	_multi_select = false
	_selection_limit = 1
	_cancel_selection()
	if _discard_prompt:
		_discard_prompt.queue_free()
		_discard_prompt = null
	_ConfirmButton.text = "CONFIRM"
	_set_hand_interactable(false)


func _cancel_selection() -> void:
	_chosen_card = null
	_selected_cards.clear()
	_clear_card_highlights()
	_CancelButton.hide()
	_ConfirmButton.hide()
	_CancelButton.set_process_input(false)
	_ConfirmButton.set_process_input(false)
	_refresh_discard_prompt()


func change_current_symbol(new_symbol: Villain.Symbol) -> void:
	_CurrentSymbol.texture = get_symbol_asset(new_symbol)
	_SymbolCompleted.texture = null


func change_completed_symbol(new_symbol: Villain.Symbol) -> void:
	_SymbolCompleted.texture = get_symbol_asset(new_symbol)


func get_symbol_asset(symbol: Villain.Symbol) -> Texture2D:
	return UIAssets.SYMBOL_LIBRARY[symbol]


func _translation_tween(control_nodes: Array[Control]) -> Tween:
	const DELAY_FACTOR: float = 0.08
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	for i: int in control_nodes.size():
		var control: Control = control_nodes[i]
		control.offset_transform_enabled = true
		control.offset_transform_visual_only = true
		translation_tweener(
			tween,
			control,
			i*DELAY_FACTOR
		)
	return tween


func translation_tweener(
		tween: Tween,
		control: Control,
		delay: float
	) -> void:

	# TODO: make this an export
	const START_DISTANCE := 80.0
	const OVERSHOOT_DISTANCE := 20.0
	const FORWARD_DURATION := 0.25
	const RETURN_DURATION := 0.15

	var start_position: Vector2 = - Vector2(START_DISTANCE, 0.0)
	var overshoot_position: Vector2 = Vector2(OVERSHOOT_DISTANCE, 0.0)

	control.offset_transform_position = start_position
	(tween.tween_property(
			control,
			"offset_transform_position",
			overshoot_position,
			FORWARD_DURATION
		)
		.set_delay(delay)
		.set_trans(Tween.TRANS_QUAD)
		.set_ease(Tween.EASE_OUT)
	)
	(tween.tween_property(
		control,
		"offset_transform_position",
		 Vector2.ZERO,
		RETURN_DURATION
	)
	.set_delay(delay + FORWARD_DURATION)
	.set_trans(Tween.TRANS_BACK)
	.set_ease(Tween.EASE_OUT)
	)


func _format_delta_text(delta: int) -> String:
	var delta_string: String
	if delta > 0:
		delta_string = "+%s" % str(delta)
	else:
		delta_string = str(delta)
	return delta_string


func add_status(status: Status) -> void:
	var new_status_icon: StatusIcon = StatusIcon.new_status_icon(status)
	_Statuses.add_child(new_status_icon)


func _add_modifier_icons() -> void:
	_Statuses.add_child(DamageModificationIcon.new_icon(_villain))
	_Statuses.add_child(BonusSpeedIcon.new_icon(_villain))
	_Statuses.add_child(IgnoreArmorIcon.new_icon(_villain))
