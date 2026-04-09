extends Node

var group_by1 = SpanishCardResource.Suit.GOLDS
var group_by2 = SpanishCardResource.Suit.CUPS

func _activate(kartas : Kartas):
	
	if group_by1 in kartas.cards_by_suit and group_by2 in kartas.cards_by_suit:
		var temp = {}
		temp[group_by1+group_by2] = kartas.cards_by_suit[group_by1]+kartas.cards_by_suit[group_by2]
		kartas.cards_by_suit.erase(group_by1)
		kartas.cards_by_suit.erase(group_by2)
		kartas.cards_by_suit[group_by1+group_by2] = temp[group_by1+group_by2]
		
	
