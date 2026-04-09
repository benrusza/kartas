extends Control



func _process(delta):
	if Input.is_key_pressed(KEY_P):
		button_joker.visible = true

@onready var button_play : Button = %Play
@onready var button_exit : Button = %Exit
@onready var button_joker : Button = %SelectJoker

func _ready() -> void:
	button_play.pressed.connect(play_button_pressed)
	button_exit.pressed.connect(exit_button_pressed)
	button_joker.pressed.connect(joker_button_pressed)

func play_button_pressed() -> void:
	Global.joker_ids = []
	Global.round = 1
	Global.goal_points = 250
	
	get_tree().change_scene_to_file("res://base/balatro/Kartas.tscn")

func joker_button_pressed() -> void:
	get_tree().change_scene_to_file("res://selectjoker.tscn")
	
func exit_button_pressed() -> void:
	get_tree().quit()
