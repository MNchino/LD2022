extends Control


func _ready():
	# warning-ignore:return_value_discarded
	GameState.connect("player_won", self, 'show_after_win')

func show_after_win(_player_that_died: Player):
	visible = true
	$Panel/VBoxContainer/HBoxContainer/TimeInSeconds.text = "%10.2f seconds" % GameState.time_taken

func _on_ResetButton_pressed():
	GameState.reset()
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
