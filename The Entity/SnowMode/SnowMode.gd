extends Node2D

func _ready():
	GameState.is_snow_mode = true
	GameState.connect("game_won", self, "on_game_won")

func on_game_won():
	$UI/FadeIn.play("FadeOut")

func switch_to_ending():
	get_tree().change_scene("res://SnowMode/EndingUI.tscn")
