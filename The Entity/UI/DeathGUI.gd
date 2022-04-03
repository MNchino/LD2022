extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.connect("player_died", self, 'show_after_death')

func show_after_death(player_that_died: Player):
	print('showing ')
	visible = true

func _on_ResetButton_pressed():
	GameState.reset()
	get_tree().reload_current_scene()
