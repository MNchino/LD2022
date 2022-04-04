extends Node2D


var active : bool = false

func activate():
	if active: 
		return
	
	active = true
	$Particles2D.emitting = true
	$AnimationPlayer.play("LightUp")
	$Light2D.visible = true
	$AnimatedSprite.animation = "On"

func _on_LightHurtbox_area_entered(area):
	activate()

func _on_ParryHurtbox_area_entered(area):
	if active:
		$Particles2D.emitting = true
	else:
		activate()
	
	GameState.reset_dashes()
