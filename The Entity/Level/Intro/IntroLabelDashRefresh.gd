extends "res://Level/Intro/IntroLabel.gd"

var first : bool = false

func _on_IntroLabel_body_entered(_body):
	if !first:
		first = true
		$AnimationPlayer.play("FadeIn")
	GameState.reset_dashes()
