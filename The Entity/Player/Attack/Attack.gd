extends Area2D

func _ready():
	$DestructionTimer.start()
	$AnimationPlayer.play("Parry")
	rotation = GameState.cur_entity.global_position.angle_to_point(global_position)

func _on_DestructionTimer_timeout():
	queue_free()
