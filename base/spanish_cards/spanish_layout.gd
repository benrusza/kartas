## Visual layout for a StandardCardResource. Shows the suit icon, card value,
## and tints the background based on the card's modifier (Gold, Steel, or None).
## Shared by both the Balatro and Solitaire examples.
##
## Expects these unique-name nodes in the scene:
## %CardColor, %Texture1, %Texture2, %Texture, %Value1, %Value2
extends CardLayout

var sword_color = Color(0.47, 0.729, 0.937, 1.0)
var club_color = Color(0.577, 1.0, 0.476, 1.0)
var gold_color = Color(1.0, 0.914, 0.335, 1.0)
var cup_color = Color(1.0, 0.541, 0.398, 1.0)

@onready var card_color: PanelContainer = %CardColor
#@onready var value_1: Label = %Value1
#@onready var value_2: Label = %Value2
@onready var texture_1: TextureRect = %Texture1
@onready var texture_2: TextureRect = %Texture2
@onready var texture: TextureRect = %Texture

@onready var panelcontainer: PanelContainer = %PanelContainer
@onready var panelcontainer2: PanelContainer = %PanelContainer2

@onready var label_description : Label = %LabelDescription
@onready var label_number : Label = %LabelNumber
@onready var label_number2 : Label = %LabelNumber2
@onready var label_point : Label = %LabelPoint
@onready var box_description= %BoxDescription
@export var tooltip_offset : Vector2 = Vector2.LEFT
@export var point_offset : Vector2 = Vector2.LEFT

var res: SpanishCardResource

func _show_label_point() -> void:
	label_point.visible = true
	
func _hide_label_point() -> void:
	label_point.visible = false

func _show_tooltip() -> void:
	box_description.visible = true
	
func _hide_tooltip() -> void:
	box_description.visible = false

func _update_display() -> void:
	
	res = card_resource as SpanishCardResource
	if res.joker_mode != SpanishCardResource.JokerMode.NONE:
		label_point.text =str(res.name)
		label_number.visible = false
		label_number2.visible = false
		panelcontainer.visible = false
		panelcontainer2.visible = false
		
	else:
		label_point.text ="+ "+ str(res.value)
		label_number.text = str(res.order_num)
		label_number2.text = str(res.order_num)
		
	label_description.text = res.description
	box_description.set_position(tooltip_offset)
	label_point.set_position(point_offset)
	set_color()
	set_texture(res.texture)
	set_value()


## Tints the card background based on the modifier.
func set_color() -> void:
	match res.card_suit:
		SpanishCardResource.Suit.SWORDS:
			
			var stylebox: = card_color.get_theme_stylebox("panel").duplicate()
			stylebox.border_color = sword_color
			card_color.add_theme_stylebox_override("panel", stylebox)
			var stylebox2: = panelcontainer.get_theme_stylebox("panel").duplicate()
			stylebox2.border_color = sword_color
			panelcontainer.add_theme_stylebox_override("panel", stylebox2)
			panelcontainer2.add_theme_stylebox_override("panel", stylebox2)

		SpanishCardResource.Suit.CLUBS:
			var stylebox: = card_color.get_theme_stylebox("panel").duplicate()
			stylebox.border_color = club_color
			card_color.add_theme_stylebox_override("panel", stylebox)
			var stylebox2: = panelcontainer.get_theme_stylebox("panel").duplicate()
			stylebox2.border_color = club_color
			panelcontainer.add_theme_stylebox_override("panel", stylebox2)
			panelcontainer2.add_theme_stylebox_override("panel", stylebox2)

		SpanishCardResource.Suit.GOLDS:
			var stylebox: = card_color.get_theme_stylebox("panel").duplicate()
			stylebox.border_color = gold_color
			card_color.add_theme_stylebox_override("panel", stylebox)
			var stylebox2: = panelcontainer.get_theme_stylebox("panel").duplicate()
			stylebox2.border_color = gold_color
			panelcontainer.add_theme_stylebox_override("panel", stylebox2)
			panelcontainer2.add_theme_stylebox_override("panel", stylebox2)

		SpanishCardResource.Suit.CUPS:
			var stylebox: = card_color.get_theme_stylebox("panel").duplicate()
			stylebox.border_color = cup_color
			card_color.add_theme_stylebox_override("panel", stylebox)
			var stylebox2: = panelcontainer.get_theme_stylebox("panel").duplicate()
			stylebox2.border_color = cup_color
			panelcontainer.add_theme_stylebox_override("panel", stylebox2)
			panelcontainer2.add_theme_stylebox_override("panel", stylebox2)

	
	match res.current_modifier:
		res.Modifier.NONE:
			card_color.self_modulate = Color("ffe1d1ff")
		res.Modifier.GOLD:
			card_color.self_modulate = Color("ffd3a3")
		res.Modifier.STEEL:
			card_color.self_modulate = Color("99c2db")


## Converts numeric value to display text (A, J, Q, K for face cards).
func set_value() -> void:
	var text: String = ""

	match res.value:
		1:
			text = "A"
		11:
			text = "J"
		12:
			text = "Q"
		13:
			text = "K"
		_:
			text = str(res.value)
			

	#value_1.text = text
	#value_2.text = text


## Sets the suit icon on all three texture nodes (center + corners).
func set_texture(suit_texture: Texture2D) -> void:
	texture.texture = suit_texture
	#texture_1.texture = suit_texture
	#texture_2.texture = suit_texture
