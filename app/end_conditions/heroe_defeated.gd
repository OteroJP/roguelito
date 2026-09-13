class_name HeroeDefeated extends EndCondition

var _heroe


func _init(heroe) -> void:
	_heroe = heroe


func was_satisfied() -> bool:
	#if _villain.health <= 0:
	satisfied.emit(self)
	return true #_villain.health <= 0
