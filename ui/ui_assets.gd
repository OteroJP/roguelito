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
