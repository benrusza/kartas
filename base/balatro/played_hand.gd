extends CardHand



func select(card: Card) -> void:
	card.position_offset = Vector2(0, -40)
	arrange_cards()


func deselect(card: Card) -> void:
	card.position_offset = Vector2.ZERO
	arrange_cards()
	
func anim_point(card: Card) -> void:
	select(card)
	card._layout._show_label_point()
	await get_tree().create_timer(0.3).timeout
	card._layout._hide_label_point()
	deselect(card)
