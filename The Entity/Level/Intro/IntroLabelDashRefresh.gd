extends Area2D

var first : bool = false

func _ready():
	# warning-ignore:return_value_discarded
	GameState.connect("player_died", self, "_hide_time")
	$Label.modulate = Color(1,1,1,0)

func _on_IntroLabel_body_entered(_body):
	if !first:
		first = true
		$AnimationPlayer.play("FadeIn")
	GameState.reset_dashes()

func _hide_time(_player):
	hide()
