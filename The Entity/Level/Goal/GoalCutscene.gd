extends Node2D

var state : int = 0
var is_in_position : bool = false
var has_started : bool = false
var accept_input : bool = false setget set_accept_input
var auto_next : bool = true

var starting_position : Vector2

func _ready():
	set_physics_process(false)
	# warning-ignore:return_value_discarded
	GameState.connect("player_won", self, "start")
	
func start(_player):
	set_physics_process(true)
	$Label.visible = accept_input
	
	GameState.cur_entity.active = false
	GameState.cur_entity.get_node("AnimationPlayer").play("FadeOut")
	
	GameState.cur_player.active = false
	GameState.cur_player.visible = false
	for timer in GameState.cur_player.get_node("Timers").get_children():
		timer.stop()
	
	GameState.camera.target = self
	
	starting_position = $PlayerSprite.position
	$PlayerSprite.visible = true
	$PlayerSprite.position = to_local(GameState.cur_player.get_node("AnimatedSprite").global_position)
	$PlayerSprite.animation = "WalkUp" if starting_position < $PlayerSprite.position else "WalkDown"
	$AudioStep.start_sound()
	has_started = true
	
func _physics_process(delta):
	if has_started:
		#GameState.cur_entity.active = false
		if !is_in_position:
			$PlayerSprite.position = $PlayerSprite.position.move_toward(starting_position, 100 * delta)
			if $PlayerSprite.position == starting_position:
				is_in_position = true
				move_state()

func _input(_event):
	if Input.is_action_just_pressed("game_restart"):
		if accept_input:
			set_accept_input(false)
			$ControlPlayer.play("FadeOut")

func move_state():
	state += 1
	
	match state:
		1:
			$AnimationPlayer.play("1")
		2:
			$Control/Label.text = "Ena..."
			$ControlPlayer.play("FadeIn")
		3:	
			$Timer.wait_time = 2
			$Timer.start()
		4:
			$Control/Label.text = "I'm so sorry."
			$ControlPlayer.play("FadeIn")
		5:
			$AnimationPlayer.play("2")
			$Control/Label.text = "What's the matter, Alo, my dear?"
			$Control/Label.self_modulate = Color("#777586")
			$ControlPlayer.play("FadeIn")
			auto_next = false
		6:
			set_accept_input(true)
			auto_next = true
		7:
			$Control/Label.text = "I.."
			$Control/Label.self_modulate = Color("#fff")
			$ControlPlayer.play("FadeIn")
		8:
			$Timer.wait_time = 1
			$Timer.start()
		9:
			$PlayerSprite.flip_h = false
			$Timer.wait_time = 3
			$Timer.start()
		10:
			$PlayerSprite.flip_h = true
			$Timer.wait_time = 2
			$Timer.start()
		11:
			$Control/Label.text = "I.. don't have much time... left."
			$ControlPlayer.play("FadeIn")
		12:
			$Control/Label.text = "Dear..."
			$Control/Label.self_modulate = Color("#777586")
			$ControlPlayer.play("FadeIn")
		13:
			$AnimationPlayer.play("3")
		14:
			$Timer.wait_time = 1
			$Timer.start()
		15:
			$Heartbreak.play()
			$Timer.wait_time = 2
			$Timer.start()
		16:
			$Control/Label.text = "Thank you for everything."
			$ControlPlayer.play("FadeIn")
		17:
			$Control/Label.text = "To give me a chance to see you\n\none last time..."
			$ControlPlayer.play("FadeIn")
		18:
			$Timer.wait_time = 3
			$Timer.start() 
		19:
			$Control/Label.text = "Please, take care of the kids."
			$Control/Label.self_modulate = Color("#fff")
			$ControlPlayer.play("FadeIn")
		20:
			$Timer.wait_time = 2
			$Timer.start()
		21:
			$Control/Label.text = "I'll miss you."
			$Control/Label.self_modulate = Color("#777586")
			$ControlPlayer.play("FadeIn")
			auto_next = false
			$AnimationPlayer.play("4")
		22:
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

func _on_AnimationPlayer_animation_finished(_anim_name):
	move_state()
	
func set_accept_input(value):
	accept_input = value
	$Label.visible = value

func _on_ControlPlayer_animation_finished(anim_name):
	if anim_name == "FadeIn":
		if auto_next:
			set_accept_input(true)
	elif anim_name == "FadeOut":
		move_state()

func _on_Timer_timeout():
	move_state()
