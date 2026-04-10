## A standard playing card resource. Stores suit, value (1-13), a display texture,
## and an optional visual modifier. Used by both the Balatro and Solitaire examples.
class_name SpanishCardResource extends CardResource

@export var order_num: int = 0 #id
@export var name: String
@export var texture: Texture2D
@export var current_modifier: Modifier = Modifier.NONE
@export var card_suit: Suit = Suit.ALL
@export var joker_mode: JokerMode = JokerMode.NONE
@export var value: int = 1 ## 1 = Ace, 11 = Jack, 12 = Queen, 13 = King
@export var description: String # should permit multilang but how?
@export var jokerScript : Script = null

## Changes the card's background color in the layout.
enum Modifier {
	NONE,
	GOLD,
	STEEL,
}

enum Suit {
	CLUBS,
	GOLDS,
	CUPS,
	SWORDS,
	ALL, ## Wildcard / no specific suit
}

enum JokerMode {
	NONE,
	STARTER, # logic at the beggining of the game
	DOUBLER, # logic at the beggining of the game
	PASIVE, # logic on play
	GROUP_SUIT # junta los palos
}
