extends Node2D

var homing_bullet_template = preload("res://Entity/Bullet/HomingBulletToEnemy.tscn")
var homing_bullets_to_spawn = 1
var homing_bullet_speed = 240

func configure(amount_to_spawn, cd_time):
	homing_bullets_to_spawn = amount_to_spawn
	$ShootCD.wait_time = cd_time

func activate():
	$ShootCD.start()
	aim_and_fire_bullet()

func aim_and_fire_bullet():
	if !is_instance_valid(GameState.cur_entity):
		return
	var target_position = GameState.cur_entity.global_position
	var angle_to_travel = (target_position - global_position).normalized()
	
	#Travel randomly if entity not there
	if !GameState.cur_entity.active:
		angle_to_travel = Vector2.RIGHT.rotated(deg2rad(randi()%360))
	if homing_bullets_to_spawn == 1:
		call_deferred('fire_bullet',homing_bullet_template,angle_to_travel,homing_bullet_speed)
	else:
		for k in range(homing_bullets_to_spawn):
			var bullet_dir = Vector2.RIGHT.rotated(deg2rad(rad2deg(angle_to_travel.angle()) + 360.0*(float(k + 0.5)/homing_bullets_to_spawn)))
			call_deferred('fire_bullet',homing_bullet_template,bullet_dir,homing_bullet_speed)

func fire_bullet(template, angle_to_travel, speed, base_angle = 0):
	if !is_instance_valid(GameState.cur_entity):
		return
	var i = template.instance()
	GameState.cur_entity.add_bullet_child(i)
	i.set_as_toplevel(true)
	i.global_position = global_position 
	i.dir = angle_to_travel
	i.speed = speed
	if base_angle != 0:
		i.set_base_angle(base_angle)

func _on_ShootCD_timeout():
	aim_and_fire_bullet()
