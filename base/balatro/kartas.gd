## Based on Balatro-style card game example.
##
## Shows off: drawing from a deck, selecting and playing cards, discarding,
## applying visual modifiers (Gold/Steel), sorting, and previewing pile contents.
##
## Scene nodes:
## - CardDeckManager: manages the deck, populates the draw pile
## - Draw (CardPile): the draw pile
## - Discard (CardPile): the discard pile
## - BalatroHand: player's hand (arc shape, max 7, click to select)
## - PlayedHand: staging area for played cards (line shape)

extends CanvasLayer

class_name Kartas 

@export var deck: CardDeck
@export var use_stagger_draw: bool = true
# ----
@export var goal_points: int = 1000
var current_points: int = 0

@onready var card_deck_manager: CardDeckManager = $CardDeckManager
@onready var joker_deck_manager: CardDeckManager = $JokerDeckManager
@onready var played_hand: CardHand = %PlayedHand
@onready var balatro_hand: BalatroHand = %BalatroHand
@onready var jokers_hand: JokerHand = %JokersHand


@onready var draw: CardPile = %Draw
@onready var jokers: CardPile = %Jokers
@onready var discard: CardPile = %Discard

@onready var gold_button: Button = %GoldButton
@onready var silv_button: Button = %SilvButton
@onready var none_button: Button = %NoneButton

@onready var discard_button: Button = %DiscardButton
@onready var play_button: Button = %PlayButton

@onready var sort_suit_button: Button = %SortSuitButton
@onready var sort_value_button: Button = %SortValueButton

@onready var preview_hand: CardHand = %PreviewHand
@onready var preview_draw: Button = %PreviewDraw
@onready var preview_discard: Button = %PreviewDiscard
# ----
@onready var label_goal_points: Label = %LabelGoalPoints
@onready var label_points: Label = %LabelPoints

@onready var label_multiplier_name: Label = %LabelMultiplierName
@onready var label_multiplier: Label = %LabelMultiplier
@onready var label_hand_points: Label = %LabelHandPoints

@onready var label_discards: Label = %LabelDiscards
@onready var label_plays: Label = %LabelPlays
var plays = 3
var discards = 3

var preview_visible: bool = false
var current_preview_pile: CardPile

var sort_by_suit: bool = false

func _process(delta):
	if Input.is_key_pressed(KEY_P):
		current_points += 1000

func _ready() -> void:
	gold_button.pressed.connect(_on_gold_pressed)
	silv_button.pressed.connect(_on_silv_pressed)
	none_button.pressed.connect(_on_none_pressed)
	discard_button.pressed.connect(_on_discard_pressed)
	play_button.pressed.connect(_on_play_button)
	sort_suit_button.pressed.connect(_on_sort_suit_pressed)
	sort_value_button.pressed.connect(_on_sort_value_pressed)
	preview_draw.pressed.connect(_on_preview_draw_pressed)
	preview_discard.pressed.connect(_on_preview_discard_pressed)
	
	CG.def_front_layout = LayoutID.SPANISH_LAYOUT
	CG.def_back_layout = LayoutID.SPANISH_LAYOUT_BACK
	
	card_deck_manager.setup()
	joker_deck_manager.setup()
	set_jokers()
	
	deal()
	
	goal_points = Global.goal_points
	label_goal_points.text = str(goal_points)
	label_discards.text = str(discards)
	label_plays.text = str(plays)
	
	

func set_jokers():
	if Global.joker_ids.size()==0:
		return
		
	for joker in jokers._cards:
		for id in Global.joker_ids:
			if joker.card_data.order_num == id:
				jokers_hand.add_card(joker.duplicate())
	
	for joker in jokers_hand.cards:
		if joker.card_data.joker_mode == SpanishCardResource.JokerMode.STARTER:
			joker.card_data.jokerScript.new()._activate(self)
			
			
	
	
	

#region Modifier Buttons

func _on_gold_pressed() -> void:
	for card: Card in balatro_hand.selected:
		card.card_data.current_modifier = SpanishCardResource.Modifier.GOLD
		card.refresh_layout()
	balatro_hand.clear_selected()


func _on_silv_pressed() -> void:
	for card: Card in balatro_hand.selected:
		card.card_data.current_modifier = SpanishCardResource.Modifier.STEEL
		card.refresh_layout()
	balatro_hand.clear_selected()


func _on_none_pressed() -> void:
	for card: Card in balatro_hand.selected:
		card.card_data.current_modifier = SpanishCardResource.Modifier.NONE
		card.refresh_layout()
	balatro_hand.clear_selected()

#endregion


#region Play and Discard

func _on_discard_pressed() -> void:
	if discards<=0:
		return
		
	if balatro_hand.selected.is_empty():
		return
	discards-=1
	label_discards.text=str(discards)
	var cards_to_discard := balatro_hand.selected.duplicate()
	balatro_hand.clear_selected()
	for card in cards_to_discard:
		discard.add_card(card)
	
	deal()


var cards_by_suit = {}
var cards_by_value = {}
var cards_to_point = []
var points = 0

func _on_play_button() -> void:
	if balatro_hand.selected.is_empty():
		return
		
	if plays<=0:
		return
	plays-=1
	label_plays.text=str(plays)
	
	_set_interaction_enabled(false)
	
	balatro_hand.sort_selected()
	var cards_to_play := balatro_hand.selected.duplicate()
	balatro_hand.clear_selected()
	staggered_draw(cards_to_play, played_hand)
	
	#await get_tree().create_timer(2).timeout ## Replace with VFX/Logic
	
	cards_by_suit = {}
	cards_by_value = {}
	points = 0
	cards_to_point = []
	
	for card in played_hand.cards.duplicate():
		if cards_by_suit.has(card.card_data.card_suit):
			cards_by_suit[card.card_data.card_suit].append(card)
		else:
			cards_by_suit[card.card_data.card_suit] = [card]
		
		if cards_by_value.has(card.card_data.value):
			cards_by_value[card.card_data.value].append(card)
		else:
			cards_by_value[card.card_data.value] = [card]
					

	#comodin de juntar palos aqui
	for joker in jokers_hand.cards:
		if joker.card_data.joker_mode == SpanishCardResource.JokerMode.GROUP_SUIT:
			joker.card_data.jokerScript.new()._activate(self)

	var id_bigger_cards_by_suit = cards_by_suit.keys()[0]
	for cards in cards_by_suit.duplicate():
		if cards_by_suit[cards].size() > cards_by_suit[id_bigger_cards_by_suit].size():
			id_bigger_cards_by_suit = cards
			
	
	var id_bigger_cards_by_value = cards_by_value.keys()[0]
	for cards in cards_by_value.duplicate():
		if cards_by_value[cards].size() > cards_by_value[id_bigger_cards_by_value].size():
			id_bigger_cards_by_value = cards
			

	var straight = has_straight(played_hand.cards)
	var multiplier = 1
			
			
	if cards_by_suit[id_bigger_cards_by_suit].size()==5:
		if straight:
			print("escalera de color*5")
			label_multiplier_name.text = "Escalera de color"
			for card in played_hand.cards:
				cards_to_point.append(card)
			multiplier = 5
		else:
			print("5 cartas de color *3")
			label_multiplier_name.text = "Color"
			for card in played_hand.cards:
				cards_to_point.append(card)
			multiplier = 3
		pass
	elif cards_by_value[id_bigger_cards_by_value].size()==4:
		print("poker*4")
		label_multiplier_name.text = "Poker"
		multiplier = 5
		for card in played_hand.cards:
			cards_to_point.append(card)
	elif straight:
		for card in played_hand.cards:
			cards_to_point.append(card)
		print("escalera* 3")
		label_multiplier_name.text = "Escalera"
		multiplier = 4
	elif cards_by_value[id_bigger_cards_by_value].size()==3:
		print("trio * 3")
		label_multiplier_name.text = "Trio"
		multiplier = 2
			
		for card in cards_by_value.values():
			if card.size()>=2 :
				multiplier+=1
				for c in card:
					cards_to_point.append(c)
		# hay full?no
		if multiplier == 4:
			label_multiplier_name.text = "Trieja"
		else:
			label_multiplier_name.text = "Trio"
	elif cards_by_value[id_bigger_cards_by_value].size()==2:

		# hay doble pareja?
		for card in cards_by_value.values():
			if card.size()==2:
				multiplier+=1
				for c in card:
					cards_to_point.append(c)
		if multiplier == 3:
			label_multiplier_name.text = "Doble pareja"
		else:
			label_multiplier_name.text = "Pareja"
			
	elif cards_by_value[id_bigger_cards_by_value].size()==1:
		label_multiplier_name.text = "Carta alta"
		multiplier = 1
		# conseguir carta mas alta
		var bigger = played_hand.cards[0]
		for card in played_hand.cards.duplicate():
			if card.card_data.value > bigger.card_data.value:
				bigger = card
		cards_to_point.append(bigger)
		

	await get_tree().create_timer(0.5).timeout
	
	for card in cards_to_point:
		points+=card.card_data.value
		played_hand.anim_point(card)
		await get_tree().create_timer(0.3).timeout
		
	var to_point_by_joker = []
	
	#joker :cartas de x tipo puntuan el doble
	for joker in jokers_hand.cards:
		if joker.card_data.joker_mode == SpanishCardResource.JokerMode.DOUBLER:
			to_point_by_joker = joker.card_data.jokerScript.new()._activate(self)
	await get_tree().create_timer(0.5).timeout
	
	if to_point_by_joker.size()>0:
		for card in to_point_by_joker:
			points+=card.card_data.value
			played_hand.anim_point(card)
			await get_tree().create_timer(0.3).timeout
	
	#joker :cartas de x tipo puntuan el doble
	for joker in jokers_hand.cards:
		if joker.card_data.joker_mode == SpanishCardResource.JokerMode.PASIVE:
			joker.card_data.jokerScript.new()._activate(self,joker)
			await get_tree().create_timer(0.3).timeout
	
	
	label_hand_points.text = str(points)
	label_multiplier.text = "x"+str(multiplier)
	
	points*=multiplier
	
	await get_tree().create_timer(0.5).timeout
	
	current_points+=points
	label_points.text = str(current_points)
	Global.points = current_points
	#points+=card.card_data.value
	
	label_hand_points.text = ""
	label_multiplier.text = ""
	
	
	for card in played_hand.cards.duplicate():
		discard.add_card(card)
	
	played_hand.clear_hand()
	
	if goal_points <= current_points:
		get_tree().change_scene_to_file("res://selectjoker.tscn")
		return
	
	if plays==0:
		get_tree().change_scene_to_file("res://base/gameover.tscn")
		return
	
	deal()
	_set_interaction_enabled(true)
	
func has_straight(cards):
	if cards.size()<5:
		return false
	# Sort the cards by value
	cards.sort_custom(Callable(self, "_sort_cards_by_value"))

	# Check if the cards have consecutive values
	var previous_value = cards[0].card_data.value - 1
	for card in cards:
		if card.card_data.value != previous_value + 1:
			return false
		previous_value = card.card_data.value

	return true

func _sort_cards_by_value(a, b):
	return a.card_data.order_num < b.card_data.order_num


#endregion


#region Dealing

## Fills the hand back up to max size. If draw pile runs out mid-deal,
## reshuffles the discard pile into draw and keeps drawing.
func deal() -> void:
	var remaining_space := balatro_hand.get_remaining_space()
	var to_deal: int = remaining_space if remaining_space >= 0 else balatro_hand.max_hand_size
	
	if to_deal <= 0:
		return
	
	var pile_size: int = draw.get_card_count()
	
	if pile_size >= to_deal:
		staggered_draw(draw.draw_cards(to_deal))
	else:
		var overflow := to_deal - pile_size
		if pile_size > 0:
			staggered_draw(draw.draw_cards(pile_size))
	
		discard.move_all_to(draw)
		draw.shuffle()
	
		var new_pile_size := draw.get_card_count()
		if new_pile_size > 0:
			staggered_draw(draw.draw_cards(mini(overflow, new_pile_size)))
	
	for card in balatro_hand.cards:
		if !card.is_front_face:
			card.flip()
	
	_apply_sort()

#endregion


#region Sorting

func _on_sort_suit_pressed() -> void:
	sort_by_suit = true
	balatro_hand.sort_by_suit()

	
func _on_sort_value_pressed() -> void:
	sort_by_suit = false
	balatro_hand.sort_by_order()


func _apply_sort() -> void:
	if sort_by_suit:
		balatro_hand.sort_by_suit()
	else:
		balatro_hand.sort_by_order()


#endregion


#region UI State

## Hides/shows everything. Used by pile preview to take over the screen.
func _set_ui_enabled(enabled: bool) -> void:
	discard_button.disabled = !enabled
	play_button.disabled = !enabled
	sort_suit_button.disabled = !enabled
	sort_value_button.disabled = !enabled
	gold_button.disabled = !enabled
	silv_button.disabled = !enabled
	none_button.disabled = !enabled
	
	balatro_hand.visible = enabled


func _set_interaction_enabled(enabled: bool) -> void:
	discard_button.disabled = !enabled
	play_button.disabled = !enabled
	sort_suit_button.disabled = !enabled
	sort_value_button.disabled = !enabled
	gold_button.disabled = !enabled
	silv_button.disabled = !enabled
	none_button.disabled = !enabled
	
	for card in balatro_hand.cards:
		card.disabled = !enabled

#endregion

#region Preview Functions

func _on_preview_discard_pressed() -> void:

		
	if preview_visible and current_preview_pile == discard:
		_close_preview()
		return

	if discard.is_empty():
		return
			
	_show_preview(discard)


func _on_preview_draw_pressed() -> void:
	if preview_visible and current_preview_pile == draw:
		_close_preview()
		return

	if draw.is_empty():
		return

	_show_preview(draw)


func _show_preview(pile: CardPile) -> void:
	preview_visible = true
	current_preview_pile = pile
	_set_ui_enabled(false)
	show_pile_preview_hand(current_preview_pile.get_cards())
	_sort_preview(preview_hand)
	for card in preview_hand.cards:
		card.disabled = true


func _close_preview() -> void:
	if preview_visible:
		hide_pile_preview_hand()
	preview_visible = false
	current_preview_pile = null
	_set_ui_enabled(true)


func show_pile_preview_hand(cards: Array[Card]) -> void:
	_update_pile_preview_hand(cards)


func _update_pile_preview_hand(cards: Array[Card]) -> void:
	if cards.is_empty():
		return
	
	preview_hand.clear_hand()
	var preview_cards: Array[Card] = []
	var preview_card = cards
	
	for child in preview_card:
		if child is Card:
			var card_proxy: Card = Card.new(child.card_data)
			card_proxy.name = child.name + "_preview"
			card_proxy.set_meta("source_card", child)
			preview_cards.append(card_proxy)
	
	preview_hand.add_cards(preview_cards)
	_sort_preview(preview_hand)


func hide_pile_preview_hand() -> void:
	if preview_hand:
		preview_hand.clear_and_free()


func _sort_preview(hand: CardHand) -> void:
	hand.sort_cards(func(a: Card, b: Card) -> bool:
		if a.card_data.card_suit != b.card_data.card_suit:
			return a.card_data.card_suit < b.card_data.card_suit
		return a.card_data.value < b.card_data.value)


func staggered_draw(cards: Array[Card], hand: CardHand = balatro_hand, use_it: bool = use_stagger_draw):
	if use_it:
		for card in cards:
			hand.add_card(card)
			await get_tree().create_timer(.075).timeout
	else: hand.add_cards(cards)


#endregion
