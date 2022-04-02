tool
extends AnimatedSprite

var parent : AnimatedSprite = get_parent()

func _process(delta):
	animation = parent.animation
	frame = parent.frame
	flip_h = parent.flip_h
