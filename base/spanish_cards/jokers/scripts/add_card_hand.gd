extends Node

func _activate(kartas : Kartas):
	print("activate add card hand")
	kartas.balatro_hand.max_hand_size += 1
