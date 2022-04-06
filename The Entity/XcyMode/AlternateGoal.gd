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
			$Control/Label.text = "Doritos..."
			$ControlPlayer.play("FadeIn")
		3:
			$Control/Label.text = "My beloved."
			$ControlPlayer.play("FadeIn")
		4:
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
