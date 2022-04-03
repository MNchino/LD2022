extends Node2D

var moving_to_player = false
export var lerp_to_player : float = 0

func _ready():
	$AnimationPlayer.play("Throw")
	
func _physics_process(delta):
	print("lerp is", $Lighterang.global_position.x, " ", GameState.cur_player.global_position.x, " ", lerp_to_player)
	$Lighterang.global_position.x = lerp($Lighterang.global_position.x, GameState.cur_player.global_position.x, lerp_to_player)
	$Lighterang.global_position.y = lerp($Lighterang.global_position.y, GameState.cur_player.global_position.y, lerp_to_player)
	
func _on_AnimationPlayer_animation_finished(anim_name):
	var anim = $AnimationPlayer.get_animation("Throw")
	anim.track_set_enabled(anim.find_track(NodePath('Lighterang:position:x')), true)
	anim.track_set_enabled(anim.find_track(NodePath('Lighterang:position:y')), true)
	queue_free()

func stop_tracking_position():
	var anim = $AnimationPlayer.get_animation("Throw")
	anim.track_set_enabled(anim.find_track(NodePath('Lighterang:position:x')), false)
	anim.track_set_enabled(anim.find_track(NodePath('Lighterang:position:y')), false)
