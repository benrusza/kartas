extends Control

@export var use_stagger_draw: bool = true
@onready var card : Card = %Card
@onready var _draw : CardPile = %Draw

@onready var select_button : Button = %ButtonSelectJoker

@onready var card_deck_manager : CardDeckManager = %CardDeckManager
@export var cardres : CardResource

@onready var balatro_hand: JokerHand = %JokersHand

func _process(delta):
	if Input.is_key_pressed(KEY_P):
		get_tree().change_scene_to_file("res://selectjoker.tscn")

func _ready() -> void:
	Global.points = 0 # Reset points
	Global.goal_points = Global.goal_points + (50 * Global.round) # prepare for next round
	Global.round += 1
	select_button.pressed.connect(_on_select_pressed)
	
	
	CG.def_front_layout = LayoutID.SPANISH_LAYOUT
	#CG.def_back_layout = LayoutID.SPANISH_LAYOUT_BACK
	
	card_deck_manager.setup()
	deal()
	
func _on_select_pressed():
	if balatro_hand.selected.size()>0:
		print(str(balatro_hand.selected[0].card_data.order_num))
		Global.joker_ids.append( balatro_hand.selected[0].card_data.order_num)
		get_tree().change_scene_to_file("res://base/balatro/Kartas.tscn")
	


func staggered_draw(cards: Array[Card], hand: CardHand = balatro_hand, use_it: bool = use_stagger_draw):
	if use_it:
		for card in cards:
			hand.add_card(card)
			await get_tree().create_timer(.075).timeout
	else: hand.add_cards(cards)

func deal() -> void:
	var remaining_space := balatro_hand.get_remaining_space()
	var to_deal: int = 3
	
	if to_deal <= 0:
		return
	
	var pile_size: int = _draw.get_card_count()
	
	if pile_size >= to_deal:
		staggered_draw(_draw.draw_cards(to_deal))
		pass
	else:
		var overflow := to_deal - pile_size
		if pile_size > 0:
			staggered_draw(_draw.draw_cards(pile_size))
	
		#discard.move_all_to(_draw)
		_draw.shuffle()
	
		var new_pile_size := _draw.get_card_count()
		if new_pile_size > 0:
			staggered_draw(_draw.draw_cards(mini(overflow, new_pile_size)))
	
	for card in balatro_hand.cards:
		if !card.is_front_face:
			card.flip()
	

		
