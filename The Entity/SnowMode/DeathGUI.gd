extends "res://UI/DeathGUI.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func show_after_death():
	.show_after_death()
	if !GameState.intro_started:
		if GameState.drowned:
			GameState.times_drowned_in_a_row += 1
		else:
			GameState.times_drowned_in_a_row = 0
	
