extends Node2D

var skip = true

func _ready():
	# warning-ignore:return_value_discarded
	GameState.connect("player_spawned", self, "_start")
	if skip || GameState.intro_started:
		$LevelGeometry/Skippy.queue_free()
		$LevelGeometry/IntroLabel/Label.text = "A shortcut to your right..."
		$LevelGeometry/Glowberry8.show()
		$LevelGeometry/Glowberry8.get_node("ParryHurtbox").monitorable = true
		$LevelGeometry/Glowberry8.get_node("ParryHurtbox").monitoring = true

func _start(_player):
	pass

func _input(_event):
	if Input.is_action_just_pressed("game_restart"):
		if !$UI/DeathGUI.visible && GameState.intro_started:
			GameState.reset()
			GameState.intro_started = false
			GameState.intro_done = false
			# warning-ignore:return_value_discarded
			get_tree().change_scene("res://Playspace.tscn")
