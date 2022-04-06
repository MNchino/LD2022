extends Node

var _left_input : int = 0
var _right_input : int = 0
var _up_input : int = 0
var _down_input : int = 0
var xdir : int = 0 setget , get_xdir
var ydir : int = 0 setget , get_ydir
var dir : Vector2 = Vector2(1,0) setget , get_dir
var game_input_enabled : bool = true

signal shoot_pressed
signal dash_pressed
signal attack_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	# warning-ignore:return_value_discarded
	GameState.connect("player_won", self, "disable_game_input")
	# warning-ignore:return_value_discarded
	GameState.connect("player_died", self, "reset_inputs_from_death")

func _input(event : InputEvent):
	if !game_input_enabled:
		return
		
	if event.is_action("game_left"):
		if event.is_action_pressed("game_left"):
			_left_input =  -1
		elif event.is_action_released("game_left"):
			_left_input = 0
	elif event.is_action("game_right"):
		if event.is_action_pressed("game_right"):
			_right_input =  1
		elif event.is_action_released("game_right"):
			_right_input = 0
	elif event.is_action("game_up"):
		if event.is_action_pressed("game_up"):
			_up_input =  -1
		elif event.is_action_released("game_up"):
			_up_input = 0
	elif event.is_action("game_down"):
		if event.is_action_pressed("game_down"):
			_down_input =  1
#			if self.ydir > 0:
#				emit_signal("down_pressed")
		elif event.is_action_released("game_down"):
			_down_input = 0
	elif event.is_action_pressed("game_shoot"):
		emit_signal("shoot_pressed")
	elif event.is_action_pressed("game_dash"):
		emit_signal("dash_pressed")
	elif event.is_action_pressed("game_attack"):
		emit_signal("attack_pressed")
		
# Prevent glitches on clicking out
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		reset_inputs()
		get_tree().paused = true
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		get_tree().paused = false
		
func disable_game_input(_player : Player):
	game_input_enabled = false
	reset_inputs()

func reset_inputs_from_death(_player : Player):
	reset_inputs()
	
func enable_game_input():
	game_input_enabled = true
	
func reset_inputs():
	_left_input = 0
	_right_input = 0
	_up_input = 0
	_down_input = 0
			
#########################################################################################

func get_xdir():
	return _left_input + _right_input
	
func get_ydir():
	return _up_input + _down_input 
	
func get_dir():
	return Vector2(self.xdir, self.ydir)
