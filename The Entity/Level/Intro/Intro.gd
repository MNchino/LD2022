extends Node2D

var skip = false

func _ready():
	# warning-ignore:return_value_discarded
	# GameState.connect("player_spawned", self, "_start")
	if skip || GameState.intro_started:
		$LevelGeometry/Skippy.queue_free()
		$LevelGeometry/IntroLabel/Label.text = "A shortcut to your right..."
		$LevelGeometry/Glowberry8.show()
		$LevelGeometry/Glowberry8.get_node("ParryHurtbox").monitorable = true
		$LevelGeometry/Glowberry8.get_node("ParryHurtbox").monitoring = true
		$YSort/IntroWalk.start()
		$UI/FadeIn.play("FadeIn")
		$UI/StartingAnim.queue_free()
	else:
		# warning-ignore:return_value_discarded
		$UI/StartingAnim.connect("starting_anim_done", self, "_start")

func _start():
	$UI/StartingAnim.disconnect("starting_anim_done", self, "_start")
	$UI/StartingAnim.queue_free()
	$YSort/IntroWalk.start()
	$UI/FadeIn.play("FadeIn")

func _input(_event):
	if Input.is_action_just_pressed("game_restart"):
		if !$UI/DeathGUI.visible && GameState.intro_started:
			GameState.reset()
			GameState.intro_started = false
			GameState.intro_done = false
			# warning-ignore:return_value_discarded
			get_tree().change_scene("res://Playspace.tscn") 
