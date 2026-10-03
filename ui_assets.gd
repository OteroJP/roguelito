class_name UIAssets
extends Object

const STANCE_LIBRARY: Dictionary[Hero.Stance, Texture2D] = {
	Hero.Stance.NONE: preload("uid://4q335xxs2p"),
	Hero.Stance.ATTACK: preload("uid://dk7fn6p2sy1xp"),
	Hero.Stance.DEFEND: preload("uid://dlrnwhe76u7ke"),
	Hero.Stance.UPGRADE: preload("uid://dlkhk201xuk2q"),
}

const SYMBOL_LIBRARY: Dictionary[Villain.Symbol, Texture2D] = {
	Villain.Symbol.NONE: null,
	Villain.Symbol.SKULL: preload("uid://cehsg6vccc7gd"),
	Villain.Symbol.OMEGA: preload("uid://b31undwpa6kjr"),
	Villain.Symbol.HEART: preload("uid://c1teqyuhv6yl8"),
}

const ATTACK_MODIFIER_LIBRARY: Dictionary[Villain.Symbol, Texture2D] = {
	Villain.Symbol.NONE: null,
	Villain.Symbol.SKULL: preload("uid://cehsg6vccc7gd"),
	Villain.Symbol.OMEGA: preload("uid://b31undwpa6kjr"),
	Villain.Symbol.HEART: preload("uid://c1teqyuhv6yl8"),
}

const STATUS_LIBRARY: Dictionary[Villain.Symbol, Texture2D] = {
	Villain.Symbol.NONE: null,
	Villain.Symbol.SKULL: preload("uid://cehsg6vccc7gd"),
	Villain.Symbol.OMEGA: preload("uid://b31undwpa6kjr"),
	Villain.Symbol.HEART: preload("uid://c1teqyuhv6yl8"),
}

const SYMBOL_COUNTER_SCENE: PackedScene = preload("uid://hj3gtb6iqefk")

const SPELL_BUTTON_SCENE: PackedScene = preload("uid://b8557o2sefgot")

const HERO_BONUS_STANCE_COLOR: Color = Color("b43333")

const VILLAIN_SECOND_PHASE_COLOR: Color = Color("063c2dff")
