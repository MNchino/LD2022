extends Node

var cur_player : Player = null
var started : bool = false
var time_taken : float = 0

signal player_spawned(player)
signal player_died(player)

func set_player(player : Player):
	cur_player = player
	emit_signal('player_spawned', player)
	
func unset_player(player : Player):
	cur_player = player
	emit_signal('player_died', player)

func _process(delta):
	if started:
		time_taken += delta

func reset():
	time_taken = 0
	started = false
	cur_player = null
