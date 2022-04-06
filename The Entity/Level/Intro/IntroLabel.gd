extends Area2D

func _ready():
	# warning-ignore:return_value_discarded
	GameState.connect("player_died", self, "hide")
	$Label.modulate = Color(1,1,1,0)

func _on_IntroLabel_body_entered(_body):
	disconnect("body_entered", self, "_on_IntroLabel_body_entered")
	$AnimationPlayer.play("FadeIn")
