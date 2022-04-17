extends Node2D

var player_template = preload("res://Player/Player.tscn");

func spawn():
	if !GameState.cur_player:
		var p = player_template.instance()
		get_tree().get_nodes_in_group("sortyboy")[0].add_child(p)
		p.global_position = global_position
		GameState.set_player(p)
		hide()
 
func spawn_no_death(_player : Player):
	_player.global_position = global_position
	_player.configure_autoshoot()
