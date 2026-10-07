class_name CharacterEntrance extends LoopPhase
	
var _hero: Hero
var _villain: Villain


func _init(
	hero_character: Hero,
	villain_character: Villain
	) -> void:
	_hero = hero_character
	_villain = villain_character


func run() -> void:
	#VFX de arribo del héroe y el villano
	#Aparece manos del villano
	#Fade in héroe al fondo de la pantalla
	pass


func get_report() -> AuditReport:
	return _report


func get_audit_header() -> String:
	return "Character entrance starting"
