extends TextureRect

var gradient_texture : GradientTexture2D
@export var gradient_path = ""
var gradient : Gradient
var offset : float = 0.0
@export var speed = 0.0



func _ready() -> void:
	gradient_texture = GradientTexture2D.new()
	gradient = load( gradient_path)
	gradient_texture.gradient = gradient
	texture = gradient_texture

var direction = 1

func _process(delta: float) -> void:
	if offset > 0.9:
		offset = 0.9
		direction = -1
	elif offset < 0.1:
		offset = 0.1
		direction = 1
		
	offset += delta * speed * direction
	gradient.set_offset(1, lerp(0.0, 1.0, offset))
