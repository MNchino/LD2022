extends Area2D

func _ready():
	# warning-ignore:return_value_discarded
	GameState.connect("player_died", self, "_hide_time")
	$Label.modulate = Color(1,1,1,0)

func _on_IntroLabel_body_entered(_body):
	disconnect("body_entered", self, "_on_IntroLabel_body_entered")
	$AnimationPlayer.play("FadeIn")

func _hide_time(_player):
	hide()
