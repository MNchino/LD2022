extends Node2D

var state : int = 0
var input_ok : bool = false

signal starting_anim_done()

func _input(_event):
	if Input.is_action_just_pressed("game_restart"):
		if $AnimPlayer.is_playing():
			$AnimPlayer.playback_speed = 8
		elif !$Timer.is_stopped():
			$Timer.stop()
			move_state()
		elif input_ok:
			$OK.hide()
			$AnimPlayer.play("FadeOut")

func move_state():
	state = state + 1
	
	match state:
		1:
			$AnimPlayer.play("FadeIn")
		2:
			$Timer.start(2)
		3:
			$AnimPlayer.play("FadeOut")
		4:
			if Input.is_key_pressed(KEY_SHIFT):
				GameState.reset()
				# warning-ignore:return_value_discarded
				get_tree().change_scene("res://XcyMode/XcyPlayspace2.tscn") 
			$Intro1.hide()
			$Intro2.hide()
			$Label1.show()
			input_ok = true
			$AnimPlayer.play("FadeIn")
		5:
			pass
		6:
			$Label1.hide()
			$Label2.show()
			$AnimPlayer.play("FadeIn")
		7:
			pass
		8:
			$Label2.hide()
			$Label3.show()
			$AnimPlayer.play("FadeIn")
		9:
			pass
		10:
			$Label3.hide()
			$Label4.show()
			$AnimPlayer.play("FadeIn")
		11:
			pass
		12:
			emit_signal("starting_anim_done")
			
func _on_AnimPlayer_animation_finished(_anim_name):
	$AnimPlayer.playback_speed = 1
	if _anim_name == "FadeIn":
		if input_ok:
			$OK.show()
	move_state()

func _on_Timer_timeout():
	move_state()
