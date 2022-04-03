extends Control


func _ready():
	GameState.connect("player_won", self, 'show_after_win')

func show_after_win(player_that_died: Player):
	visible = true

func _on_ResetButton_pressed():
	GameState.reset()
	get_tree().reload_current_scene()
