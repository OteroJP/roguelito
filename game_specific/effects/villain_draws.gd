@tool
class_name VillainDraw
extends Effect

@export var cards_to_draw: int = 1



func apply(target: Character) -> bool:
    var previous_hand_size := target.deck.cards_in_hand()
    for _index in cards_to_draw:
        target.draw()
    return target.deck.cards_in_hand() != previous_hand_size


func _effect_text() -> String:
    return "Villain draws %d cards" % cards_to_draw
