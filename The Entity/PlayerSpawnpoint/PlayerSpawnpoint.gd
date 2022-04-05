extends Node2D

var player_template = preload("res://Player/Player.tscn");

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Spawn");

func spawn():
	var p = player_template.instance()
	get_tree().get_nodes_in_group("sortyboy")[0].add_child(p)
	p.global_position = global_position
	GameState.set_player(p)
	hide()
