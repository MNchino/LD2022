extends "res://UI/DeathGUI.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func restart_game():
	GameState.soft_reset()
	GameState.respawn_in_next_room()
	$AnimationPlayer.play('RESET')
	visible = false
