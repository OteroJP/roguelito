class_name Resolution extends LoopPhase

var _control_node: Control


func init(playing_area_container: Control) -> void:
	_control_node = playing_area_container


func run() -> void:
	# Show Hero card
	var hero_card: Card = Card.new_card(GameManager.current_hero_card)
	hero_card.offset_transform_enabled = true
	hero_card.offset_transform_visual_only = true
	hero_card.offset_transform_rotation = PI
	_control_node.add_child(hero_card)
	await _control_node.get_tree().process_frame 
	
	var villain_card: Card = Card.new_card(GameManager.current_villain_card)
	_control_node.add_child(villain_card)
	await _control_node.get_tree().process_frame 
	
	# check stance and other condicionals.
	# check pc cards condicionales.
	# Compare cards speed and execute in order.
	await GameManager.sort_cards()
	await _control_node.get_tree().process_frame 
	
	# Execute faster card. 
	# WIN-LOSS CHECK
	await GameManager.execute_faster_card()
	# Execute slower card. 
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
		
	await GameManager.execute_slower_card()
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	
	await GameManager.end_phase()
	for child: Control in _control_node.get_children():
		child.queue_free()
	await _control_node.get_tree().process_frame 
	_control_node.hide()
	
	#TODO Discards cards, if there is more than hand_limit (6) it must discard hand_size - hand_limit.
