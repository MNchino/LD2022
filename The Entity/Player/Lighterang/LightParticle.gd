extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var direction : Vector2
var speed_range : Vector2 = Vector2(1, 2)
var speed : float

# Called when the node enters the scene tree for the first time.
func _ready():
	direction = Vector2(randf()*2 - 1, randf()*2 - 1).normalized()
	speed = rand_range(speed_range.x, speed_range.y)
	
func _process(delta : float):
	global_position += speed*direction

func _on_DestroyTimer_timeout():
	queue_free()
