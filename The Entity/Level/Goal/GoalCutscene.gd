extends Node2D

var state : int = 0
var is_in_position : bool = false
var has_started : bool = false

var starting_position : Vector2

func _ready():
	# warning-ignore:return_value_discarded
	GameState.connect("player_spawned", self, "start")
	
func start(_player):
	GameState.cur_entity.active = false
	GameState.cur_entity.get_node("AnimationPlayer").play("FadeOut")
	
	GameState.cur_player.active = false
	GameState.cur_player.visible = false
	for timer in GameState.cur_player.get_node("Timers").get_children():
		timer.stop()
	
	get_tree().get_current_scene().get_node("PlayerCamera").target = self
	
	starting_position = $PlayerSprite.position
	$PlayerSprite.position = to_local(GameState.cur_player.get_node("AnimatedSprite").global_position)
	$PlayerSprite.animation = "WalkUp" if starting_position < $PlayerSprite.position else "WalkDown"
	$AudioStep.start_sound()
	has_started = true
	
func _physics_process(delta):
	GameState.cur_entity.active = false
	if has_started && !is_in_position:
		$PlayerSprite.position = $PlayerSprite.position.move_toward(starting_position, 100 * delta)
		if $PlayerSprite.position == starting_position:
			is_in_position = true
			move_state()

func move_state():
	state += 1
	
	match state:
		1:
			$AnimationPlayer.play("1")
		2:
			queue_free()
			GameState.cur_player.update_sprite_xflip(-1)
			GameState.cur_player.global_position = $PlayerSprite.global_position + Vector2(0,-10)
			GameState.cur_player.insta_kill()

func _on_AnimationPlayer_animation_finished(anim_name):
	move_state()
