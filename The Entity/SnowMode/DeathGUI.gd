extends "res://UI/DeathGUI.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	death_messages = [
		"Keep going, I believe in you.",
		"No turning back now.",
		"This is it.  This is the final battle.",
		"You know what needs to be done.",
		"You've come this far. Can't back out now.",
		"Yes, I do indeed hate myself.",
		"to hoe",
		"There is no exit, just one obstacle in front of you.",
		"There's no easy way out.  Not this time.",
		"Eventually, it does get easier.",
		"m u r d e r",
		"bruh, get back up, it's way too early for dying.",
		"Only that which is pink strikes back.",
		"I named the wall 'wally' :)",
		"this mode wasn't supposed to happen",
		"what are u gonna do with your time once this is all over",
		"time for a word from this game's sponsor, caffeine",
		"oki bruh there's no secrets hidden in the death quotes this time",
		"unfortunately in this game, you cannot touch grass",
		"unfortunately in this game, you cannot pet the entity",
		"if you think about it really hard, isn't the sun an RGB light?",
		"game ending music gonna be like \"I don't want To Say Goodbye\"",
		"should we add ducks to the game?",
		"come for the gameplay, stay for the random quotes",
		"Can you beat it without reading every quote?",
		"If you don't beat it, I'm stealing your dog.",
		"bouncy bouncy bouncy bouncy bouncy bouncy bouncy bouncy "
	]

func restart_game():
	GameState.soft_reset()
	GameState.respawn_in_next_room()
	$AnimationPlayer.play('RESET')
	visible = false
