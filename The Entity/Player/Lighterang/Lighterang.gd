extends Area2D

var particle_template = preload("res://Player/Lighterang/LightParticle.tscn")
var rotation_speed = 270*7 # degrees per second
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	$Sprite.rotation_degrees += rotation_speed*delta
