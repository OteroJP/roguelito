class_name PlayerTurn extends LoopPhase


var _villain


func _init(
	villain_character, 
	) -> void:
	_villain = villain_character
	
	
func run() -> void:
	print("player turn started")
	# Opcional: Before choosing card: spend mana for casting spell.
	# TODO: Esto de abajo comentado lo implementaremos en otro sprint 
	#await _villain.activate_ability() 
	# TODO: cambiar lo de abajo por esto? 
	#		> GameManager.current_hero_card = await _villain.play_card() 
	await _villain.play_card() # Mandatory: Player selects a card to play, may undo, and the confirms.	
	# TODO: Esto de aca abajo va a Resolution, no?
	# On card play, check for symbol match:
		# Add symbols to completed symbols box
		# Symbol effect resolution (inmediatamente uno de 3 efectos genéricos).
	phase_ended.emit()	
