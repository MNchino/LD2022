tool
extends AnimatedSprite

var parent : AnimatedSprite

func _ready():
	parent = get_parent()

func _process(delta):
	flip_h = parent.flip_h
