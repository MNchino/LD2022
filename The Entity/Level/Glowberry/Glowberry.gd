extends Node2D
var active : bool = false

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
	GameState.reset_dashes()

func lights_out(_player : Player):
	$Light2D.visible = false
