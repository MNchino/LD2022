extends Node2D
var active : bool = false

func _ready():
	# warning-ignore:return_value_discarded
	GameState.connect("player_died", self, "lights_out")

func activate():
	if active: 
		return
	
	active = true
	$Particles2D.emitting = true
	$HitParticle.restart()
	$HitParticle.emitting = true
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
	
	GameState.reset_dashes()

func lights_out(_player : Player):
	$Light2D.visible = false
