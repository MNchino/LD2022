extends Node2D


var active : bool = false

func activate():
	if active: 
		return
	
	active = true
	$AnimationPlayer.play("LightUp")

func _on_LightHurtbox_area_entered(area):
	activate()

func _on_ParryHurtbox_area_entered(area):
	GameState.reset_dashes()
