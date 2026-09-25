class_name Attack
extends RefCounted

:
	health -= damage
	character_stats_changed.emit()
