extends KinematicBody2D

var speed : float  = 0
var dir : Vector2  = Vector2(0,0)

func _physics_process(delta):
	move_and_slide(dir*speed)

func _process(delta):
	$Light2D.rotation_degrees = rad2deg(dir.angle() - 90)
