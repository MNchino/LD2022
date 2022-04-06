extends Area2D

var entity_template = preload("res://Entity/Entity.tscn")

func _on_IntroLabel_body_entered(_body):
	var entity = entity_template.instance()
	get_tree().get_nodes_in_group("sortyboy")[0].add_child(entity)
	entity.position = $Node2D.global_position
	entity.active = true
	disconnect("body_entered", self, "_on_IntroLabel_body_entered")
	$AnimationPlayer.play("FadeIn")
