extends Node2D
var active : bool = false

var homing_bullet_template = preload("res://Entity/Bullet/HomingBulletToEnemy.tscn")
var homing_bullets_to_spawn = 12
var homing_bullet_speed = 240

func _ready():
	# warning-ignore:return_value_discarded
	GameState.connect("player_died", self, "lights_out")
	call_deferred("reparent",self)

func reparent(node):
	var target_new_parent = get_tree().get_nodes_in_group('sortyboy')[0]
	var temp_pos = node.global_position
	node.get_parent().remove_child(node) # error here  
	target_new_parent.add_child(node)
	node.global_position = temp_pos

func activate():
	if active: 
		return
	
	active = true
	$Particles2D.emitting = true
	$HitParticle.restart()
	$HitParticle.emitting = true
	$Audio/Reveal.pitch_scale = rand_range(0.95,1.05)
	$Audio/Reveal.play()
	$AnimationPlayer.play("LightUp")
	$Light2D.visible = true
	$AnimatedSprite.animation = "On"

func _on_LightHurtbox_area_entered(_area):
	activate()

func _on_ParryHurtbox_area_entered(_area):
	if active:
		$Particles2D.emitting = true
		$HitParticle.restart()
		$HitParticle.emitting = true
	else:
		activate()
	
	$Audio/Hit.pitch_scale = rand_range(0.9,1.1)
	$Audio/Hit.play()
	if GameState.is_snow_mode:
		if is_instance_valid(GameState.cur_entity):
			var target_position = GameState.cur_entity.global_position
			var angle_to_travel = (target_position - global_position).normalized()
			for k in range(homing_bullets_to_spawn):
				var bullet_dir = Vector2(1,0).rotated(deg2rad(rad2deg(angle_to_travel.angle()) + 360.0*(float(k + 0.5)/homing_bullets_to_spawn)))
				call_deferred('fire_bullet',homing_bullet_template,bullet_dir,homing_bullet_speed)
		hide()
	else:
		GameState.reset_dashes()
		
func fire_bullet(template, angle_to_travel, speed, base_angle = 0):
	var i = template.instance()
	GameState.cur_entity.add_child(i)
	i.set_as_toplevel(true)
	i.global_position = global_position 
	i.dir = angle_to_travel
	i.speed = speed
	if base_angle != 0:
		i.set_base_angle(base_angle)

func lights_out(_player : Player):
	$Light2D.visible = false
