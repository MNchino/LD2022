extends Node2D

func _ready():
	$PlayerSprite.play()
	GameState.freeze(0.2)
	
func _process(_delta):
	if $PlayerSprite.frame == 0:
		$PlayerSprite.position.x = rand_range(-1,1)
	else:
		$PlayerSprite.position.x = 0

func _on_FinishedDying_timeout():
	GameState.start_death_gui()

func set_xflip(flip : bool):
	$PlayerSprite.flip_h = flip

func drown_sprite():
	$PlayerSprite.animation = "Drown"
