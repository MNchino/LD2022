extends "res://UI/GeneralDialogUI.gd"

func _init():
	dialog_lines = [
		"You won.",
		"You've literally killed death itself.",
		"Congratulations.",
		"Legit, I didn't expect you to make it this far.",
		"You've went above and beyond.",
		"Tackled every obstacle in your way.",
		"That dedication...",
		"That unbelievable persistence...",
		"It makes me truly happy.",
		"You've seen this through to the end.",
		"Here are your best times, recorded on the system:",
		"[HIGH_SCORES]",
		"In the end, there is no prize.",
		"Nothing spectacular, Nothing life changing.",
		"But even still, I think you knew that already.",
		"Grasping for for your life, potentially for hours...",
		"Even if the light ahead of you is short and dim.",
		"Somewhere, somehow, you found an attachment to keep going.",
		"As meaningless as others may see it...",
		"That small fragment of resolve drove you towards something amazing.",
		"Don't, ever, let that go.",
		"Just one more thing before you go...",
		"[THANK_YOU]",
	]

func _ready():
	start()
	
func play_next_dialog_line():
	if dialog_index < dialog_lines.size():
		disable_input()
		if dialog_lines[dialog_index] == "[THANK_YOU]":
			OS.alert('Thank you for playing our game.', 'Adieu')
			get_tree().quit()
		elif dialog_lines[dialog_index] == "[HIGH_SCORES]":
			$HighScores/HBoxContainer/VBoxContainer2/AloScore.text = "%0*d secs" % [3, min(GameState.alo_high_score, 999)]
			$HighScores/HBoxContainer/VBoxContainer2/XcyScore.text = "%0*d secs" % [3, min(GameState.xcy_high_score, 999)]
			$HighScores/HBoxContainer/VBoxContainer2/SnowScore.text = "%0*d secs" % [3, min(GameState.snow_high_score, 999)]
			$HighScores.visible = true
			enable_input()
		else:
			set_and_play_line(dialog_lines[dialog_index])
		dialog_index += 1
	else:
		if use_white:
			$AnimationPlayer.play("FadeOutWhite")
		else:
			$AnimationPlayer.play("FadeOutScene")
