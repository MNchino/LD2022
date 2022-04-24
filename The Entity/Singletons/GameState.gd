extends Node

var cur_player : Player = null
var cur_entity : Entity = null
var cur_hit_particle : Particles2D = null
var started : bool = false
var time_taken : float = 0
var num_dashes : int = 2
var num_rooms : int = 0
var travelled_rooms : int = -1 setget set_travelled_rooms
var camera : Camera2D = null
var finished : bool = false
var drowned : bool = false
var intro_started : bool = false
var intro_done : bool = false
var phases = [0,3,6,9]
var phases_xcy = [0,2,5,8]
var phases_snow = [0,50, 100, 150, 200, 250]
var cur_phase = -1
var is_snow_mode = false
var is_xcy_mode = false
var times_drowned_in_a_row = 0 setget set_times_drowned_in_a_row
var times_drowned_in_a_row_required = 1
var recieved_item = false
var unlocked_snow = false
var unlocked_xcy = false
var max_int = 9223372036854775807
var alo_high_score = max_int
var xcy_high_score = max_int
var snow_high_score = max_int
var entity_max_health : float = 300
var entity_health = entity_max_health setget set_entity_health
var freeze_timer : Timer
var root : Viewport
var rooms = []
var cur_chaser = null
var health_to_gain_on_soft_reset = 30
var shooting_amount_level = [1,1,2,3,4,5]
var shooting_speed_level = [1,1,1,.5,.5,.3]
var num_teleports = 0
var player_shooting_speed : float = shooting_speed_level[num_teleports]
var player_shooting_amount : float = shooting_amount_level[num_teleports]
var is_player_in_final_room : bool = false
var is_entity_alive = true

signal player_spawned(player)
signal player_died(player)
signal player_won(player)
signal player_died_gui()
signal dashes_changed(new_num)
#warning-ignore:unused_signal
signal parried(direction)
signal phase_changed(new_phase)
signal unlocked_item()
signal save_data_loaded()
signal player_teleported_to_start()
signal player_reached_last_room()

signal entity_died()
signal game_won()


func _ready():
	reset()
	init_freezetimer()
	OS.set_window_size(Vector2(1280,720))
	OS.center_window()
	
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
	camera = get_tree().get_current_scene().get_node("PlayerCamera")
	cur_player = player
	started = true
	emit_signal('player_spawned', player)
	
func teleport_back_to_beginning():
	is_player_in_final_room = false
	if is_instance_valid(cur_chaser):
		cur_chaser.restart()
	set_travelled_rooms(-1)
	for room in rooms:
		room.is_travelled = false
		
	#Configure player auto shooting
	num_teleports += 1
	player_shooting_speed = shooting_speed_level[min(shooting_speed_level.size() - 1, num_teleports)]
	player_shooting_amount = shooting_amount_level[min(shooting_amount_level.size() - 1, num_teleports)]
		
	var room_to_spawn : Node2D = rooms[0]
	var spawnpoint = room_to_spawn.spawnpoint
	spawnpoint.spawn_no_death(cur_player)
	
	emit_signal('player_teleported_to_start')
	
func unset_player(player : Player):
	cur_player = player
	save_game()
	emit_signal('player_died', player)
	
func set_hit_particle(hitpart : Particles2D):
	cur_hit_particle = hitpart
	
func finish_game(player : Player):
	started = false
	finished = true
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
	randomize()
	drowned = false
	time_taken = 0
	started = false
	cur_player = null
	num_rooms = 0
	travelled_rooms = -1
	cur_phase = -1
	finished = false
	is_snow_mode = false
	is_xcy_mode = false
	set_entity_health(entity_max_health)
	reset_dashes()
	GInput.enable_game_input()
	
func soft_reset():
	reset_dashes()
	GInput.enable_game_input()
	started = false
	drowned = false
	cur_player = null
	for berri in get_tree().get_nodes_in_group('glowboi'):
		berri.show_to_player()
	set_entity_health(min(entity_health +health_to_gain_on_soft_reset, entity_max_health))

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
	
func set_entity_health(new_health : float):
	entity_health = max(new_health, 0)
	var health_remaining = entity_max_health - entity_health
	var phase = -1
	if is_snow_mode:
		if entity_health <= 0:
			print('we ded boiz')
			emit_signal("entity_died")
			is_entity_alive = false
			return
		for min_before_phase in phases_snow:
			if health_remaining >= min_before_phase:
				phase += 1
		if cur_phase != phase:
			cur_phase = phase
			print ("changing to phase ", phase)
			emit_signal("phase_changed", cur_phase)
			
func game_won():
	emit_signal('game_won')

func set_travelled_rooms(new_num : int):
	travelled_rooms = new_num
	var phase = -1
	var used_phases = phases
	if is_xcy_mode:
		used_phases = phases_xcy
	if is_snow_mode:
		#Disable enemy in last room, so player can't camp
		if travelled_rooms >= num_rooms - 1:
			is_player_in_final_room = true
			print("we should despawn entity")
			emit_signal("player_reached_last_room")
	else:
		for min_before_phase in used_phases:
			if travelled_rooms >= min_before_phase:
				phase += 1
		if cur_phase < phase:
			cur_phase = phase
			emit_signal("phase_changed", cur_phase)
		
func set_times_drowned_in_a_row(new_num : int):
	times_drowned_in_a_row = new_num
	if times_drowned_in_a_row >= times_drowned_in_a_row_required && !recieved_item:
		recieved_item = true
		GameState.recieved_item = true
		GameState.save_game()
		emit_signal("unlocked_item")
		
func hsv_to_rgb(h, s, v, a = 1):
	#based on code at
	#http://stackoverflow.com/questions/51203917/math-behind-hsv-to-rgb-conversion-of-colors
	var r
	var g
	var b

	var i = floor(h * 6)
	var f = h * 6 - i
	var p = v * (1 - s)
	var q = v * (1 - f * s)
	var t = v * (1 - (1 - f) * s)

	match (int(i) % 6):
		0:
			r = v
			g = t
			b = p
		1:
			r = q
			g = v
			b = p
		2:
			r = p
			g = v
			b = t
		3:
			r = p
			g = q
			b = v
		4:
			r = t
			g = p
			b = v
		5:
			r = v
			g = p
			b = q
	return Color(r, g, b, a)
	
func load_game():
	var save_game = File.new()
	if !save_game.file_exists("user://save_game.save"):
		emit_signal("save_data_loaded")
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore the object it represents
	var error = save_game.open("user://save_game.save", File.READ)
	if error == OK:
		while not save_game.eof_reached():
			var current_line = parse_json(save_game.get_line())
			recieved_item = bool(current_line["recieved_item"])
			unlocked_xcy = bool(current_line["unlocked_xcy"])
			unlocked_snow = bool(current_line["unlocked_snow"])
			alo_high_score = int(current_line["alo_high_score"])
			xcy_high_score = int(current_line["xcy_high_score"])
			snow_high_score = int(current_line["snow_high_score"])
		save_game.close()
		emit_signal("save_data_loaded")
		
func respawn_in_next_room():
	var room_to_spawn_index = travelled_rooms
	if travelled_rooms < num_rooms - 1:
		room_to_spawn_index += 1
		
	var room_to_spawn : Node2D = rooms[room_to_spawn_index]
	var spawnpoint = room_to_spawn.spawnpoint
	spawnpoint.spawn()

func save_game():
	var save_game = File.new()
	var error = save_game.open("user://save_game.save", File.WRITE)
	if error == OK:
		var save_data = {
			"recieved_item" : recieved_item,
			"unlocked_xcy" : unlocked_xcy,
			"unlocked_snow" : unlocked_snow,
			"alo_high_score" : alo_high_score,
			"xcy_high_score" : xcy_high_score,
			"snow_high_score" : snow_high_score
		}
		save_game.store_string(to_json(save_data)) #NOTE - CAN USE STORE LINE, BUT LAST STORE MUST BE STORE STRING
		save_game.close()
