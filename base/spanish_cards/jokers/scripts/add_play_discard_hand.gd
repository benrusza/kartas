extends Node

func _activate(kartas : Kartas):
	kartas.plays += 1
	kartas.discards += 1
	kartas.balatro_hand.max_hand_size += 1
