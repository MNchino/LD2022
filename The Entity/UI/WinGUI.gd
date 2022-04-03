extends Control


func _ready():
	GameState.connect("player_won", self, 'show_after_win')

func show_after_win(player_that_died: Player):
	visible = true
	$Panel/VBoxContainer/HBoxContainer/TimeInSeconds.text = "%10.2f seconds" % GameState.time_taken

func _on_ResetButton_pressed():
	GameState.reset()
	get_tree().reload_current_scene()
