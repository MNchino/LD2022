extends Node2D


func _ready():
	$AnimationPlayer.play("Throw")
	
func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
