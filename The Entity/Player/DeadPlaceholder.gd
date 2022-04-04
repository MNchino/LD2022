extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$PlayerSprite.play("Dead")


func _on_FinishedDying_timeout():
	GameState.start_death_gui()
