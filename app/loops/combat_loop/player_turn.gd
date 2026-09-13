class_name PlayerTurn extends LoopPhase


var _hero
var _villain

func _init(
	villain_character, 
	hero_character
	) -> void:
	_hero = hero_character
	_villain = villain_character
	
	
func run() -> void:
	# Opcional: Before choosing card: spend mana for casting spell.
	await _villain.activate_ability() 
	await _villain.play_card() # Mandatory: Player selects a card to play, may undo, and the confirms.	
	# On card play, check for symbol match:
		# Add symbols to completed symbols box
		# Symbol effect resolution (inmediatamente uno de 3 efectos genéricos).
