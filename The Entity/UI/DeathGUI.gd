extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	GameState.connect("player_died_gui", self, 'show_after_death')

func show_after_death():
	visible = true
	$AnimationPlayer.play("RESET")

func _input(_event):
	if Input.is_action_just_pressed("game_restart"):
		if visible:
			GameState.reset()
			# warning-ignore:return_value_discarded
			get_tree().reload_current_scene()
