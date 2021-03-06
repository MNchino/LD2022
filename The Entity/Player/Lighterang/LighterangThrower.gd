extends Node2D

var moving_to_player = false
export var lerp_to_player : float = 0
var can_home_player : bool = true
var playback_speed = 2

func _ready():
	$AnimationPlayer.playback_speed = playback_speed
	$AnimationPlayer.play("Throw")
	# warning-ignore:return_value_discarded
	GameState.connect("player_died", self, "stop_player_follow")
	# warning-ignore:return_value_discarded
	GameState.connect("player_won", self, "stop_player_follow")
	
func _physics_process(_delta):
	if can_home_player:
		$Lighterang.global_position.x = lerp($Lighterang.global_position.x, GameState.cur_player.global_position.x, lerp_to_player)
		$Lighterang.global_position.y = lerp($Lighterang.global_position.y, GameState.cur_player.global_position.y, lerp_to_player)
	
func _on_AnimationPlayer_animation_finished(_anim_name):
	var anim = $AnimationPlayer.get_animation("Throw")
	anim.track_set_enabled(anim.find_track(NodePath('Lighterang:position:x')), true)
	anim.track_set_enabled(anim.find_track(NodePath('Lighterang:position:y')), true)
	queue_free()
 
func stop_tracking_position():
	var anim = $AnimationPlayer.get_animation("Throw")
	anim.track_set_enabled(anim.find_track(NodePath('Lighterang:position:x')), false)
	anim.track_set_enabled(anim.find_track(NodePath('Lighterang:position:y')), false)

func stop_player_follow(_player):
	can_home_player = false
