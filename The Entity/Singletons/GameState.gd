extends Node

var cur_player : Player = null

signal player_spawned(player)

func set_player(player : Player):
	cur_player = player
	emit_signal('player_spawned', player)
