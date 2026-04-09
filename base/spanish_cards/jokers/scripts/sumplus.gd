extends Node


func _activate(kartas : Kartas, card : Card):
	print("activate add multiplier")
	kartas.jokers_hand.anim_point(card)
	await kartas.get_tree().create_timer(0.3).timeout
	kartas.points+= card.card_data.value
