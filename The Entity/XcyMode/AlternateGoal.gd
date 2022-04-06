extends "res://Level/Goal/GoalCutscene.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func move_state():
	state += 1
	
	match state:
		1:
			$AnimationPlayer.play("1")
		2:
			$Control/Label.text = "Dorithos..."
			$ControlPlayer.play("FadeIn")
		3:
			$Control/Label.text = "My beloved."
			$ControlPlayer.play("FadeIn")
		4:
			$Control/Label.text = "I have arrived to thee."
			$ControlPlayer.play("FadeIn")
		5:
			$Control/Label.text = "For thy shall dab and enjoy prithee."
			$ControlPlayer.play("FadeIn")
		6:
			$AnimationPlayer.play("2")
		7:
			$Control/Label.modulate = Color("#cc1010")
			$Control/Label.text = "I will indulge in thine offering."
			$ControlPlayer.play("FadeIn")
		8:
			$Control/Label.text = "Through the dowsing of the flavor\n\nof the holy Nacho Cheese..."
			$ControlPlayer.play("FadeIn")
		9:
			$Control/Label.text = "Your sacrifice will hold fruit."
			$ControlPlayer.play("FadeIn")
		10:
			$Timer.start(2)
		11:
			$Control/Label.modulate = Color("#fff")
			$Control/Label.text = "Nacho Cheese Nuts."
			$ControlPlayer.play("FadeIn")
			auto_next = true
			$Timer.start(.5)
		12:
			$Control/Label.modulate = Color("#cc1010")
			$Control/Label.text = "Gottem."
			$ControlPlayer.play("FadeIn")
			$Timer.start(.2)
		13:
			var node = $Heartbreak
			remove_child(node)
			get_tree().get_current_scene().add_child(node)
			queue_free()
			
			GameState.cur_player.active = true
			GameState.cur_player.visible = true
			GameState.cur_player.invincible = false
			
			GameState.cur_player.update_sprite_xflip(-1)
			GameState.cur_player.global_position = $PlayerSprite.global_position + Vector2(0,-10)
			GameState.cur_player.insta_kill()
