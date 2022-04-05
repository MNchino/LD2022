extends Area2D

var firsthit : bool = false
var freeze_time : float = 0.05

func _ready():
	$DestructionTimer.start()
	$AnimationPlayer.play("Parry")
	if is_instance_valid(GameState.cur_entity):
		rotation = GameState.cur_entity.global_position.angle_to_point(global_position)
	else:
		rotation = get_global_mouse_position().angle_to_point(global_position)

func _on_DestructionTimer_timeout():
	queue_free()

func _on_Attack_area_entered(area : Area2D):
	if area.get_parent() is Bullet || area.get_parent().name == "Entity":
		if firsthit:
			return
		
		if area.get_parent() is Bullet:
			$ParrySound.pitch_scale = rand_range(0.95,1.05)
			$ParrySound.play()
		
		firsthit = true
		GameState.freeze(freeze_time)
		GameState.emit_signal("parried", rotation)
		#var pos = to_local(area.global_position)
		#GameState.hit_particle(global_position.linear_interpolate(pos, .5))
		GameState.hit_particle(area.global_position)
		GameState.hit_particle(global_position)
		$Sprite.visible = false
