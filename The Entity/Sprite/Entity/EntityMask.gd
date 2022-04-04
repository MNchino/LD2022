tool
extends AnimatedSprite

var parent : AnimatedSprite

func _ready():
	parent = get_parent();

func _process(_delta):
	animation = parent.animation
	frame = parent.frame
	flip_h = parent.flip_h
