class_name Resolution extends LoopPhase


func run() -> void:
	# Show Hero card
	# check stance and other condicionals.
	# check pc cards condicionales.
	# Compare cards speed and execute in order.
	await prepare_phase()
	# Execute faster card. 
	# WIN-LOSS CHECK
	await execute_faster_card()
	# Execute slower card. 
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	await execute_slower_card()
	if _have_loop_ended.call(): # WIN-LOSS CHECK
		return
	
	# Discards cards, if there is more than hand_limit (6) it must discard hand_size - hand_limit.


func prepare_phase() -> void:
	await create_timer(1).timeout
	

func execute_faster_card() -> void:
	await get_tree().create_timer(1).timeout


func execute_slower_card() -> void:
	await get_tree().create_timer(1).timeout
