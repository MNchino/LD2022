extends Control


var blink_range = Vector2(.05, .3)
var blink_range_hide = Vector2(.1, 2.2)

# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	GameState.connect("player_died_gui", self, 'show_after_death')

func show_after_death():
	visible = true
	$AnimationPlayer.play("RESET")

func _input(_event):
	if Input.is_action_just_pressed("game_restart"):
		if visible:
			GameState.reset()
			# warning-ignore:return_value_discarded
			get_tree().reload_current_scene()

func show_progress():
	$PercentCounter/TimeBeforeHideOrShow.start()
	print("num trabled", GameState.travelled_rooms, " ", GameState.num_rooms)
	var messing_around = rand_range(-0.025, 0.025)
	var frac = 1 - float(GameState.travelled_rooms)/GameState.num_rooms + messing_around
	$PercentCounter/Label.text = str(round(clamp(frac,0,1)*100.0))

func _on_TimeBeforeHideOrShow_timeout():
	$PercentCounter.visible = !$PercentCounter.visible
	$PercentCounter/TimeBeforeHideOrShow.wait_time = rand_range(blink_range.x, blink_range.y) if $PercentCounter.visible else rand_range(blink_range_hide.x, blink_range_hide.y)
	$PercentCounter/TimeBeforeHideOrShow.start()
