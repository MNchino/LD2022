extends Node2D

#var spawnpoint = preload("res://PlayerSpawnpoint/PlayerSpawnpoint.tscn")
var player_template = preload("res://Player/Player.tscn")

func _ready():
	var camera = get_tree().get_current_scene().get_node("PlayerCamera")
	camera.target = self
	camera.global_position = global_position

func _on_StepTimer_timeout():
	$Step.play()
	$Step/StepTimer.start()

func _on_AnimationPlayer_animation_finished(_anim_name):
	$Step/StepTimer.stop()
	
	var p : Player = player_template.instance()
	get_tree().get_nodes_in_group("sortyboy")[0].add_child(p)
	p.global_position = global_position
	p.is_facing_up = true
	GameState.num_dashes = 0
	GameState.use_dash()
	GameState.set_player(p)
	
	queue_free()
