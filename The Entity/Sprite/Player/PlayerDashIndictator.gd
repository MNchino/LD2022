tool
extends AnimatedSprite

var parent : AnimatedSprite

func _ready():
	parent = self.get_parent()

func _process(_delta):
	flip_h = parent.flip_h
