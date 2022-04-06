extends Area2D

var entity_template = preload("res://Entity/Entity.tscn")

func _on_IntroLabel_body_entered(_body):
	disconnect("body_entered", self, "_on_IntroLabel_body_entered")
	var entity = entity_template.instance()
	var sorty = get_tree().get_nodes_in_group("sortyboy")[0]
	sorty.call_deferred("add_child", entity)
	entity.position = $Node2D.global_position
	entity.active = true
	entity.homing_bullets_to_spawn = 0
	entity.shoot_delay_min = .1
	entity.shoot_delay_max = .1
	entity.bullet_speed = 600
	entity.homing_bullet_speed = 400
	entity.get_node("AnimationPlayer").play("FadeIn")
	
	var cd : Timer = entity.get_node("ShootingCoolDown")
	cd.wait_time = 3
	cd.start()
	$AnimationPlayer.play("FadeIn")
	GameState.intro_done = true
