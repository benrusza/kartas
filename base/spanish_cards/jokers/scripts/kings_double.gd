extends Node

var card_to_double = 12 # king

func _activate(kartas : Kartas):
	var new_cards_to_point = []
	for card in kartas.cards_to_point:
		if card.card_data.value == card_to_double:
			print("activado rey")
			new_cards_to_point.append(card)
	
	return new_cards_to_point
	
