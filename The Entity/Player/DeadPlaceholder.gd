extends Node2D

var secondframe : bool = false

func _ready():
	get_tree().get_current_scene().get_node("PlayerCamera").target = self
	$PlayerSprite.play()
	$Audio/DeadHit.play()
	GameState.freeze(0.2)
	
func _process(_delta):
	if $PlayerSprite.frame == 0:
		$PlayerSprite.position.x = rand_range(-1,1)
	else:
		$PlayerSprite.position.x = 0
		if !secondframe:
			secondframe = true
			$Audio/DeadBump.play()

func _on_FinishedDying_timeout():
	GameState.start_death_gui()

func set_xflip(flip : bool):
	$PlayerSprite.flip_h = flip

func drown_sprite():
	$PlayerSprite.animation = "Drown"
