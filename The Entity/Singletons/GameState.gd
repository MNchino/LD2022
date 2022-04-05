extends Node

var cur_player : Player = null
var cur_entity : Entity = null
var cur_hit_particle : Particles2D = null
var started : bool = false
var time_taken : float = 0
var num_dashes : int = 2
var num_rooms : int = 0
var travelled_rooms : int = -1

var freeze_timer : Timer
var root : Viewport

signal player_spawned(player)
signal player_died(player)
signal player_won(player)
signal player_died_gui()
signal dashes_changed(new_num)
#warning-ignore:unused_signal
signal parried(direction)

func _ready():
	init_freezetimer()
	
func init_freezetimer():
	freeze_timer = Timer.new()
	freeze_timer.pause_mode = PAUSE_MODE_PROCESS
	freeze_timer.name = "GameStateFreezeTimer"
	freeze_timer.one_shot = true
	freeze_timer.autostart = true
	
	root = get_tree().root
	root.call_deferred("add_child", freeze_timer)
	
	# warning-ignore:return_value_discarded
	freeze_timer.connect("timeout", self, "_on_freezetimer_timeout")

func set_entity(entity : Entity):
	cur_entity = entity

func set_player(player : Player):
	cur_player = player
	started = true
	emit_signal('player_spawned', player)
	
func unset_player(player : Player):
	cur_player = player
	emit_signal('player_died', player)
	
func set_hit_particle(hitpart : Particles2D):
	cur_hit_particle = hitpart
	
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
	num_rooms = 0
	travelled_rooms = -1
	reset_dashes()
	GInput.enable_game_input()

func freeze(time : float = 1.0):
	freeze_timer.wait_time = time
	freeze_timer.start()
	get_tree().paused = true
	
func _on_freezetimer_timeout():
	get_tree().paused = false

func hit_particle(pos : Vector2):
	cur_hit_particle.restart()
	cur_hit_particle.position = pos
	cur_hit_particle.emitting = true
