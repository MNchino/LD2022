extends Node

var cur_player : Player = null
var cur_entity : Entity = null
var started : bool = false
var time_taken : float = 0
var num_dashes : int = 2

signal player_spawned(player)
signal player_died(player)
signal player_won(player)
signal player_died_gui()
signal dashes_changed(new_num)

func set_entity(entity : Entity):
	cur_entity = entity

func set_player(player : Player):
	cur_player = player
	started = true
	emit_signal('player_spawned', player)
	
func unset_player(player : Player):
	cur_player = player
	emit_signal('player_died', player)
	
func finish_game(player : Player):
	started = false
	emit_signal('player_won', player)
	
func can_use_dash():
	return num_dashes > 0
	
func use_dash():
	num_dashes = int(max(0, num_dashes - 1))
	emit_signal('dashes_changed', num_dashes)
	
func reset_dashes():
	num_dashes = 2
	emit_signal('dashes_changed', num_dashes)
	
func start_death_gui():
	emit_signal('player_died_gui')

func _process(delta):
	if started:
		time_taken += delta

func reset():
	time_taken = 0
	started = false
	cur_player = null
	reset_dashes()
	GInput.enable_game_input()
