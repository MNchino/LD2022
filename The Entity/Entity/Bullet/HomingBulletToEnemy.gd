extends Node2D

export(float) var speed : float  = 0
export(Vector2) var dir : Vector2  = Vector2(0,0)
var homing : bool = true
var distance_before_stop_homing = 60
var minimum_angle_before_stop_homing = 90
var visited_enemy = false
var turn_speed = 12

func _physics_process(_delta):
	if homing && is_instance_valid(GameState.cur_entity):
		var enemy_pos = GameState.cur_entity.global_position
		var distance_to_enemy = (enemy_pos - global_position).length()
		var angle_to_enemy = (enemy_pos - global_position).normalized()
		var angle_difference = angle_to_enemy.angle() - dir.angle()
		if distance_to_enemy < distance_before_stop_homing:
			visited_enemy = true
			if abs(rad2deg(angle_difference)) < minimum_angle_before_stop_homing:
				homing = false
		elif visited_enemy:
			homing = false
		else:
			#dir = dir.rotated(angle_difference)
			dir = lerp(dir, angle_to_enemy, turn_speed*_delta).normalized()
	position += dir*speed*_delta
		
func _process(_delta):
	rotation_degrees = rad2deg(dir.angle())

func _on_Timer_timeout():
	homing = false

func _on_VisibilityNotifier2D_screen_exited():
	call_deferred("queue_free")

func _on_Hitbox_tree_exiting():
	queue_free()
