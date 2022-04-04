extends Node2D

func _ready():
	$PlayerSprite.play("Dead")
	
func _process(delta):
	if $PlayerSprite.frame == 0:
		$PlayerSprite.position.x = rand_range(-1,1)
	else:
		$PlayerSprite.position.x = 0

func _on_FinishedDying_timeout():
	GameState.start_death_gui()
