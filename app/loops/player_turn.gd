class_name PlayerTurn extends Loop


var _hero
var _villian

func _init(
	villian_character, 
	hero_character
	) -> void:
	_hero = hero_character
	_villian = villian_character
	
	
func run() -> void:
	# Opcional: Before choosing card: spend mana for casting spell.
	await _villian.activate_ability() 
	await _villian.play_card() # Mandatory: Player selects a card to play, may undo, and the confirms.	
	# On card play, check for symbol match:
		# Add symbols to completed symbols box
		# Symbol effect resolution (inmediatamente uno de 3 efectos genéricos).
