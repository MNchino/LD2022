extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("ring")
	$Modulator.play("ring")


func _on_Teleporter_body_entered(body):
	if GameState.is_entity_alive:
		GameState.teleport_back_to_beginning()
